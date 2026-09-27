# matcha runbook

MacBook M1 Pro, macOS + nix-darwin (`hosts/matcha`). Bootstrap steps are in
the README. Nothing here has been exercised yet; correct it on first contact.

## First switch

nix-darwin aborts activation if the Nix installer left unmanaged files in
`/etc` (`nix/nix.conf`, `zshrc`, `bashrc`). Rename each to
`<name>.before-nix-darwin` as the error says, then switch again.

The login shell comes from `users.knownUsers`, which needs uid 501 (the first
macOS account). On a different uid activation warns and skips the user; fix
`uid` in `hosts/matcha/default.nix`.

## Tailscale

The Standalone app comes from the `tailscale-app` Homebrew cask. First launch:
approve the network extension in System Settings → Privacy & Security, log in,
and make sure the machine is named `matcha` in the admin console.

## Ghostty hotkey

`opt+enter` (global keybind, `home/lanice/matcha.nix`) needs System Settings →
Privacy & Security → Accessibility → Ghostty. Grant once; the copied app keeps
its signature, so the grant survives switches.

## Tinycast

Third-party tap. nix-darwin marks casks `trusted: true`; if the switch still
fails on it, run `brew trust --tap abue-ammar/tinycast` once. The app is
self-signed; if macOS blocks it, run
`xattr -dr com.apple.quarantine /Applications/Tinycast.app`. For Cmd+Space,
first disable Spotlight's shortcut (System Settings → Keyboard → Keyboard
Shortcuts → Spotlight).

## SSH trust

Remote Login is on (`services.openssh`), keys only, for sencha and longjing.
The host key is macOS's own. After the first boot, add it to `hosts/fleet.nix`
(`hosts.matcha.hostKey`, from `/etc/ssh/ssh_host_ed25519_key.pub`) and to
`hosts/common/fleet-ssh.nix`, so workstations don't prompt trust-on-first-use.

## Herdr server

No service: the first `herdr` connection starts the server over SSH, and
herdr detaches it itself (`setsid` plus the per-user launchd bootstrap
context, like tmux), so it survives SSH drops. A launchd agent is worse:
launchd children aren't session leaders, so herdr asks to "restart" them,
and `KeepAlive` fights herdr's own restarts and update handoffs.

Register once from longjing (or sencha):

```sh
herdr machine add matcha --label Matcha
```

After a reboot the server is gone until the next connection starts it. A
closed lid sleeps the Mac and drops the connection; panes resume on wake.

## Tokenscope collector

`hosts/common/tokenscope-collector-darwin.nix` runs launchd daemons
`org.nixos.tokenscope-collect-{claude,codex}` as lanice, with the same flags,
state paths and token scheme as the NixOS collector ([boba.md](boba.md#tokenscope-collection-and-project-assignments)).
Differences: no sandboxing; the agenix token (`/run/agenix/tokenscopeMatcha`)
is owned by lanice; each daemon runs at load (boot, switch) and on the hour,
including once on wake for a slot missed asleep; failures retry after at least
15 minutes. Logs: `/var/log/tokenscope/<tool>.log`, rotated by newsyslog.

Ingestion needs a `{"host":"matcha","token":...}` entry in the server grants.
The token lives only in `secrets/tokenscopeMatcha.age`; copy it over from an
admin host (sencha/longjing):

```sh
cd secrets
agenix -d tokenscopeMatcha.age   # token
agenix -e tokenscopeGrants.age   # add the matcha entry
colmena apply --on boba
```

```sh
sudo launchctl print system/org.nixos.tokenscope-collect-codex
sudo launchctl kickstart -k system/org.nixos.tokenscope-collect-codex
tail /var/log/tokenscope/codex.log
```
