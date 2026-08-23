# Backup recovery runbook

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
