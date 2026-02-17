# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

NixOS + home-manager flake managing 3 hosts: **sencha** (ThinkPad laptop, GNOME desktop), **boba** (ZimaCube homelab server), **unstable** (desktop PC homelab server). Boba & unstable deployed via Colmena from sencha.

## Commands

```bash
# Update flake inputs
nix flake update                                 # or: nfu

# Build (current host, no switch)
nixos-rebuild --flake . build                    # or: nrb

# Build + switch (current host)
sudo nixos-rebuild --flake . switch              # or: snrs

# Format
nix fmt

# Build remote host
colmena build --on <hostname> [--verbose]

# Deploy remote host
colmena apply --on <hostname> [--verbose]
```

Formatter is **alejandra**.

## Architecture

### Hosts (`hosts/`)
- `hosts/common/global/` — shared NixOS config (nix settings, users, fish, tailscale, boot)
- `hosts/<hostname>/` — per-host system config + hardware
- `hosts/boba/services/` — 20+ self-hosted services behind nginx reverse proxy on `*.lanice.dev`

### Home-manager (`home/lanice/`)
- `global/` — shared home config across all hosts
- `features/cli/` — shell (fish primary), editors (helix default), dev tools, git
- `features/desktop/` — GUI apps (firefox, ghostty, vscode, gnome)
- `themes/` — catppuccin frappe (dark) / latte (light)
- Per-host entry points: `sencha.nix` (full desktop), `boba.nix` / `unstable.nix` (minimal CLI)

### Custom modules (`modules/home-manager/`)
Font profiles and theme polarity (light/dark) options.

### Packages (`pkgs/`)
Custom nix packages (dirstat-rs). Exported via `self.packages`.

### Secrets (`secrets/`)
Age-encrypted via agenix. Keys mapped in `secrets/secrets.nix` with per-host access control.

## Key Patterns

- All flake inputs follow nixpkgs (unstable channel) for consistency
- Feature-based modularity: hosts import feature sets, not individual tools
- Theme system: import a theme from `themes/` to set `theme.polarity` ("dark"/"light"); theme-aware modules check `config.theme.polarity`
- Fish abbreviations define most CLI shortcuts (see `features/cli/fish.nix`)
- Services on boba run behind nginx with ACME/Porkbun DNS for `*.lanice.dev`
