# The media group's gid is pinned to 992, inside NixOS's dynamic range

The media estate's shares are co-accessible because every service that touches
them is in one group, `multimedia`. That group was declared without a `gid`, so
NixOS allocated one at activation and recorded it in `/var/lib/nixos/gid-map` —
which meant the number existed only on the running machine. It was not knowable
at evaluation time (`config.users.groups.multimedia.gid` evaluates to `null`
when unset), so the eight modules that needed it hand-copied the literal `992`,
three of them with a comment explaining where the number came from.

Nothing on disk carries that knowledge either. `/data/media` and `/downloads`
live on the `data` pool, which a reinstall does not touch, while the gid map
lives on the root pool, which disko wipes. Rebuilding boba from scratch would
therefore have reallocated `multimedia` to some other number and orphaned every
file in the estate.

We pinned it: `users.groups.multimedia.gid = 992`. With the option set, it
evaluates to `992`, so `homelab.media.gid` can hand the number out and the
literals are gone. `users.users.lanice.uid = 1000` is pinned in
`hosts/common/global/lanice.nix` for the same reason — it is the estate's owner
and had the same problem, and all three hosts already allocated 1000.

## Considered options

992 sits in the range NixOS's allocator walks down from 999, which normally
marks a number as not ours to take. The alternative was a gid outside that range
— 3000, say — which would have been tidier and unambiguous.

We chose 992 because it is what is already on disk. A different number means a
recursive `chgrp` across a 24 TB raidz1 and `/downloads`, landing in the same
maintenance window as the rebuild, with every media service down until it
finishes. Matching disk costs one line and no migration. Declaring the gid
statically also makes the allocator skip it, so the range overlap cannot produce
a collision later.

## Consequences

Pinning is easy to do and expensive to undo: changing 992 to anything else now
carries the recursive `chgrp` we avoided, so treat it as fixed. If the estate
ever moves to a host where 992 is taken, the migration — not the number — is the
work.
