# boba runbook

Operational quirks that are not derivable from the config. Dates are when the
issue was diagnosed.

## atlantic NIC TX checksum offload (2026-06-07)

boba's NIC is an Aquantia/Marvell AQC107 (`enp95s0`, driver `atlantic`). With
TX checksum offload enabled the driver emits bad UDP checksums, corrupting
WireGuard/Tailscale packets. Receivers drop ~2.5% as checksum errors, which
collapses tunneled TCP to ~2 Mbit/s while raw LAN TCP is unaffected. Every
Jellyfin client reaches boba only over Tailscale, so all of them get choppy
playback at once. Not a transcode, storage, CPU, DNS or DERP problem.

Signature:

- tunnel throughput ~100x lower than direct LAN for the same file
- `nstat UdpInErrors` climbing on the *receiving* peer while `UdpRcvbufErrors`
  stays 0
- `ss -ti` shows `cwnd:10` pinned plus `TCPLostRetransmit`

Fix is committed in `hosts/boba/default.nix`:
`linkConfig.TransmitChecksumOffload = false` on a `.link` unit for `enp95s0`.
Runtime probe: `nix run nixpkgs#ethtool -- -K enp95s0 tx off`.

It appeared on the first boot of kernel 7.0.10; the kernel-regression
attribution was never confirmed. Re-test removing the workaround after kernel
bumps (boba moved to 6.18 LTS in August 2026).

## Containers reaching host services

Containers reach host-native services via the `podman0` bridge
(`host.containers.internal` = 10.88.0.1), and `nixos-fw` drops that traffic by
default. Pattern: `networking.firewall.interfaces."podman0".allowedTCPPorts` in
`hosts/boba/default.nix`, one commented entry per container need.

Not `trustedInterfaces` (a compromised container could reach every host
service) and not `services.X.openFirewall` (exposes the port on the LAN too).
Symptom of forgetting: the container request hangs, often surfacing as a 504 in
a web UI that runs the call synchronously.

## Sandboxed services must order after zfs-mount.service (2026-07-24)

Services with `RootDirectory=`, `BindReadOnlyPaths=`, `ProtectSystem=strict`
or an inotify watcher snapshot their view of the filesystem at start. If
`/data/media` is not mounted yet they capture the empty stub directory under
the mountpoint and see an empty share for their whole lifetime. navidrome hit
this: started 0.7s before `zfs-mount.service`, marked all tracks missing.

The data datasets use native ZFS mounting, not generated fstab mount units.
`RequiresMountsFor=` alone cannot order their initial mount. Any new service
that sandboxes itself and reads a share needs
`after`/`requires = ["zfs-mount.service"]` (see navidrome in
`hosts/boba/services/media.nix` and shelfmark).

Diagnose what the service really sees:

```
sudo nsenter -t $(systemctl show <svc> -p MainPID --value) -m -U --preserve-credentials -- ls <share>
```

Recovery is a plain restart once the dataset is mounted.

## Native data mounts (2026-09-13)

The data datasets previously had both native ZFS mountpoints and fstab entries.
`zfs mount -a` raced the generated mount units, producing "dataset is busy"
failures even though the datasets mounted successfully.

Keep their mountpoints in disko's `options.mountpoint`, not its `mountpoint`
field. Keep `boot.zfs.extraPools = ["data"]`: without fstab entries, the pool
needs an explicit import dependency. Root and system datasets are unchanged.

The cutover reboot is complete. Normal deployments no longer need boot-only
activation for this migration.

## Netconsole verification (2026-09-13)

The old module-load unit returned success even when the kernel rejected its
target because `enp95s0` had no IP. The service now waits up to 60 seconds for
carrier and global IPv4, then configures and checks a configfs target.

Taro must use `enp1s0`: reserved IP `192.168.7.171`, MAC `00:e0:4c:56:27:82`.
The receiver firewall rule is tied to that interface.

After activation, check on boba:

```bash
sudo cat /sys/kernel/config/netconsole/taro/enabled
printf '<3>netconsole manual forwarding check\n' | sudo tee /dev/kmsg
```

