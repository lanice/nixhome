# Backup recovery runbook

## B2 capacity guardrail

The production bucket's storage cap is `$0.24/day`. Backblaze exposes only
fixed alerts at 75% and 100% of the cap, with no custom storage threshold: the
first fires at `$0.18/day` (about `785 GB`) and the cap represents `1.046 TB`.
The expected steady footprint is about `300 GB`; the remaining `740 GB` covers
one duplicate full upload plus roughly `440 GB` of locked garbage before the
cap stops further growth. Class A, B and C transactions are free, so transaction
caps do not bound this threat.

## Landing quota

boba's rest-server 0.14.0 starts with `--max-size 343597383680` (320 GiB).
This is a shared limit for the entire `/data/backups/restic` path, not a
per-repository limit. In that release, `mux.go` constructs one quota manager
from `server.Path`, and `quota/quota.go` tallies that path recursively,
including every subrepository. The four expected landing repositories currently
total about 180 GiB (sencha 119 GiB, boba 50 GiB, mail archive 6.5 GiB,
Forgejo 3 GiB), so the limit leaves about 140 GiB for churn and temporarily
duplicated packs while bounding a hostile sender far below the 20 TiB available
on the dataset.

Because the quota is shared, a hostile sender can exhaust the landing
allowance and temporarily deny writes to the other senders; rest-server cannot
provide per-user quotas in one process. The service must be restarted after a
boba-side prune or other local deletion so its in-memory usage counter is
re-tallied.

## Retention grouping

Every `forget` in the offsite chain runs with `--group-by host`. restic applies
the keep policy per group, and its default grouping is `host,paths`; the
`--keep-*` counts are relative to the snapshots in a group, not the calendar.
A group that stops receiving snapshots therefore keeps its last 7 daily /
4 weekly / 12 monthly forever. That happened on 2026-08-23 when ssh host keys
joined the mail-archive set: the nine pre-cutover snapshots
(`/var/lib/mail-archive` only) survived two prunes as a frozen second group.
Grouping by host only lets old path sets compete with new ones for the same
slots and age out normally.

Implications:

- Each repo must keep exactly one writer and one logical set. Two jobs from the
  same host sharing a repo would evict each other's snapshots.
- A sender whose hostname changes (reinstall under a new name) forms a new
  group and freezes the old one the same way. Either keep the name, or forget
  the old group by hand once: `restic forget --host <old> --keep-last 0`.
- Watch the prune output on the 05:30 chain: each repo should print one
  `keep N snapshots:` block per prune. Two blocks means a second group exists
  and something about the sender's identity changed.

## Offsite upload limit

Measured from boba on 2026-08-23 with `speedtest-cli`: 175.71 Mbit/s
upstream. The offsite chain passes `--limit-upload=10240`, equivalent to
80 Mbit/s (46% of that measurement), leaving roughly half the uplink available
to Jellyfin and game peers. During the first production copy, the B2 object-size
delta was 258,003,084 bytes over 26.55 seconds: 9,489.9 KiB/s (77.74 Mbit/s),
93% of the configured ceiling after request and object-commit overhead.

## Observed offsite performance

The initial four-repository copy on 2026-08-23/24 completed in 5h01m45s,
sent 177.2 GiB, and successfully copied and pruned sencha, Forgejo, mail
archive and boba. The next scheduled 05:30 run copied only new packs and
finished in 1m31s. A scheduled sencha prune under B2 Object Lock produced a
current delete marker over a retained 11,008,430-byte object version; ticket 11
records the exact key, version IDs, hidden timestamp and 2026-09-24 observation
date.

The manual monthly check on 2026-08-24 used rotation group `8/12`, read 14.2
GiB from B2, and finished in 4m26s. It read 556 sencha, 54 Forgejo, 38 mail
archive and 196 boba data packs; metadata checks passed on all four landing
repositories. The four canaries restored the same file from the newest offsite
snapshot and its landing `original`; all SHA-256 comparisons passed and the
monthly healthcheck accepted the success ping.

## Observed boba backup performance

Measured on boba on 2026-08-23 through the local rest-server:

