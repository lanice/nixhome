# CLAUDE.md

## What This Is

NixOS + nix-darwin + home-manager flake managing 6 hosts: **sencha** (ThinkPad P1 Gen5 laptop, COSMIC desktop), **longjing** (Framework 13 laptop, COSMIC desktop), **boba** (ZimaCube homelab server), **unstable** (desktop PC homelab server), **taro** (ZimaBoard 2 homelab server), **matcha** (MacBook M1 Pro, macOS + nix-darwin). Boba, taro & unstable deployed via Colmena from sencha or longjing.

## Commands

```bash
# Update flake inputs
nix flake update

# Build (current host, no switch)
nh os build

# Build + switch (current host)
nh os switch

# matcha (on the Mac)
nh darwin switch

# Format (bare `nix fmt` fails: alejandra reads empty stdin)
nix fmt .

# Build remote host
colmena build --on <hostname/tag> [--verbose]

# Deploy remote host
colmena apply --on <hostname/tag> [--verbose]
```

Home-manager runs as a NixOS/nix-darwin module on every host. lanice's platform-specific home config lives in `home/lanice/platform/{linux,darwin}.nix`, imported next to the host file by `hosts/common/global/lanice.nix` and `hosts/matcha` (not `sharedModules`: that would reach other HM users like taro's `coding`). Coding-agent global context is `agents.context` (`modules/home-manager/agents.nix`), set per platform/host and fed to claude-code, codex, omp and opencode.

Formatter is **alejandra**. New files must be `git add`ed before any flake eval (colmena build/apply) sees them.

## Working conventions

- **Comments extremely concise.** No mannered prose.
- **Missing CLI tools:** use `nix shell nixpkgs#<pkg> -c <cmd>` or `nix run`.
- **ssh to fleet hosts** has two traps. Local fish mangles inner quotes/globs, so wrap the whole remote command in outer `"..."` (in Nix abbr strings use `''...''` so the double quotes need no escaping). The remote login shell is fish too (`hosts/common/global/lanice.nix`), so anything with loops, `$(...)`, `&&` chains or `[ ]` needs `ssh boba "bash -c '...'"` with `$` and `'` escaped inside. Simple single commands are fine bare.

## Runbooks

Operational knowledge that isn't derivable from the config lives in `docs/runbooks/`:

- `boba.md` — NIC checksum offload workaround, podman0 firewall, zfs-mount ordering, sparse media, midnight I/O window, Jellyfin client issues
- `sencha.md` — GPU thermal crashes, dock USB wedge, MX Master scroll, COSMIC audio applet, Tailscale DNS, Zen browser first run
- `matcha.md` — nix-darwin first switch, Tailscale app, SSH host key, herdr server, Tokenscope collector
- `backup-recovery.md` — restic/B2 recovery

## Agent skills

### Issue tracker

Issues and specs live as local markdown under `.scratch/<feature>/` in this repo (gitignored). See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
