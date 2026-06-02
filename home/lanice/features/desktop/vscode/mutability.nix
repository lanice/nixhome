# Make vscode settings/keybindings/snippets writable at runtime.
#
# Adapted from the gist's vscode.nix:
# https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
# The upstream version read the pre-rename top-level options
# (programs.vscode.userSettings, etc.), which now emit "Obsolete option"
# warnings. This reads from profiles.default.* instead.
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.vscode;
  profile = cfg.profiles.default;

  vscodePname = cfg.package.pname;

  configDir =
    {
      "vscode" = "Code";
      "vscode-insiders" = "Code - Insiders";
      "vscodium" = "VSCodium";
    }
    .${
      vscodePname
    };

  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/${configDir}/User"
    else "${config.xdg.configHome}/${configDir}/User";

  configFilePath = "${userDir}/settings.json";
  tasksFilePath = "${userDir}/tasks.json";
  keybindingsFilePath = "${userDir}/keybindings.json";

  snippetDir = "${userDir}/snippets";

  pathsToMakeWritable = lib.flatten [
    (lib.optional (profile.userTasks != {}) tasksFilePath)
    (lib.optional (profile.userSettings != {}) configFilePath)
    (lib.optional (profile.keybindings != []) keybindingsFilePath)
    (lib.optional (profile.globalSnippets != {})
      "${snippetDir}/global.code-snippets")
    (lib.mapAttrsToList (language: _: "${snippetDir}/${language}.json")
      profile.languageSnippets)
  ];
in {
  home.file = lib.genAttrs pathsToMakeWritable (_: {
    force = true;
    mutable = true;
  });
}
