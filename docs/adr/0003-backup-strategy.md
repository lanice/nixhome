# Backups are restic, hub-and-spoke through boba, offsite on B2 behind Object Lock

Longjing's extension was deployed on 2026-09-10 and its initial landing backup
completed. The first offsite copy and production restore canary remain unverified;
the backup recovery runbook records the next checks.

Until now the fleet had one copy of almost everything. taro shipped its mail
archive and forgejo dumps to boba nightly, but boba itself — paperless, every
service's state, the ebooks — existed once, on a raidz1 pool that protects
against a dead disk and nothing else. sencha had no backup tooling at all. And
boba's `zfs-snapshot-*` timers had been firing for months without snapshotting
anything, because no dataset carried `com.sun:auto-snapshot`.

The strategy: **restic everywhere, hub-and-spoke.** sencha, longjing and taro
back up to landing repos on boba over Tailscale; boba copies every landing repo
plus its own backup set to Backblaze B2 nightly. Only boba holds offsite credentials.
Restoring with boba gone needs restic, the B2 key and the offsite repo
password — `restic copy` produces a fully independent repository — plus the
printed recovery packet to reach Bitwarden and the B2 console from nothing.
boba's own data has only two failure domains (boba, B2): its landing repo
shares the chassis and the `data` pool with its sources, and a third
physical target for ~50 GB was judged not worth the hardware.

Landing repos live on their own dataset, `data/backups`, which is **not**
snapshotted: a restic repo is already versioned, and snapshotting it retains
every pruned pack a second time. Senders reach them through restic's
rest-server in **append-only** mode, so a compromised sender can add
snapshots but not delete them; boba owns every repo file and does all
pruning. Everything else worth keeping is snapshotted
(`system/home`, `system/var`, `data/storage`; `data/media` daily + weekly
only), and `/var/lib/containers` moved to its own un-snapshotted dataset so
image churn doesn't inflate them.

## Considered options

**borg** — ssh-only targets, no object storage. No advantage over restic, which
the mail archive already used.

**ZFS send/recv offsite** — the most efficient path for boba, useless for the
two ext4 hosts, and it needs a ZFS receiver. Not worth a second tool.

**Each host → B2 directly** — simpler wiring, but three sets of credentials,
laptop uploads over whatever Wi-Fi it's on, and no fast local restore. Rejected
in favour of the hub.

**Offsite provider** — B2 over Hetzner Storage Box (EU-only, sftp, no
key scoping), rsync.net and Wasabi (800 GB / 1 TB minimums; Wasabi's 90-day
retention fights `prune`), R2 (no delete-less token, no region pin). B2 is
cheapest at ~300 GB, US-East next to boba, and supports Object Lock.

**sftp chroot landing** — one Unix user per sender, `restrict,command="internal-sftp"`
plus a root-owned `ChrootDirectory` with the repo as a writable
subdirectory. It confines the sender but gives it full delete on its own
repo, so a hostile sender can `forget --prune` everything and B2's 30-day
lock becomes the only floor. Rejected for rest-server `--append-only
--private-repos`: senders can add snapshots and remove their own lock files,
nothing else, and boba owns every repo file. That last part also removes a
second failure: a root-run `copy` that died mid-way would leave a
`root:root 0600` lock in a sender-owned repo, which restic's `backup` fails
on and `unlock` silently skips. Trade: an htpasswd password per sender in
place of an ssh key, and plain HTTP over the tailnet.

**Append-only key on boba** — restic needs delete permission for its own lock
files, so a write-only B2 key breaks every run. Instead: bucket versioning +
Object Lock in **governance** mode with 30-day default retention + one
lifecycle rule (`daysFromHidingToDeleting=30`, unfinished large files
cancelled after 7 days, never upload-age), and a bucket-scoped key with the
exact capabilities `listFiles`, `readFiles`, `writeFiles`, `deleteFiles`,
`listBuckets`, and `listAllBucketNames`. The four file capabilities alone
failed restic's initial S3 `Stat(<config/>)` with `Access Denied`; adding only
the two documented bucket-listing capabilities passed repository creation,
backup, listing, check, restore, hide/delete and prune against a disposable
prefix. The key omits `bypassGovernance` and every retention, lifecycle and
bucket-administration capability. A daily account cap on storage is the one
quantity that bounds a runaway uploader now that B2 bills no class A/B/C
transactions. Compliance mode was
considered and rejected: the threat is a hostile boba, boba's key cannot
bypass governance, and the console login that can is kept out of agenix
entirely (Bitwarden and the recovery packet only), so the two modes are
equivalent against it; compliance only removes the console's ability to clean up a
mistaken or runaway upload — 30 days of undeletable, billed garbage.

