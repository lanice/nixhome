# CLAUDE.md

## What This Is

NixOS + home-manager flake managing 3 hosts: **sencha** (ThinkPad laptop, COSMIC desktop), **boba** (ZimaCube homelab server), **unstable** (desktop PC homelab server). Boba & unstable deployed via Colmena from sencha.

## Commands

```bash
# Update flake inputs
nix flake update                  # or: nfu

# Build (current host, no switch)
nh os build                       # or: nrb

# Build + switch (current host)
nh os switch                      # or: snrs

# Format
nix fmt

# Build remote host
colmena build --on <hostname> [--verbose]

# Deploy remote host
colmena apply --on <hostname> [--verbose]
```

Formatter is **alejandra**.
