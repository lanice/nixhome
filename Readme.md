# nixhome

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

- `sencha`: Lenovo ThinkPad P1 Gen5 - 32GB RAM, i7 12700H, RTX A1000 | **NixOS** | Gnome
- `unstable`: Desktop PC - 16GB RAM, Xeon E3-1240, GTX 3060 | **NixOS** | headless

## Use pinned pkgs version example

```nix
{
  pkgs,
  system,
  ...
}: let
  pinnedPks =
    import (builtins.fetchTarball {
      # URL to the tarball of the specific nixpkgs commit
      # Choose the right version for examplePkg using https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=examplePkg
      url = "https://github.com/NixOS/nixpkgs/archive/336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3.tar.gz";
      sha256 = "sha256:0v8vnmgw7cifsp5irib1wkc0bpxzqcarlv8mdybk6dck5m7p10lr";
    }) {
      inherit (pkgs) system;
    };

  examplePkgPinned = pinnedPks.examplePkg;
in {
  home.packages = with pkgs; [ examplePkgPinned ];
}
```

