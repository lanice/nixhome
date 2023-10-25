{lib, ...}: {
  programs.broot = {
    enable = true;

    settings = {
      # Override default skin imports
      # imports = lib.mkForce [
      #   "verbs.hjson"
      #   {
      #     file = "dark-orange-skin.hjson";
      #     luma = ["dark" "unknown"];
      #   }
      #   {
      #     file = "white-skin.hjson";
      #     luma = "light";
      #   }
      # ];
    };
  };
}
