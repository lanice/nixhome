{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.backup;
  landingRoot = "/data/backups/restic";
  offsiteRoot = "s3:s3.us-east-005.backblazeb2.com/lanice-restic-offsite";
  uploadLimitKiB = 10240;

  pascalCase = name: let
    camel = lib.toCamelCase name;
  in
    lib.toUpper (lib.substring 0 1 camel) + lib.substring 1 (-1) camel;

  landingPassword = name:
    config.age.secrets.${
      if name == "mail-archive"
      then "mailArchiveResticPassword"
      else "restic${pascalCase name}Password"
    }.path;
  offsitePassword = name:
    config.age.secrets."resticOffsite${pascalCase name}Password".path;
  freshnessHours = name:
    if name == "sencha"
    then 30
    else 12;

  repoCalls = operation:
    lib.concatMapStringsSep "\n" (name:
      operation {
        inherit name;
        landing = "${landingRoot}/${name}";
        offsite = "${offsiteRoot}/${name}";
        landingPassword = landingPassword name;
        offsitePassword = offsitePassword name;
        freshnessHours = freshnessHours name;
      })
    cfg.landingRepos;

  offsiteChain = pkgs.writeShellScript "restic-offsite-chain" ''
    set -u -o pipefail

    process_repo() {
      local name="$1"
      local freshness_hours="$2"
      local landing_repo="$3"
      local offsite_repo="$4"
      local landing_password="$5"
      local offsite_password="$6"
      local snapshots_json newest_time newest_epoch now_epoch age_seconds config_status

      echo "[$name] checking landing freshness"
      if ! snapshots_json=$(${pkgs.restic}/bin/restic \
        --repo "$landing_repo" \
        --password-file "$landing_password" \
        --retry-lock=2h \
        snapshots --json); then
        echo "[$name] failed to read landing snapshots" >&2
        return 1
      fi

      newest_time=$(${pkgs.jq}/bin/jq -r 'if length == 0 then empty else max_by(.time).time end' <<<"$snapshots_json")
      if [ -z "$newest_time" ]; then
        echo "[$name] stale source: landing repository has no snapshots" >&2
        return 1
      fi
      if ! newest_epoch=$(${pkgs.coreutils}/bin/date --date="$newest_time" +%s); then
        echo "[$name] failed to parse newest landing snapshot time: $newest_time" >&2
        return 1
      fi
      now_epoch=$(${pkgs.coreutils}/bin/date +%s)
      age_seconds=$((now_epoch - newest_epoch))
      if [ "$age_seconds" -gt "$((freshness_hours * 3600))" ]; then
        echo "[$name] stale source: newest snapshot is $age_seconds seconds old; threshold is $freshness_hours hours" >&2
        return 1
      fi

      if ${pkgs.restic}/bin/restic \
        --repo "$offsite_repo" \
        --password-file "$offsite_password" \
        --retry-lock=2h \
        cat config >/dev/null; then
        :
      else
        config_status=$?
        if [ "$config_status" -ne 10 ]; then
          echo "[$name] failed to open offsite repository (restic exit $config_status)" >&2
          return 1
        fi
        echo "[$name] initializing offsite repository from landing chunker parameters"
        if ! ${pkgs.restic}/bin/restic \
          --repo "$offsite_repo" \
          --password-file "$offsite_password" \
          --retry-lock=2h \
          init \
          --from-repo "$landing_repo" \
          --from-password-file "$landing_password" \
          --copy-chunker-params; then
          echo "[$name] offsite repository initialization failed" >&2
          return 1
        fi
      fi

      echo "[$name] copying landing snapshots offsite at no more than ${toString uploadLimitKiB} KiB/s"
      if ! ${pkgs.restic}/bin/restic \
        --repo "$offsite_repo" \
        --password-file "$offsite_password" \
        --retry-lock=2h \
        --limit-upload=${toString uploadLimitKiB} \
        copy \
        --from-repo "$landing_repo" \
        --from-password-file "$landing_password"; then
        echo "[$name] offsite copy failed; landing prune skipped" >&2
        return 1
      fi

      # One writer per repo. Default grouping (host,paths) freezes the old
      # path set's last 7/4/12 snapshots forever whenever a sender's paths change.
      echo "[$name] pruning offsite repository"
      if ! ${pkgs.restic}/bin/restic \
        --repo "$offsite_repo" \
        --password-file "$offsite_password" \
        --retry-lock=2h \
        forget --prune --group-by host --keep-daily 7 --keep-weekly 4 --keep-monthly 12; then
        echo "[$name] offsite prune failed; landing prune skipped" >&2
        return 1
      fi

      echo "[$name] pruning landing repository"
      if [ "$name" = sencha ]; then
        if ! ${pkgs.restic}/bin/restic \
          --repo "$landing_repo" \
          --password-file "$landing_password" \
          --retry-lock=2h \
          forget --prune --group-by host --keep-hourly 24 --keep-daily 7 --keep-weekly 4 --keep-monthly 12; then
          echo "[$name] landing prune failed" >&2
          return 1
        fi
      elif ! ${pkgs.restic}/bin/restic \
        --repo "$landing_repo" \
        --password-file "$landing_password" \
        --retry-lock=2h \
        forget --prune --group-by host --keep-daily 7 --keep-weekly 4 --keep-monthly 12; then
        echo "[$name] landing prune failed" >&2
        return 1
      fi

      echo "[$name] copy and both prunes complete"
    }

    failed_repos=()
    ${repoCalls (repo: ''
      if ! process_repo \
        ${lib.escapeShellArg repo.name} \
        ${toString repo.freshnessHours} \
        ${lib.escapeShellArg repo.landing} \
        ${lib.escapeShellArg repo.offsite} \
        ${lib.escapeShellArg repo.landingPassword} \
        ${lib.escapeShellArg repo.offsitePassword}; then
        failed_repos+=(${lib.escapeShellArg repo.name})
      fi
    '')}

    uuid=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.resticOffsiteHealthcheckUuid.path})
    if [ "''${#failed_repos[@]}" -eq 0 ]; then
      if ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid"; then
        echo "offsite chain complete: ${toString (lib.length cfg.landingRepos)} repositories copied and pruned"
        exit 0
      fi
      echo "offsite chain healthcheck success ping failed" >&2
    else
      printf 'offsite chain failed for repositories:' >&2
      printf ' %s' "''${failed_repos[@]}" >&2
      printf '\n' >&2
    fi

    ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid/fail" || true
    exit 1
  '';

  monthlyCheck = pkgs.writeShellScript "restic-offsite-monthly-check" ''
    set -u -o pipefail

    check_repo() {
      local name="$1"
      local landing_repo="$2"
      local offsite_repo="$3"
      local landing_password="$4"
      local offsite_password="$5"
      local month="$6"
      local repo_failed=0
      local snapshots_json offsite_snapshot original landing_snapshots
      local candidates count index selected_path relative_path scratch
      local offsite_file landing_file offsite_hash landing_hash

      echo "[$name] checking one twelfth of offsite data"
      if ! ${pkgs.restic}/bin/restic \
        --repo "$offsite_repo" \
        --password-file "$offsite_password" \
        --retry-lock=2h \
        check --read-data-subset="$month/12"; then
        echo "[$name] offsite data check failed" >&2
        repo_failed=1
      fi

      echo "[$name] checking landing metadata"
      if ! ${pkgs.restic}/bin/restic \
        --repo "$landing_repo" \
        --password-file "$landing_password" \
        --retry-lock=2h \
        check; then
        echo "[$name] landing metadata check failed" >&2
        repo_failed=1
      fi

      echo "[$name] selecting restore canary"
      if ! snapshots_json=$(${pkgs.restic}/bin/restic \
        --repo "$offsite_repo" \
        --password-file "$offsite_password" \
        --retry-lock=2h \
        snapshots --json); then
        echo "[$name] failed to list offsite snapshots for canary" >&2
        return 1
      fi
      offsite_snapshot=$(${pkgs.jq}/bin/jq -r 'if length == 0 then empty else max_by(.time).id end' <<<"$snapshots_json")
      if [ -z "$offsite_snapshot" ]; then
        echo "[$name] canary has no offsite snapshot" >&2
        return 1
      fi
      original=$(${pkgs.jq}/bin/jq -r --arg id "$offsite_snapshot" '.[] | select(.id == $id) | .original // empty' <<<"$snapshots_json")
      if [ -z "$original" ]; then
        echo "[$name] canary snapshot $offsite_snapshot has no original landing snapshot ID" >&2
        return 1
      fi

      if ! landing_snapshots=$(${pkgs.restic}/bin/restic \
        --repo "$landing_repo" \
        --password-file "$landing_password" \
        --retry-lock=2h \
        snapshots --json "$original"); then
        echo "[$name] failed to look up original landing snapshot $original" >&2
        return 1
      fi
      if ! ${pkgs.jq}/bin/jq -e --arg id "$original" 'any(.[]; .id == $id)' <<<"$landing_snapshots" >/dev/null; then
        echo "[$name] original landing snapshot $original is absent" >&2
        return 1
      fi

      if ! candidates=$(${pkgs.restic}/bin/restic \
        --repo "$offsite_repo" \
        --password-file "$offsite_password" \
        --retry-lock=2h \
        ls --json "$offsite_snapshot" \
        | ${pkgs.jq}/bin/jq -s '[.[] | select(.message_type == "node" and .type == "file" and (.size // 0) < 16777216) | {path}] | sort_by(.path)'); then
        echo "[$name] failed to list canary candidates" >&2
        return 1
      fi
      count=$(${pkgs.jq}/bin/jq 'length' <<<"$candidates")
      if [ "$count" -eq 0 ]; then
        echo "[$name] canary snapshot has no regular file smaller than 16 MiB" >&2
        return 1
      fi
      index=$((month % count))
      selected_path=
      if ! IFS= read -r -d $'\0' selected_path < <(
        ${pkgs.jq}/bin/jq -j --argjson index "$index" '.[$index].path, "\u0000"' <<<"$candidates"
      ); then
        echo "[$name] failed to select canary path" >&2
        return 1
      fi
      printf '[%s] restoring canary path %q\n' "$name" "$selected_path"

      scratch="$RUNTIME_DIRECTORY/$name"
      ${pkgs.coreutils}/bin/rm -rf -- "$scratch"
      ${pkgs.coreutils}/bin/mkdir -p -- "$scratch/offsite" "$scratch/landing"
      if ! ${pkgs.restic}/bin/restic \
        --repo "$offsite_repo" \
        --password-file "$offsite_password" \
        --retry-lock=2h \
        restore "$offsite_snapshot" --target "$scratch/offsite" --include "$selected_path"; then
        echo "[$name] offsite canary restore failed" >&2
        ${pkgs.coreutils}/bin/rm -rf -- "$scratch"
        return 1
      fi
      if ! ${pkgs.restic}/bin/restic \
        --repo "$landing_repo" \
        --password-file "$landing_password" \
        --retry-lock=2h \
        restore "$original" --target "$scratch/landing" --include "$selected_path"; then
        echo "[$name] landing canary restore failed" >&2
        ${pkgs.coreutils}/bin/rm -rf -- "$scratch"
        return 1
      fi

      relative_path="''${selected_path#/}"
      offsite_file="$scratch/offsite/$relative_path"
      landing_file="$scratch/landing/$relative_path"
      if [ ! -f "$offsite_file" ] || [ ! -f "$landing_file" ]; then
        echo "[$name] selected canary path was not restored as a regular file" >&2
        ${pkgs.coreutils}/bin/rm -rf -- "$scratch"
        return 1
      fi
      offsite_hash=$(${pkgs.coreutils}/bin/sha256sum <"$offsite_file")
      landing_hash=$(${pkgs.coreutils}/bin/sha256sum <"$landing_file")
      offsite_hash="''${offsite_hash%% *}"
      landing_hash="''${landing_hash%% *}"
      ${pkgs.coreutils}/bin/rm -rf -- "$scratch"
      if [ "$offsite_hash" != "$landing_hash" ]; then
        echo "[$name] canary hash mismatch: offsite=$offsite_hash landing=$landing_hash" >&2
        return 1
      fi

      echo "[$name] monthly checks and restore canary passed with SHA-256 $offsite_hash"
      return "$repo_failed"
    }

    month=$((10#$(${pkgs.coreutils}/bin/date +%m)))
    failed_repos=()
    ${repoCalls (repo: ''
      if ! check_repo \
        ${lib.escapeShellArg repo.name} \
        ${lib.escapeShellArg repo.landing} \
        ${lib.escapeShellArg repo.offsite} \
        ${lib.escapeShellArg repo.landingPassword} \
        ${lib.escapeShellArg repo.offsitePassword} \
        "$month"; then
        failed_repos+=(${lib.escapeShellArg repo.name})
      fi
    '')}

    uuid=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.resticMonthlyHealthcheckUuid.path})
    if [ "''${#failed_repos[@]}" -eq 0 ]; then
      if ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid"; then
        echo "monthly offsite checks and canaries complete for ${toString (lib.length cfg.landingRepos)} repositories"
        exit 0
      fi
      echo "monthly healthcheck success ping failed" >&2
    else
      printf 'monthly checks failed for repositories:' >&2
      printf ' %s' "''${failed_repos[@]}" >&2
      printf '\n' >&2
    fi

    ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid/fail" || true
    exit 1
  '';
