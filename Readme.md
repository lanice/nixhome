# nixhome

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
