# nixhome

## Bootstrap

**Prerequisites:** Nix (https://nixos.org/download.html) and Git installed.

Clone the repository, then bootstrap into a flake-enabled nix-shell with home-manager enabled, and switch to your configuration:

```
git clone https://github.com/lanice/nixhome.git
cd nixhome
nix-shell
home-manager switch --flake .#<username@hostname>
```

## From There

To change home manager configurations, the bash alias `hms` maps to `home-manager switch --flake $HOME/nixhome/`.

## My hosts

- `GreenGen5`: Lenovo ThinkPad P1 Gen5 - 32GB RAM, i7 12700H, RTX A1000 | **Ubuntu** | Gnome
- `unstable`: Desktop PC - 16GB RAM, Xeon E3-1240, GTX 3060 | **Ubuntu** | Gnome