in {
  systemd.services.restic-offsite = {
    description = "Copy landing restic repositories to B2 and prune both tiers";
    after = [
      "network-online.target"
      "restic-backups-boba.service"
      "restic-rest-server.service"
    ];
    wants = ["network-online.target"];
    unitConfig.OnFailure = "notify-failure@%n.service";
    serviceConfig = {
      Type = "oneshot";
      User = "restic";
      Group = "restic";
      UMask = "0077";
      CacheDirectory = "restic-offsite";
      EnvironmentFile = config.age.secrets.resticB2Credentials.path;
      ExecStart = offsiteChain;
      # rest-server 0.14.0 keeps one shared in-memory quota counter. Local-path
      # prunes bypass it, so recount after every full or partial chain run.
      ExecStopPost = "+${pkgs.systemd}/bin/systemctl restart restic-rest-server.service";
    };
  };

  systemd.timers.restic-offsite = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 05:30:00";
      Persistent = true;
    };
  };

  systemd.services.restic-offsite-monthly = {
    description = "Check offsite and landing restic repositories with restore canaries";
    after = [
      "network-online.target"
      "restic-offsite.service"
    ];
    wants = ["network-online.target"];
    unitConfig.OnFailure = "notify-failure@%n.service";
    serviceConfig = {
      Type = "oneshot";
      User = "restic";
      Group = "restic";
      UMask = "0077";
      CacheDirectory = "restic-offsite";
      RuntimeDirectory = "restic-offsite-monthly";
      EnvironmentFile = config.age.secrets.resticB2Credentials.path;
      ExecStart = monthlyCheck;
    };
  };

  systemd.timers.restic-offsite-monthly = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-01 06:00:00";
      Persistent = true;
    };
  };
}
