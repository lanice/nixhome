{
  pkgs,
  inputs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.codex = {
    enable = true;
    package = llm-agents.codex;

    context = ''
      This is a NixOS system.
    '';
  };
}
