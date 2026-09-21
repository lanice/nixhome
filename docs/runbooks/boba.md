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

The API is at `https://tokenscope.lanice.dev`, tailnet-only. The pinned version
has no web UI; `/` and `/projects` return 404. Reporting and project management
require network access, not a token. Ingestion requires a host-scoped bearer
credential. Project identities and mappings live in SQLite.

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
  root. Worktree attribution uses verified Git links; wrapper databases are
  not read.

Each `tokenscope-collect-<tool>.timer` runs hourly and five minutes after boot.
Persistent timers catch missed runs; failed services retry after fifteen minutes.
They neither wake laptops nor require AC power. Each pass discovers and hashes
all accessible history, including resumed old sessions. Unchanged files reuse
cached parsing; unchanged offline runs also reuse validated aggregates. Changed
runs use one bulk reader export rather than an export per reporting day.
The pinned reader uses packaged offline pricing.

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

Compare the journal result with `tokenscope status` and its host/tool last-success
timestamp. Successful quiet scans advance freshness; failed scans do not.
A disconnected collector cannot publish its failure, so the prior success ages.
An offline host that has never submitted is absent, not a successful zero.
Private temporary directories can hide Git worktrees under another process's
`/tmp`; missing Git evidence remains an attribution gap.

### Reports and assignments through the CLI

The shared Home Manager CLI configuration installs `tokenscope` and writes
`~/.config/tokenscope/config.json` with `server = "https://tokenscope.lanice.dev"`.
After activation, commands work from any directory without ingestion credentials:

```sh
tokenscope monthly                 # Year to date, grouped by month
tokenscope                         # Month-to-date overview
tokenscope monthly --range all
tokenscope status
tokenscope directories --unassigned
tokenscope projects
tokenscope project create NAME
tokenscope project assign NAME --host HOST --directory /absolute/checkout
tokenscope monthly --project NAME --json
```

Accounting dates use America/New_York. Costs are known estimates, not invoices.
Server selection precedence is `--server`, `TOKENSCOPE_SERVER`, XDG config,
then `http://127.0.0.1:8080`. CLI reports require the upgraded API server.

Parent directories include descendants; more-specific mappings override them.
Known subagents follow their parent. Verified worktrees follow the checkout
unless an explicit worktree mapping overrides it. The location list describes
directory rules; record provenance shows the effective session attribution.

Reassigning or removing a mapping changes historical grouping on the next
request, not usage. Unmapped locations and unknown directories remain in totals.
The CLI creates projects and assigns directories; rename and deletion use the
HTTP API. Assignment changes read and replace a complete set, so coordinate
concurrent edits. Any tailnet client with access can edit projects.
Never put personal project names or mappings in the flake or application defaults.

### Upgrades

Publish and test application fixes in its repository, then update only the
`tokenscope` flake input. Deploy Boba and Taro with `colmena apply --on boba,taro`;
the owner pulls and runs `nh os switch` on Longjing and Sencha.
Use the coordinated API/CLI cutover below only when crossing that older breaking
revision. The incremental upgrade does not require it.

Revision `962ba7455b498a3f58e9a644eb39faf944b34b28` removes T3 database reading.
The collector module no longer accepts `t3State` or passes `--t3-state`.
Before activating this revision, finish pending uploads containing T3 links
with the previous collector and server versions. New ingestion accepts only Git
evidence. Keep existing state directories; stored usage and worktree associations
remain intact.

Preserve the server's SQLite state and collector progress directories across
upgrades. Project state needs no mapping-file migration or `--projects` argument.
Use the existing coherent backup and isolated-restore procedure before a schema
change. Verify installed runs and reports after activation; a build alone does
not prove collection.

### Incremental collection (2026-09-21)

Revision `23afd2f50ad7b4c7e2c889a9c71de3e42b0c5c1f` packages ccusage
`20.0.23+tokenscope.4`. Updating the pin enables incremental processing with the
existing `--state` and `--offline` arguments. No credentials, timer, state-path,
ingestion-protocol or database migration is required.

Keep existing state and pending uploads. The new collector replays pending
batches before scanning; its first successful pass creates processing caches.
Source bytes are still hashed on each pass, so late historical files are not
excluded by date. Reader, pricing and relevant configuration changes invalidate
derived results. Git/worktree evidence is rechecked even on unchanged runs.

For a one-time full reconciliation, run the configured collection command with
`--rebuild` in the same account and credential context. Do not leave that flag
in the hourly service or delete the state directory to force a refresh.

Boba and Taro were deployed through Colmena. The server retained all eight
projects and their assignment counts. Taro's first observed new-reader pass
took 515 ms; two repeat passes succeeded in 147 ms and 157 ms, compared with
roughly 0.8–1.0 seconds before the upgrade. These are elapsed times from the
service journal. Workstation activation is owner-managed.

