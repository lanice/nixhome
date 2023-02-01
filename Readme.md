# nixhome

## Bootstrap

Nix and Git installed. https://nixos.org/download.html

Clone the repository, bootstrap into a flake-enabled nix-shell with home-manager enabled, and switch to

```
#####  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
git clone https://github.com/lanice/nixhome.git
cd nixhome
nix-shell
home-manager switch --flake .#<username@hostname>
```

## Home Manager Configuration

To build the home configuration:

```shell
nix build "github:lanice/nixhome#homeConfigurations.lanice.activationPackage"
./result/activate
```

To create a local copy and adjust it:

```shell
git clone https://github.com/lanice/nixhome.git
cd nixhome
nix build .#homeConfigurations.lanice.activationPackage
./result/activate
```

After activating the config the first time, it can be rebuilt using:

```shell
home-manager switch --flake ~/nixhome
```