- Initial snapshot: 184,281 files and 57.693 GiB scanned in 6m43s; 44.535 GiB
  added, 39.694 GiB stored. The service wall time was 6m46s and the landing
  repository occupied 42 GiB.
- Immediate repeat, including stale-snapshot recovery: 184,283 files and
  57.701 GiB scanned in 9s; 3 new, 383 changed, 183,897 unmodified. The fresh
  database dump and other live-state churn added 123.309 MiB logically and
  22.161 MiB stored. Service wall time was 11.957s.
- `/var/cache/restic-backups-boba` occupied 43 MiB after the runs.

These are observations, not alert thresholds. A large departure should be
traced against the configured includes and excludes before changing the set.

## Observed sencha backup performance

Measured on sencha and its boba landing on 2026-08-23:

- The initial broad snapshot processed 1,558,244 files and 179.664 GiB in
  26m09s, adding 125.017 GiB stored. A top-level snapshot inventory traced the
  excess to 23.2 GiB of regenerable pnpm, Go, UMU, Whisper and Bun data; those
  paths were added to the denylist. Steam Link's 2.4 MiB of Flatpak
  paired-device state remains included.
- The corrected warm run processed 723,062 files and 156.482 GiB in 19s,
  adding 23.486 MiB stored. Service wall time was 20.998s.
- During a local boba prune, the next backup logged `repo already locked,
  waiting up to 30m0s`, then saved its snapshot. Service wall time was 25.592s.
- After removing the superseded broad snapshot and pruning with
  `--max-unused=0`, the latest snapshot held 117.993 GiB of compressed raw data
  and the landing occupied 119 GiB. rest-server was restarted afterward so its
  shared in-memory quota counter was re-tallied.

The 20:00 hourly elapse on battery skipped the service, and reconnecting AC did
not start it; the 21:00 elapse remained the fallback. An active backup exposed
a systemd `sleep` inhibitor in `block` mode. The operator declined the
hour-long suspend/wake exercise, so `Persistent=true` is configured but that
wake path was not exercised.

The NixOS restic module's stock initialization probe treats any
`restic cat config` failure as a missing repository. That misclassified an
active prune lock and attempted `restic init`. sencha therefore uses an
equivalent custom initialization probe: lockless read-only config detection,
initialization only for restic's missing-repository exit code, and a 180-second
bound when boba is unreachable. The actual backup retains
`--retry-lock=30m`.

The bound was 30 seconds until 2026-08-25. `Persistent=true` fires the
catch-up about 8 seconds after boot, and `network-online.target` is reached
before the tailnet is usable; on that boot outbound internet took 57 seconds
and the path to boba 96 seconds, so the probe timed out and the unit sat in
`failed` until the next hour. Two earlier boots had the tailnet up within
13 seconds. A probe failure at boot is harmless (the hourly timer retries, no
mail by design) but shows up in `systemctl --failed` on sencha; if that recurs
with 180 seconds, check `journalctl -b -u tailscaled` for `open-conn-track`
timeouts before touching the bound.

The bounded unreachable-boba run failed in 30.051s. The unit had no
`OnFailure`, sent no mail and did not run its success-only healthcheck hook.
The dashboard's last-ping timestamp remained unchanged; its one-day period and
six-hour grace produce the 30-hour deadline.

## Restore taro's remote coding environment

The nightly `forgejo` backup set contains `/home/t3code`, excluding `workspaces`,
`.t3/worktrees`, caches, and the disposable T3/Codex SQLite databases and their
sidecars. Checkouts, unpushed work and database contents are not recovered.

1. Stop `t3code.service` and close coding-account shells before restoring.
2. Restore `/home/t3code`, including the retained `.t3` and `.codex` files,
   and `.ssh`.
3. Set the restored home tree's owner to the current `t3code:t3code` account,
   keep the home and `.ssh` private, and set private keys to mode `0600`.
4. Clone projects again from their Git remotes into `/home/t3code/workspaces`.
   Start `t3code.service` and pair the laptops again if needed. Re-add project
   paths in T3; do not expect its old project or thread records to return.
   Run `codex login status` as `t3code`; reauthenticate if necessary.