Follow-up revision `82b8d91e5e693eae83da8368c12d758b5d95067a` restores Claude's
tolerance for syntactically corrupt final records, including NUL padding.
Incomplete JSON prefixes still require a retry; source consistency checks remain.
The reader stays at `.4`. Preserve transcripts, caches and pending uploads;
normal collection after activation is sufficient, without `--rebuild`.
Boba and Taro were deployed and verified at this revision; Taro's collection
succeeded in 172 ms. Longjing and Sencha deployment remains owner-managed.

### API and CLI cutover to b1bd84d

The pin is `b1bd84d90246ac3f18c3d090e6c7862d9b9b6436`, upgraded from `962ba74`.
The reader remains ccusage `20.0.23+tokenscope.3`. Database schema v6 removes
`source`; usage identity and collection status now use host/tool. The module
drops `--source`, and encrypted grants retain their tokens with host-only scope.
The historical `coding` component in collector state paths stays unchanged.

1. Pause all collector timers, including Sencha. Drain pending uploads with the
   old server and collectors. Confirm no `pending.json` remains; never delete it.
   Prevent collector retries and restarts during the cutover.
2. Stop Boba's server and back up its whole state directory, old grants, and
   system generation. Keep that backup private. Do not reboot during the cutover.
3. Activate Boba with the new grants and package. Startup migrates schema 1–5
   transactionally to v6. Conflicting observations abort without changing the
   old database. A successful migration cannot be undone by switching binaries;
   rollback requires restoring the stopped pre-migration state and old grants.
4. Activate all collectors at the same pin, then resume collection and timers.
   Check `tokenscope status` and `tokenscope monthly` through the HTTPS endpoint.

The guided cutover uses per-unit
`/run/systemd/system/<unit>.d/99-tokenscope-cutover.conf` conditions to prevent
automatic starts during activation. A failed stage leaves its guards in place.
Inspect the failure before removing them and reloading systemd; never resume an
old collector against the new server. Guards disappear on reboot, so keep hosts
running until the cutover finishes. Boba's private rollback backup includes
`state/`, `grants.json` and `system`; its path is recorded in
`/var/lib/tokenscope-pre-v6-backup-path`.

The former `/api/report`, `/api/project-assignments`, and `/api/source-state`
routes are removed. Use `/api/usage`, the project-management API, and
`/api/collection-states`. `/api/projects` now returns an `items` envelope.

Pre-activation verification built Boba, Taro, Longjing and Sencha and passed the
packaged Go suite. A coherent online copy of the production schema-v5 database
migrated to v6 with all usage/session rows, projects, assignments and worktrees
preserved. XDG-configured monthly reports and JSON status/projects worked against
that isolated copy from different working directories. This was not activation.

### Verified rollout (2026-09-20)

The initial rollout used `1adbbc43846e733cc823017626a82714a00234c4`. Its reader
reported `20.0.23+tokenscope.2`. Real imports exposed Codex copied ancestor headers
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

### Claude compatibility repair (2026-09-20)

The shared application pin is `80a3cdfd5abf090678bd8d6812d8890290e1aae1`,
with ccusage `20.0.23+tokenscope.3`. Ordinary Claude sessions use assistant-established
native identities and their earliest matching location. Copied files share a native
reader export; workflow agents retain ccusage's aggregate and parent attribution.
The session reader now accepts the agent-progress envelopes already handled by
daily discovery. Counting, pricing and deduplication remain in ccusage.

Claude metadata skips syntax-invalid JSON lines, matching the reader. Damaged
records remain outside accounting coverage. Valid JSON with invalid metadata and
genuinely conflicting conversation identities still fail. Do not delete transcripts,
limit history, or disable reconciliation to obtain a successful run.

The corrected package imported Sencha's complete accessible Claude history into an
isolated database. Every reporting day's tokens and costs matched ccusage; mixed-ID
initial locations and a repeated oldest-day collection were verified. Synthetic
regressions, the package's full Go suite and static analysis passed. No real
transcript was changed. Temporary verification state and credentials were removed.

Boba, Taro and Longjing were built, activated and verified at the new pin.
Installed Longjing Claude/Codex/OMP and Taro Codex runs succeeded with reader
provenance `20.0.23+tokenscope.3`. Central history and project assignments survived.
Sencha's checkout is repinned and its system built, but SSH activation has no
authentication agent and sudo requires a password. Its installed Claude unit still
uses the previous package until an administrator runs this on Sencha:

```sh
sudo nixos-rebuild switch --flake /home/lanice/nixhome#sencha
```

Then check the installed Claude journal and central source freshness. Isolated
verification is not a production import. Sencha's Codex transport failure recovered
through its existing retry before this upgrade; no pending upload was discarded.