The enabled value must be `1`. On taro:

```bash
sudo journalctl -u netconsole-receiver --since '2 minutes ago' --grep='netconsole manual forwarding check'
```

Boba's console log level is 4, so a priority-4 warning is filtered; use
priority 3 for the test. An enabled target does not prove packet delivery.
Missing remote logs alone do not distinguish a hardware reset from a panic.

## EFI random-seed permissions (2026-09-13)

`/boot` uses FAT. Its `fmask=0077,dmask=0077` mount options restrict the
bootloader random seed to root; `chmod` is not persistent permission control
on FAT. After reboot, verify the masks with `findmnt /boot` and check that
`stat -c %a /boot/loader/random-seed` reports `700`.

## Jellyfin: DbUpdateConcurrencyException (2026-05-16)

On 10.11.8 and older, auth/session writes could race on `RowVersion` under
the default `LockingBehavior=NoLock`. User-visible as Jellyseerr "Something
went wrong while trying to sign in" and client token failures. A restart
cleared it for ~12h only.

Upstream fixed jellyfin/jellyfin#16353 in jellyfin/jellyfin#15368, released
in 10.11.9. boba returned to `NoLock` on 10.11.11 on 2026-09-03. The former
`Pessimistic` workaround is unsafe across async thread transitions; see
jellyfin/jellyfin#17560.

`database.xml` is mutable runtime state. Stop Jellyfin before editing it;
shutdown rewrites the in-memory value.

## Sonarr queue and fake downloads (2026-09-14)

SABnzbd's unwanted-extension filter is global, with no category exceptions.
`services/sabnzbd.nix` instead assigns `reject-tv-payloads` only to `tv`.
It checks filenames after unpacking and fails jobs containing executable/script
extensions or `.docx`/`.zipx`. It does not inspect file signatures or archive
contents, and cannot save the bandwidth already spent downloading a fake.
Keep `script_can_fail = true`; otherwise script rejection still reports success.
Software and ebook categories do not run the script.

The guard was activated through SAB's API without a system switch. Its store
path is pinned by `/nix/var/nix/gcroots/sabnzbd-tv-scripts`; remove that extra root
after a system deployment includes the guard.

