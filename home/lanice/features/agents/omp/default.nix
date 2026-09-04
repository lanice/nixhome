{
  inputs,
  pkgs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [llm-agents.omp];
  home.file.".omp/agent/RULES.md".source = ./RULES.md;
  home.file.".omp/agent/AGENTS.md".source = ./AGENTS.md;
}