**Clock offsets as ordering**: rejected. The offsite unit requires a snapshot
at most 12 h old for each nightly server set, so yesterday's snapshot cannot
pass as tonight's. It copies both laptops' available snapshots regardless of age;
an intentionally offline laptop must not fail the offsite chain. Empty or
unreadable repos and copy/prune errors still fail. It attempts all five repos
regardless of earlier failures and pings its healthcheck only on full success;
forgejo's restic is chained on its dump unit.

## Consequences

- **Every secret belongs in agenix and Bitwarden.** Both workstation user
  identities are agenix admins. Host identities alone give no clean-room
  recovery once those hosts are gone. New credentials must reach Bitwarden
  before deployment; losing the laptop must not lose access to its backup.
- Deliberately not backed up: shows/movies/anime, `/downloads`, container
  images, jellyfin trickplay, Steam and other re-downloadable game data, the
  nix store, package caches, `Sync/photo-share` (the other household laptop's
  responsibility), `Sync/sd*`/`stable-diffusion`, Games ROMs. RAID plus ZFS
  snapshots are the only protection for media, and that is the intended level.
- The Podman volumes observed during the `system/containers` migration are
  deliberately excluded: LibreChat `pgdata2` vector state (disposable;
  one-off migration dump only), Forgejo Actions workspace/environment volumes
  (disposable job state), MongoDB's non-authoritative
  `librechat-mongodb-configdb`, Tracearr's non-authoritative
  `tracearr-backup`, and one empty orphan with no
  current owner. MongoDB and Tracearr's authoritative state is in bind mounts
  under `/var/lib` and remains in boba's backup set. Exact runtime-generated
  volume IDs and observed owners live in the recovery runbook.
- Pruned packs linger 30 days offsite under Object Lock — a few GB, accepted.
  Restic never multiparts a pack (200 MiB part size, 128 MiB max pack), so
  the unfinished-large-file lifecycle rule is a safety net, not a cost
  control.
- A hostile *sender* is bounded by retention, not by the lock: with
  append-only landing it cannot delete the real snapshots, which age out
  under 7d/4w/12m while its garbage accumulates. A week of dailies is the
  detection window; the monthlies survive a year. It can still fill the
  repo, which rest-server's `--max-size` caps.
- Object Lock is set on the bucket at creation. An offsite prune has verified
  that restic can remove current keys without errors and that B2 retains hidden
  prior versions. Lifecycle expiry is observed separately.
- A hostile boba can hide or overwrite every current object. Object Lock keeps
  the prior versions, but the current prefix would no longer be a valid restic
  repository. Recovery from that state is an untested emergency operation:
  isolate boba, revoke its B2 key, use B2 version tooling to reconstruct the
  pre-attack repository in a fresh bucket or local directory, then run
  `restic check` and restore. Do not mutate the production bucket while
  recovering. No reconstruction script or hostile rehearsal is maintained.
  The normal clean-room drill proves recovery when boba is unavailable and the
  current B2 repository is intact; it does not claim tested recovery from a
  mass hostile overwrite.
- The lock protects availability, not confidentiality. boba holds every
  landing and offsite password because it must open a repo to copy it, so a
  hostile boba can read everything backed up — sencha's `.ssh`, keyrings and
  cloud credentials included. Inherent to hub-and-spoke; accepted rather
  than giving each host its own offsite credentials.
- boba's `@backup` snapshots are mounted explicitly (`mount -t zfs`) for the
  backup unit, not reached through `.zfs/snapshot/`: the ctldir automount
  is lazy, namespace-unfriendly and expires.
- Offsite restorability is proven by a monthly machine canary (restore one
  file per repo from B2, compare with the landing copy), not by a recurring
  human rotation; the human drill is annual and restores from every repo
  with the Bitwarden-held passwords, which nothing automated exercises. The
  canary matches offsite to landing snapshots by the `original` field
  `restic copy` records, not by "latest" (`copy` preserves an existing
  `original`, so the field always names the first-hop source; one hop
  here, and a second hop would not change what it points at). It has its
  own dead-man healthcheck: the daily copies would otherwise keep the
  offsite check green while a broken monthly timer stayed silent.
- Neither laptop sends failure mail: an hourly unit that needs the tailnet
  would mail every hour boba is unreachable. Source dead-man deadlines are
  30 h for longjing and 168 h for sencha, including grace. These external
  Healthchecks settings are an operator deployment step, not Nix options.
  Pause only the affected source check for planned downtime and retain
  resume-on-ping. A paused check provides no recovery-point age alarm.
  Never pause the offsite check for laptop downtime. boba and taro keep `OnFailure`.
- Every boba-side repo operation runs as the `restic` user on the local
  path; boba's own backup set also enters through rest-server (loopback),
  so no root-owned file ever lands in a landing repo.
- boba's backup is one systemd unit: `ExecStartPre=+` prepares dumps,
  snapshots and mounts on the host, `ExecStart` runs restic with the
  snapshots bind-mounted over the live paths, `ExecStopPost=+` cleans up on
  every exit. Each `Exec*` command gets its own mount namespace once any
  namespacing option is set (the module sets `PrivateTmp`), so a mount made
  in a sandboxed prepare step dies with it; `+` is what makes one unit
  work.
