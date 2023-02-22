# nixhome

This config is based on [Misterio77's starter config](https://github.com/Misterio77/nix-starter-configs) and their own [NixOS configuration](https://github.com/Misterio77/nix-config).

## Bootstrap

### NixOS

Execute `nix-shell -p git` to enter a nix shell with git available. From there:

```bash
git clone https://github.com/lanice/nixhome.git
cd nixhome
nix-shell # Enter the provided flake-enabled nix shell to bootstrap nixos and home-manager
cp /etc/nixos/hardware-configuration.nix hosts/<hostname>/hardware-configuration.nix # Make sure you use the nixos-generated hardware config
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<username>@<hostname>
```

Reboot, done.

### Non-NixOS

**Prerequisites:** Nix (https://nixos.org/download.html) installed.

Execute `nix-shell -p git` to enter a nix shell with git available. From there:

```bash
git clone https://github.com/lanice/nixhome.git
cd nixhome
nix-shell # Enter the provided flake-enabled nix shell to bootstrap home-manager
home-manager switch --flake .#<username>@<hostname>
```

## Hosts

- `GreenGen5`: Lenovo ThinkPad P1 Gen5 - 32GB RAM, i7 12700H, RTX A1000 | **Ubuntu** | Gnome
- `unstable`: Desktop PC - 16GB RAM, Xeon E3-1240, GTX 3060 | **NixOS** | headless

## Useful aliases provided by the HM configuration

- `hm` → `home-manager`
- `hms` → `home-manager switch --flake $HOME/nixhome/`
