{
  programs.zellij = {
    enable = false;

    # settings = {
    #   theme = "default";
    # };
  };

  home.file.".config/zellij/layouts/ot-frontend.kdl".source = ./ot-frontend.kdl;
}
