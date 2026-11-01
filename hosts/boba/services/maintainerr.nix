{
  config,
  pkgs,
  ...
}: let
  media = config.homelab.media;
  dataDir = "/var/lib/maintainerr";
  port = toString config.homelab.published.maintainerr.proxyTo;

  # Maintainerr has no per-collection trigger; acts on each item in "Manual: *".
  # Handled items leave the collection, so a later re-download stays.
  deleteManual = pkgs.writeShellApplication {
    name = "maintainerr-delete-manual";
    runtimeInputs = [pkgs.curl pkgs.gawk pkgs.jq];
    text = ''
      api=http://127.0.0.1:${port}/api
      items=$(mktemp)
      trap 'rm -f "$items"' EXIT

      curl -fsS "$api/collections" | jq -r '.[] | select(.title | startswith("Manual: ")) | "\(.id)\t\(.title)"' |
        while IFS=$'\t' read -r id title; do
          page=$(curl -fsS "$api/collections/media/$id/content/1?size=1000")
          if [ "$(jq '.items | length' <<<"$page")" != "$(jq .totalSize <<<"$page")" ]; then
            echo "Could not list all of $title" >&2
            exit 1
          fi
          jq -r --arg id "$id" --arg title "$title" \
            '.items[] | [$id, .mediaServerId, $title, (.sizeBytes // 0), .mediaData.title] | @tsv' <<<"$page"
        done >"$items"

      if [ ! -s "$items" ]; then
        echo "Manual collections are empty."
        exit 0
      fi

      awk -F'\t' '{ printf "%7.1f GB  %-26s %s\n", $4 / 1e9, $3, $5; total += $4 }
        END { printf "\n%d titles, %.1f GB. Deletes them and their files, no undo.\n", NR, total / 1e9 }' "$items"
      read -rp "Type delete to confirm: " answer </dev/tty
      if [ "$answer" != delete ]; then
        echo "Nothing deleted."
        exit 0
      fi

      failed=0
      while IFS=$'\t' read -r id media _ _ name; do
        body=$(jq -cn --argjson c "$id" --arg m "$media" '{collectionId: $c, mediaId: $m}')
        if curl -fsS -o /dev/null -X POST -H 'Content-Type: application/json' -d "$body" "$api/collections/media/handle"; then
          echo "Deleted: $name"
        else
          echo "FAILED, still in collection: $name" >&2
          failed=1
        fi
      done <"$items"
      exit "$failed"
    '';
  };
in {
  environment.systemPackages = [deleteManual];

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 ${media.owner} ${media.group} - -"
  ];

  # Review-only: rule groups carry an *arr action but no "take action after days",
  # so nothing is removed until "Trigger Rule Action" is confirmed per item.
  # Jellyfin/Sonarr/Radarr/Seerr are set in the web UI (stored in its SQLite DB)
  # as http://host.containers.internal:<port>; podman0 ports in hosts/boba/default.nix.
  virtualisation.oci-containers.containers.maintainerr = {
    # Pinned: it deletes media, so upgrades are deliberate.
    image = "ghcr.io/maintainerr/maintainerr:3.31.0";
    autoStart = true;
    user = "${toString media.uid}:${toString media.gid}";
    ports = ["127.0.0.1:${toString config.homelab.published.maintainerr.proxyTo}:6246"];
    environment = {
      TZ = "America/New_York";
      TELEMETRY = "off";
    };
    volumes = ["${dataDir}:/opt/data:rw"];
  };

  homelab.published.maintainerr.proxyTo = 6246;
}
