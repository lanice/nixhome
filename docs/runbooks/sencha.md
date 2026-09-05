# sencha runbook

ThinkPad P1 Gen 5, hybrid Intel Iris Xe + NVIDIA RTX A1000 in
PRIME offload mode, COSMIC desktop. Zen browser notes at the end apply to
longjing too.

## GPU "fallen off the bus" (Xid 79) is thermal

Kernel signature: `NVRM: Xid ...: 79, GPU has fallen off the bus` then
`Xid ...: 154, GPU Reset Required`, compositor dies, hard power-off needed.
Audio keeps playing because it runs on the independent Intel SOF chip. The
signature is always recoverable from `journalctl -b -1 -k`. It can hit with no
telemetry precursor.

Driver theories were exhausted. GSP-off (`NVreg_EnableGpuFirmware=0`, still in
`hosts/sencha/default.nix`) was confirmed active and did not hold; it is a
candidate for removal. The stress test showed both fans maxed with the GPU at
85°C @ 23W and the CPU pinned at Tjmax, i.e. the heatsink could not move the
heat. Fan/fin cleaning on 2026-07-04 recovered ~18°C (GPU 66°C loaded, 52°C
idle, fans with headroom).

Do not repaste. Per the Lenovo HMM (section 1160, local copy at
`~/Documents/thinkpad-p1-gen5-hmm.pdf`) the thermal module and system board on
RTX models are one FRU with liquid-metal TIM and a do-not-disassemble label.
If it recurs: compressed air, bottom cover off (PH0 captive screws; disable the
built-in battery in BIOS first), clean fans and fin stacks in place, else
Lenovo service. Containment: cap clocks with `nvidia-smi -lgc` and avoid
stacking heavy CPU load on a hot GPU, which was the crash trigger.

Harness in `hosts/sencha/gpu-stress-monitor.nix`:

- `gpu-stress-monitor-start` / `gpu-stress-monitor-stop` log to
  `/tmp/gpu-stress-monitor/`: `smi-query.log` (5s, watch `pcie.link.gen`),
  `dmon.log` (1s), `kernel.log` (Xid/NVRM), `system.log` (CPU temp + fan RPM).
- `gpu-stress-test` runs vkmark and glmark2 on the dGPU.

Correlate GPU temp with fan RPM and CPU temp around the Xid.

## Thunderbolt dock loses USB after replug (2026-06-09)

Unplugging from the ThinkPad TBT3 dock and replugging brings the monitor back
(DP alt-mode) but not the USB hub. The dock's xHCI controller
(`0000:25:00.0`) wedges on the hot re-tunnel: `HC died` on unplug, MMIO reads
`0xffffffff` on replug. Ruled out: PCIe remove + rescan, secondary bus reset on
the parent bridge, s2idle (no S3 on this machine), dTBT firmware update,
kernel bumps, `services.hardware.bolt`. Only a reboot recovers it. Power-cycling
the dock's AC brick for ~10s is untested and worth trying first next time.

## MX Master 4 scroll speed depends on transport

- Bluetooth needs Solaar `hires-smooth-resolution = true` (else ~15x too slow)
- Bolt receiver needs `false` (else ~15x too fast)

On BT the kernel `hid-logitech-hidpp` driver does the `*120/multiplier` math
itself; on the dongle events go through generic `hid-input`, which cannot
re-sync the resolution multiplier when Solaar flips the mode. libinput has no
`REL_WHEEL` scaling knob. Solaar persists one setting per device, so one
transport is always wrong. Fish abbrs `scroll_bt` / `scroll_dock` in
`home/lanice/features/cli/fish/default.nix` toggle it by hand. Do not chase
hwdb or libinput quirks; they were investigated and do not apply.

## T3 remote coding on taro

These steps also apply to longjing. NixOS owns the system service and packages.
Do not use the desktop SSH launcher, `t3 service install`, `npx`, or T3's runtime
updater for this environment. Pair with the existing HTTPS server instead.
Upgrade the desktop and taro packages together through this flake after active
agent work finishes.

Update the pinned packages from the repository root:

```sh
./pkgs/t3code/update
./pkgs/t3code/update v0.0.38
./pkgs/t3code/update nightly
./pkgs/t3code/update v0.0.39-nightly.20260905.1289
```

No argument selects the latest stable release, even when a nightly is currently
pinned. Explicit versions also work without the leading `v`. `nightly` resolves
to one exact version; subsequent builds never follow a moving channel.

The updater uses tools from the flake's locked nixpkgs and regenerates
`pkgs/t3code/release.nix` and `package-lock.json`. Both desktop and server
artifacts must exist for the selected version. It does not deploy, restart T3,
or install an npm-managed runtime.

Review the generated changes and build both packages before deploying:

```sh
nix build .#t3code .#t3code-server
```

Create a DNS A record for `t3code.lanice.dev` pointing to taro's tailnet address,
`100.103.16.7`. Publishing supplies the nginx proxy and ACME certificate. Clients
must join the tailnet; do not expose port 3773 or add public forwarding.

Both laptops' fleet SSH keys can log in directly:

```sh
ssh t3code@taro
```

Run the following commands in that remote Bash session. They need no sudo.
Authenticate Codex using device login, after enabling device code login in
ChatGPT's security settings or workspace permissions:

```sh
codex login --device-auth
codex login status
```

If device login is unavailable, reconnect with
`ssh -L 1455:localhost:1455 t3code@taro`, run `codex login`, and open its printed
address in the laptop's browser. Authentication belongs to `/home/t3code/.codex`,
not lanice's account. Keep login codes and credentials out of chat and logs.

Create a dedicated SSH key manually on taro before cloning private repositories
or signing commits. For unattended service use, the key must work without a
laptop's forwarded agent. A key without a passphrase gives unattended access but
is readable by every coding process running as `t3code`; limit repository
permissions accordingly.

```sh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C t3code@taro
printf '* %s\n' "$(cat ~/.ssh/id_ed25519.pub)" > ~/.ssh/allowed_signers
chmod 600 ~/.ssh/allowed_signers
```

Register only `~/.ssh/id_ed25519.pub` with the relevant forge for repository
access and SSH commit signing. Keep the private key on taro. Git uses the same
author identity and settings as lanice; commits will fail to sign until the
key is available.

Mint a separate one-time pairing link for each laptop:

```sh
t3 auth pairing create --base-dir /home/t3code/.t3 --base-url https://t3code.lanice.dev --label longjing
t3 auth pairing create --base-dir /home/t3code/.t3 --base-url https://t3code.lanice.dev --label sencha
```

Paste each generated pairing URL into that laptop's T3 remote-environment
connection flow. Do not paste tokens or URLs into chat, issues, or committed
files. Use `t3 auth --help` to inspect or revoke access later. The nginx endpoint
already supplies HTTPS; do not use `t3 pair --tailscale`, which would configure
an additional Tailscale Serve proxy.

Clone projects under `/home/t3code/workspaces`, then add those remote paths in
T3. `nix develop` works as the unprivileged account through the system Nix
daemon. T3's upstream Full access default is intentional: agents can run
commands and read or modify all state and credentials owned by `t3code`.
The account has no sudo or administrative groups.

The system service owns agent processes independently of SSH sessions and
desktop connections. From lanice's administrative login, use
`sudo systemctl status t3code` and `sudo journalctl -u t3code` for diagnostics.
Startup logs may contain pairing credentials; redact them before sharing.

References: [T3 remote access at v0.0.38](https://github.com/pingdotgg/t3code/blob/v0.0.38/docs/user/remote-access.md)
and [Codex headless authentication](https://developers.openai.com/codex/auth#login-on-headless-devices).
