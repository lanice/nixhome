# CLAUDE.md

## What This Is

NixOS + home-manager flake managing 4 hosts: **sencha** (ThinkPad laptop, COSMIC desktop), **boba** (ZimaCube homelab server), **unstable** (desktop PC homelab server), **taro** (ZimaBoard 2 homelab server). Boba, taro & unstable deployed via Colmena from sencha.

## Commands

```bash
# Update flake inputs
nix flake update

# Build (current host, no switch)
nh os build

# Build + switch (current host)
nh os switch

# Format
nix fmt

# Build remote host
colmena build --on <hostname> [--verbose]

# Deploy remote host
colmena apply --on <hostname> [--verbose]
```

Formatter is **alejandra**.

## Agent skills

### Issue tracker

Issues and specs live as local markdown under `.scratch/<feature>/` in this repo (gitignored). See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
