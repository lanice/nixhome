# Backups are restic, hub-and-spoke through boba, offsite on B2 behind Object Lock

Until now the fleet had one copy of almost everything. taro shipped its mail
archive and forgejo dumps to boba nightly, but boba itself — paperless, every
service's state, the ebooks — existed once, on a raidz1 pool that protects
against a dead disk and nothing else. sencha had no backup tooling at all. And
boba's `zfs-snapshot-*` timers had been firing for months without snapshotting
anything, because no dataset carried `com.sun:auto-snapshot`.

The strategy: **restic everywhere, hub-and-spoke.** sencha and taro back up to
landing repos on boba over Tailscale; boba copies every landing repo plus its
own backup set to Backblaze B2 nightly. Only boba holds offsite credentials.
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

**Clock offsets as ordering** — rejected. The offsite unit checks each
source's newest snapshot against a freshness threshold (12 h for the nightly
server sets — yesterday's snapshot cannot pass as tonight's — 30 h for the
laptop) before copying, attempts all four
repos regardless of earlier failures, and pings its healthcheck only on full
success; forgejo's restic is chained on its dump unit. The mail chain already
established this pattern.

## Consequences

- **Every secret exists in agenix and in Bitwarden.** sencha holds the only
  portable, human-operated agenix identity; host identities give no clean-room
  recovery once those hosts are gone. A scheme where losing the laptop also
  loses the ability to decrypt its backup is not a backup.
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
- Object Lock is set on the bucket at creation; verifying restic's behaviour
  under it is part of the mandatory restore drill, not assumed.
- The lock changes what "restore" means when boba was *hostile* rather than
  dead: every object can be hidden and overwritten, the data survives as
  prior versions, and recovery is containment (isolate the host, revoke its
  key) followed by **reconstruction elsewhere — the production bucket is
  never mutated**. A script walks every key's versions under the repo
  prefix and copies, into a fresh bucket or directory, the exact version
  that was current just before the attack cutoff; keys whose last
  pre-cutoff event was a hide marker (restic had pruned them) or that the
  attacker created are skipped. One case, idempotent by construction, no
  privileged write against production. The attacker's versions are left to
  expire; early `bypassGovernance` deletion is cleanup, not recovery.
  In-place promotion (copy old versions over the attacker's, place fresh
  delete markers) was rejected: three cases, delete-marker bookkeeping, and
  a privileged script one prefix bug away from taking all four repos
  offline. Drilled read-only against a small versioned bucket with forced
  pagination — not assumed.
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
- sencha sends no failure mail: it has no msmtp, and an hourly unit that
  needs the tailnet would mail every hour the laptop sits on AC with boba
  unreachable. Its 30 h dead-man healthcheck is the only alarm. boba and
  taro units keep `OnFailure`.
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
- sencha's set is `$HOME` minus a denylist, not a curated allowlist: a
  forgotten include is silent data loss, a forgotten exclude is repo size.
- `/etc/ssh/ssh_host_*` is in every host's set: it is that host's agenix
  identity.
- boba's consistency contract is crash-consistent: one multi-dataset
  `@backup` ZFS snapshot (a single point in time) bind-mounted over the live
  paths inside the backup unit, plus one atomic logical dump of the host
  PostgreSQL (peertube, bookorbit). Container databases on the snapshotted
  datasets — Tracearr's postgres, LibreChat's mongo — are crash-consistent
  only: they recover from an atomic snapshot as from a power cut, and none
  of that data would be missed. LibreChat's vector DB on the un-snapshotted
  `system/containers` is not backed up at all; each such volume carries a
  comment in Nix.
- Retention is 7d/4w/12m on every repo; sencha, the only hourly source,
  adds 24h. (`--keep-hourly 24` on a nightly repo keeps 24 nights.) Only
  boba prunes, landing and offsite alike, in the nightly chain after each
  repo's copy.
- Operational procedures — clean-room restore, B2 reconstruction after a
  hostile overwrite, drill rotation, Forgejo import, credential retrieval
  order, measured timings, and the observed podman volume inventory — live in
  `docs/runbooks/backup-recovery.md`, not in the gitignored spec. Deliberate
  inclusion and exclusion decisions stay in this ADR; any excluded or
  specially dumped volume also carries a comment beside its Nix declaration.
- RPO is stated per lost domain, not as the capture cadence. Against loss
  of the source host: 1 h (sencha), 24 h (taro). Against loss of boba — the
  only case for boba's own data — **B2 is at most 40 h (server sets) /
  58 h (sencha) behind before an alert must have fired**: freshness gate
  12 h / 30 h + 25 h copy interval + 3 h grace. The interval is 25 h once a
  year because the timers are local time and the hosts observe DST; no
  daily timer may sit in the 02:00–02:59 hour, which is skipped at the
  spring-forward. Copying right after each source backup would shave only
  ~2.5 h, so the interval stays 24 h.
- sencha's live-read browser and Thunderbird profiles are accepted loss
  outside the RPO: logins are in Bitwarden and mail is IMAP; a torn SQLite
  profile can cost bookmarks and address books.
- ZFS auto-snapshots on boba keep no monthlies (`monthly = 0`): they are for
  oops-recovery, and the restic repos already hold 12 monthlies of the same
  data on the same pool.
