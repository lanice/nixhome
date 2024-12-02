{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "GoMono Nerd Font Mono";
      package = pkgs.nerd-fonts.go-mono;
    };
    serif = {
      family = "Iosevka Etoile";
      package = pkgs.iosevka-bin.override {variant = "Etoile";};
    };
    sansSerif = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
    emoji = {
      family = "Noto Color Emoji";
      package = pkgs.noto-fonts-emoji-blob-bin;
    };
  };
}
