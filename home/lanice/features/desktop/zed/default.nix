{lib, ...}: {
  programs.zed-editor = let
    themeData = builtins.fromJSON (builtins.readFile ./tailwind-css-theme.json);
  in {
    enable = true;
    themes = builtins.listToAttrs (map (theme: {
        name = builtins.replaceStrings [" " "(" ")"] ["-" "" ""] (lib.strings.toLower theme.name);
        value = theme;
      })
      themeData.themes);
  };
}