Session JSONL and retained files are live-read, not an atomic snapshot. Restore does
not resume in-flight agent processes. If the host was compromised, revoke and replace its
Git key and provider credentials rather than reusing the backed-up credentials.

## Bootstrap sencha's agenix identity

sencha does not run sshd, so NixOS does not generate its host key. After a
reinstall, restore the identity in this order:

```fish
sudo install -d -m 0755 /etc/ssh
sudo ssh-keygen -q -t ed25519 -N "" -C root@sencha \
  -f /etc/ssh/ssh_host_ed25519_key
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Add the printed public key as `fleet.hosts.sencha.hostKey` in
`hosts/fleet.nix`, retain
`age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"]` in sencha's
configuration, add the new host key to every sencha-readable secret in
`secrets/secrets.nix`, then re-key those secrets from the operator identity.
Apply the sencha configuration only after the private key and recipient rules
exist. Nothing else regenerates this key.

## Observed Podman volume inventory

Inventory taken on boba on 2026-08-23 immediately before moving the rootful
Podman graph root to `system/containers`. Hash-named volumes are runtime-created;
the identifiers below record this migration, not stable configuration names.

| Volume | Owner and purpose | Observed size | Backup decision |
| --- | --- | ---: | --- |
| `pgdata2` | LibreChat `vectordb`; PostgreSQL vector state | 9.3 MiB | Deliberately excluded. LibreChat vector state is disposable. |
| `706a369384c4db0d35c78f8a78938c38abd32b24029fd2b404f178f685d35699` | No current container; empty orphaned anonymous volume | 2 KiB | Deliberately excluded. It contains no state and has no active owner. |
| `91cd6d49bf75f79b9fe073e651a27f0b` | Exited Forgejo Actions job; workflow workspace | 1.3 GiB | Deliberately excluded. Runner workspaces are disposable execution state. |
| `91cd6d49bf75f79b9fe073e651a27f0b-env` | Exited Forgejo Actions job; runner environment volume | 1.1 MiB | Deliberately excluded. Runner environment volumes are disposable execution state. |
| `2342a23ad66172ce12925c6c7c4e815af49f220e6f71362c276ae0e35f6f5449` | Tracearr; image-created `/data/backup` volume | 2 KiB | Deliberately excluded. It was empty; authoritative Tracearr state is in `/var/lib/tracearr` and belongs to the boba backup set. |
| `a4827249f6bdac5f9ca2cc9430ae952b6d460080f88dac860c313e0a1bc514ee` | LibreChat MongoDB; image-created `/data/configdb` volume | 2 KiB | Deliberately excluded. It was empty; MongoDB data is in `/var/lib/librechat/data-node` and belongs to the boba backup set. |

The stateful and runner-owned volumes survived the byte-for-byte migration with
their names unchanged. Recreating MongoDB and Tracearr also recreated their
empty image-declared anonymous volumes, exposing that those two IDs could never
be stable across service restarts. Their declarations now assign the stable
names `librechat-mongodb-configdb` and `tracearr-backup`; the replacement
volumes remain deliberately excluded. The post-migration inventory is:

- `pgdata2`
- `706a369384c4db0d35c78f8a78938c38abd32b24029fd2b404f178f685d35699`
- `91cd6d49bf75f79b9fe073e651a27f0b`
- `91cd6d49bf75f79b9fe073e651a27f0b-env`
- `librechat-mongodb-configdb`
- `tracearr-backup`

After the reboot, `zfs-mount.service` became active before the Podman socket,
every container and the Forgejo runner. A read-only snapshot mount of
`system/var` showed that the hidden `/var/lib/containers` stub was empty.
Removing the migration copy reduced `system/var` from 230 GiB to 72.1 GiB;
`system/containers` held 159 GiB.

The migration safety dump for the otherwise excluded `pgdata2` volume is
`/data/storage/migration-safety/pgdata2-2026-08-23.sql`. It was created with
`pg_dumpall` before stopping Podman and loaded successfully with `psql
--set ON_ERROR_STOP=1` into a fresh, tmpfs-backed `ankane/pgvector:latest`
container. This dump is a one-off migration artifact, not a recurring backup.
