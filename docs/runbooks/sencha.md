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
