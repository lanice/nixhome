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
