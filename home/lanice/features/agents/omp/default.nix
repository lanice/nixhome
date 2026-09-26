{
  config,
  inputs,
  pkgs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.omp = {
    enable = true;
    package = llm-agents.omp;

    inherit (config.agents) context;
    rules = ./RULES.md;
  };
}
