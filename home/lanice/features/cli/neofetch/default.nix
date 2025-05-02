{pkgs, ...}: {
  home.packages = [pkgs.fastfetch];
  # home.file.".config/neofetch/config.conf".source = ./config.conf;

  programs.fish.shellAliases = {
    neofetch = "${pkgs.fastfetch}/bin/fastfetch";
  };
}
