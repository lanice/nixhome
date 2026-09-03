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

Non-legacy ZFS datasets are mounted by `zfs mount -a`, not by a generated
`.mount` unit, so `RequiresMountsFor=` has nothing to attach to. Any new service
that sandboxes itself and reads a share needs
`after`/`requires = ["zfs-mount.service"]` (see navidrome in
`hosts/boba/services/media.nix` and shelfmark).

Diagnose what the service really sees:

```
sudo nsenter -t $(systemctl show <svc> -p MainPID --value) -m -U --preserve-credentials -- ls <share>
```

Recovery is a plain restart once the dataset is mounted.

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
