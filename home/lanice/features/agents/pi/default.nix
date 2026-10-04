{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  # settings/keybindings/models stay unset: pi rewrites those files itself.
  programs.pi-coding-agent = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isLinux
      then
        pkgs.symlinkJoin {
          name = "pi-with-native-libs-${llm-agents.pi.version}";
          paths = [llm-agents.pi];
          nativeBuildInputs = [pkgs.makeWrapper];
          # Native Node addons bypass nix-ld.
          postBuild = ''
            wrapProgram "$out/bin/pi" \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]}"
          '';
          inherit (llm-agents.pi) meta;
        }
      else llm-agents.pi;
    # npm for `pi install npm:...`.
    extraPackages = [pkgs.nodejs];

    inherit (config.agents) context;
  };
}