- Both workstation sets are `$HOME` minus a denylist, not curated allowlists:
  a forgotten include is silent data loss, a forgotten exclude is repo size.
  They share one source module; Sencha's capture policy is unchanged.
- Longjing excludes the entire `.codex/sessions`, `.claude/projects` and
  `.omp/agent/sessions` directories. Their transcripts, subagent records,
  attachments and other contents are disposable after host loss, regardless
  of file size or type. Settings and credentials elsewhere remain included.
  Static directory exclusions replace size-based filtering to avoid custom
  backup preparation code. Sencha's exclusions remain unchanged, and previously
  captured session data ages out under normal retention.
- Longjing's `dev/photos` contains disposable copies. Its explicit `.nobackup`
  marker is honored. Neither this marker nor the session exclusions delete data.
- Workstation backups start only on AC, may finish after unplugging, and inhibit
  sleep during the actual restic backup, including lock waits. No wake schedule,
  battery watcher or application shutdown is introduced.
- `/etc/ssh/ssh_host_*` is in every host's set: it is that host's agenix
  identity.
- taro's nightly `forgejo` backup set includes `/home/coding`, retaining
  non-database T3/Codex state, herdr configuration and session layouts,
  authentication, and `.ssh` credentials and configuration.
  `workspaces`, `.t3/worktrees`, and `.herdr/worktrees` are disposable checkouts
  and excluded entirely, including local Git history and uncommitted files.
  Projects must be recoverable from their Git remotes; losing unpushed work is accepted.
  Package caches are also excluded. The exact exclusions live in `hosts/taro/backup.nix`.
- T3's `.t3/userdata/state.sqlite` and Codex's root `.codex/*.sqlite`
  databases are disposable and deliberately excluded, along with their WAL,
  SHM and rollback-journal sidecars. No database capture or staging is needed.
  Losing their contents after host failure is accepted.
- Coding session JSONL and retained files are live-read, not an atomic snapshot.
  In-flight processes and unflushed memory are not restored. Backups never stop
  T3 or herdr. Routine upgrades do not take a snapshot. Changes to the database
  layout require updating the exclusions.
  Restore steps live in [the recovery runbook](../runbooks/backup-recovery.md#restore-taros-remote-coding-environment).
- boba's consistency contract is crash-consistent: one multi-dataset
  `@backup` ZFS snapshot (a single point in time) bind-mounted over the live
  paths inside the backup unit, plus one atomic logical dump of the host
  PostgreSQL (peertube, bookorbit). Container databases on the snapshotted
  datasets — Tracearr's postgres, LibreChat's mongo — are crash-consistent
  only: they recover from an atomic snapshot as from a power cut, and none
  of that data would be missed. LibreChat's vector DB on the un-snapshotted
  `system/containers` is not backed up at all; each such volume carries a
  comment in Nix.
- Retention is 7 daily / 4 weekly / 12 monthly snapshots on both tiers.
  Both laptops additionally keep 24 hourly snapshots on landing only.
  `--keep-hourly 24` on a nightly repo would keep 24 nights. Only boba prunes,
  in the nightly chain after each repo's copy.
- Operational procedures such as clean-room restore, the annual human drill,
  Forgejo import, credential retrieval order, measured timings, and the
  observed podman volume inventory live in
  `docs/runbooks/backup-recovery.md`, not in the gitignored spec. Deliberate
  inclusion and exclusion decisions stay in this ADR; any excluded or
  specially dumped volume also carries a comment beside its Nix declaration.
- Capture cadence is not a recovery-point guarantee. Both laptops attempt hourly
  captures only while awake, on AC and able to reach boba; taro captures nightly.
  With the agreed source monitoring active, the existing alert-bound calculation
  gives 40 h for server B2 copies, 58 h for longjing and 196 h for sencha:
  source freshness/deadline of 12/30/168 h plus a 25 h copy interval and 3 h grace.
  These bounds depend on the external checks being configured and unpaused.
  The interval is 25 h once a year because the hosts observe DST. Daily timers
  stay outside the skipped 02:00–02:59 spring-forward hour.
- Workstation application state is live-read, not an atomic desktop snapshot.
  Browser, mail and coding-tool databases may need resetting after restore.
  Logins can be recovered from Bitwarden and mail from IMAP; torn profiles
  can still cost bookmarks, address books or local application history.
  This loss is accepted; no database dumps or per-application capture hooks
  are added. Longjing does not inherit taro's disposable coding-database policy.
- ZFS auto-snapshots on boba keep no monthlies (`monthly = 0`): they are for
  oops-recovery, and the restic repos already hold 12 monthlies of the same
  data on the same pool.
