{
  programs.nh = {
    enable = true;
    flake = "/home/lanice/nixhome";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
}
