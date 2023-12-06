{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/apng" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/webp" = "imv.desktop";

      "video/mp4" = "mpv.desktop";
      "video/mpv" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";

      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";

      "x-scheme-handler/mailto" = "thunderbird.desktop";
    };

    associations.removed = {
      "application/pdf" = "gimp.desktop";
    };
  };

  # See https://github.com/nix-community/home-manager/issues/1213
  xdg.configFile."mimeapps.list".force = true;
}
