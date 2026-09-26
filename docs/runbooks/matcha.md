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
