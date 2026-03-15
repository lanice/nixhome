{
  lib,
  inputs,
  config,
  ...
}: {
  imports = [inputs.nix-index-database.homeModules.nix-index] ++ (builtins.attrValues inputs.self.homeManagerModules);

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "lanice";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    sessionVariables = {
      FLAKE = "$HOME/nixhome";
    };

    # Produce a nice diff of added/removed/changed packages after home-manager switch
    # activation.report-changes = config.lib.dag.entryAnywhere ''
    #   ${pkgs.nvd}/bin/nvd diff $(ls -d1v /nix/var/nix/profiles/per-user/${config.home.username}/profile-*-link | tail -2)
    # '';
  };
}
