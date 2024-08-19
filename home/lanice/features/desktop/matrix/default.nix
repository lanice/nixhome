{pkgs, ...}: {
  programs.nheko = {
    enable = true;
  };

  home.packages = with pkgs; [
    cinny-desktop
  ];
}