Usenet-Crawler uses Prowlarr's **Manual search only** sync profile after supplying
11 executable-only fake TV releases. Change its policy in Prowlarr, not Sonarr.
AnimeTosho is disabled: its feed timed out and its
[shutdown notice](https://animetosho.org/about/shutdown2) says ingestion stopped
in May 2026.

Bake Off US release numbering differs from Sonarr's UK numbering. Masterclass
and festive releases belong under Specials. Verify episode content before
manual import; a series-wide title exclusion would also block wanted specials.

## BookOrbit upgrades and KOReader (2026-09-18)

Before activating an upgrade, stop BookOrbit and take a fresh PostgreSQL dump
and app-state backup. Preserve pending `/downloads/book-dock` files separately;
the regular backup excludes `/downloads`. Database migrations run before the
service starts. Rolling back the Nix generation alone does not undo them:
restore the matching database and app state when reverting the application.

The stock plugin download embeds the browser's origin. A ZIP downloaded through
`https://bookorbit.lanice.dev` therefore contains an address the Kindle cannot
reach. Set the plugin's server URL to `http://192.168.4.41:3004` on the Kindle
and check it after installing a fresh preconfigured ZIP. Plugin self-update
archives omit the provisioning file.

After activation, check Book Dock filing, browser reading, and Kindle downloads,
progress, and highlight sync.

Stock nixpkgs 2.10.0 was deployed on September 18 at 21:45 EDT. All 17 pending
migrations completed, with no series indexes cleared. Database counts remained
11 books, 15 files, and one user. Local and published HTTPS health checks passed;
the login page rendered. Authenticated reading, filing, and Kindle sync still
need a user check.

The one-off pre-upgrade backups and extra GC root were removed at the user's
request after deployment. Regular backups and NixOS generations were unchanged.

## Speedtest Tracker server failures (2026-09-20)

Recurring Ookla socket errors and generic CLI failures began July 10.
In completed results' `serverSelection` data, Frontier server 56485 failed
latency selection 3/81 times July 1-9, 35/45 times July 10-19, and 80/90
times September 1-20. Frontier 14229 also failed selection; Gateway Fiber
68118 had no selection failures in that September sample.

Scheduled tests now use Gateway Fiber 68118 in Springfield, MA, through
`SPEEDTEST_SERVERS`. A queued test against it completed successfully.
This avoids the unreliable Frontier endpoints; failed results do not retain
the selected server, so attributing every failure to Frontier is unproven.
No speedtest config or nixpkgs change was found at the July 10 cutoff.

Homepage's v2 widget requests `/api/v1/results/latest`, including failed and
running results. Null measurements become zero throughput and blank ping.
Check the result status before changing the API key or widget version.
The widget does not fall back to the last successful measurement.

## Tokenscope deployment (2026-09-20)

Reports and `/projects` are at `https://tokenscope.lanice.dev`, tailnet-only.
Any private UI viewer can edit projects. Ingestion separately requires a
source-scoped bearer credential. Project identities and mappings live in SQLite.
No Dashboard link or unattended collector was added by this deployment.

`flake.lock` pins the Forgejo application for both server and collectors.
Keep its own nixpkgs pin so the packaged ccusage matches application verification.
For development only, an override can be evaluated without rewriting that lock:

```sh
nix eval --raw .#nixosConfigurations.boba.config.systemd.services.tokenscope.serviceConfig.ExecStart \
  --override-input tokenscope path:/path/to/tokenscope --no-write-lock-file
```

Do not use an override for a deployment. Normal activation is
`colmena apply --on boba`.

See [Tokenscope recovery](backup-recovery.md#tokenscope-recovery) for stopped
SQLite capture, landing/B2 snapshot IDs, isolated restore evidence and the
unrelated static-check and offsite-chain diagnostics observed during rollout.
The protected-service recovery checkpoint passed. Production was empty at that
checkpoint; ticket 09 owns source enrollment, unattended collection and backfill.

## Tokenscope collection and project assignments

`hosts/common/tokenscope-collector.nix` enrolls sources independently:

- Longjing and Sencha: the workstation account's Claude, Codex and OMP histories.
- Taro: the coding account's Codex history. No Claude or OMP history was present.
- Codex reads its home, including archived sessions. OMP has an explicit sessions
  root. T3's database supplies retained worktree links on Longjing and Taro,
  never another token source. Sencha's T3 state has not been inspected.

Each `tokenscope-collect-<tool>.timer` runs hourly and five minutes after boot.
Persistent timers catch missed runs; failed services retry after fifteen minutes.
They neither wake laptops nor require AC power. Each pass scans all accessible
history, including resumed old sessions. The pinned reader uses packaged offline
pricing, and reports keep its version and unavailable-pricing status.

Collectors run as the history owner, with a read-only home and system filesystem.
Systemd loads a root-only agenix token through `LoadCredential`; tokens are not
command-line values. Private progress is under
`/var/lib/tokenscope/<host>/coding/<tool>/<destination-sha256>/`, mode 0700.
Do not share that directory between sources or destinations, or delete a pending
upload to hide a failed pass. A subsequent run replays it before rescanning.

Inspect an installed source with:

```sh
systemctl status tokenscope-collect-codex.service tokenscope-collect-codex.timer
journalctl -u tokenscope-collect-codex.service
sudo systemctl start tokenscope-collect-codex.service
```

Compare the journal result with the report's per-source status and last-success
timestamp. Successful quiet scans advance freshness; failed scans do not.
A disconnected collector cannot publish its failure, so the prior success ages.
An offline host that has never submitted is absent, not a successful zero.
Private temporary directories can hide Git worktrees under another process's
`/tmp`; missing Git/T3 evidence remains an attribution gap.

### Assignments through the private UI

Open `https://tokenscope.lanice.dev/projects` after collection:

1. Create a named project.
2. Choose an observed location, or enter its host and absolute checkout directory.
3. Save the mapping. Map other hosts' checkouts explicitly to the same project.
4. Open the report and select that project. Combine provider, model, host and tool
   filters as needed; download the selected JSON from the same page.

Parent directories include descendants; more-specific mappings override them.
Known subagents follow their parent. Verified worktrees follow the checkout
unless an explicit worktree mapping overrides it. The location list describes
directory rules; record provenance shows the effective session attribution.

Renaming keeps the project's ID and saved filters. Reassigning or removing a
mapping changes historical grouping on the next request. Project deletion
requires confirmation and removes mappings, not usage. Unmapped locations and
unknown directories remain in totals. Any private UI viewer can edit; SQLite
shares assignments across browsers and devices, not browser-local storage.
Never put personal project names or mappings in the flake or application defaults.

### Upgrades

Publish and test application fixes in its repository, then update only the
`tokenscope` flake input. Build Boba and every enrolled host before activation;
deploy the same pin to server and collectors. Use `colmena apply --on boba,taro`
for servers and `nh os switch` on an available workstation. An offline Sencha
remains configuration-ready until it is switched.

Preserve the server's SQLite state and collector progress directories across
upgrades. Project state needs no mapping-file migration or `--projects` argument.
Use the existing coherent backup and isolated-restore procedure before a schema
change. Verify installed runs and reports after activation; a build alone does
not prove collection.

### Verified rollout (2026-09-20)

The fleet pin is `1adbbc43846e733cc823017626a82714a00234c4`. Its packaged reader
reports `20.0.23+tokenscope.2`. Real imports exposed Codex copied ancestor headers
and OMP's repeated subagent filenames and leading title records. The owner
approved application fixes and a shared repin. Regression fixtures failed before
the fixes, then passed with the full application package suite and static analysis.
The Pi patch changes header discovery and session identity, not token counting
or pricing; the application repository documents it.

Boba, Taro, Longjing and Sencha built successfully. Boba and Taro were deployed
with Colmena; Longjing was switched through desktop-authorized `nixos-rebuild`.
Installed Longjing Claude/Codex/OMP and Taro Codex runs submitted through HTTPS.
Their timers were active, persistent and non-waking, with fifteen-minute failure
retries. Collector state was 0700 under the correct source account; agenix
credentials stayed root-only. Sencha was offline: built and configured for three
sources, but neither activated nor live-verified.

Real fleet imports supplied the project setup. Eight project identities and ten
location assignments were created through `/projects`. Shared-host grouping,
known parent attribution and retained T3 worktree attribution were observed.
Unmapped and unknown-directory history remained visible. The final server
restart preserved projects, assignments and accounting totals.

Desktop and mobile browser checks covered daily/monthly reports, five combined
filters, provenance, matching JSON downloads, and shared assignments in an
independent browser context. All five JSON mutations and all five HTML form
actions rejected cross-site writes through the published proxy with HTTP 403.
Isolated browser state covered rename with stable filters, reassignment, removal,
confirmed deletion and unavailable pricing without changing accounting history.

The final packaged collector passed isolated unavailable-destination recovery:
pending bytes survived separate processes, replay worked after source removal,
quiet scans advanced success, and older resumed sessions refreshed without a
lookback or duplication. Source failures preserved prior success and did not
block healthy sources. Deleted transcripts and disabled sources retained central
history. Real repeated passes preserved historical records; ongoing sessions
updated their existing aggregates.

Fleet formatting/package checks and changed-file Statix/Deadnix passed. Existing
backup exclusions, retention, publication and unrelated schedules were unchanged.
Ticket 08's protected-service checkpoint remains the backup/restore evidence;
this rollout needed no schema migration. Disposable servers, histories, credentials,
manual enrollment state and scripts were removed. Detailed accounting snapshots
and collection timestamps remain in the private ticket evidence, not public config.
