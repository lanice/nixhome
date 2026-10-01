{
  config,
  pkgs,
  inputs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.fish.shellAbbrs = {
    oc = "opencode2";
  };

  programs.opencode = {
    enable = true;
    # v2; binary is `opencode2`
    package = llm-agents.opencode2;

    inherit (config.agents) context;
  };
}
