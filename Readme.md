# nixhome

Bootstrap:

```console
# clone this repo to ~/nixhome
ln -s ~/nixhome ~/.config/nixpkgs
cd ~/nixhome
nix build --extra-experimental-features "nix-command flakes" .#homeConfigurations.lanice.activationPackage
./result/activate
```

Afterwards:

```console
home-manager switch --flake ~/nixhome
# aliased to
hms
```
