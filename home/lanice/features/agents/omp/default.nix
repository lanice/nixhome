{
  inputs,
  pkgs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.omp = {
    enable = true;
    package = llm-agents.omp;

    context = ./AGENTS.md;
    rules = ./RULES.md;

    skills = {
      frontend-design = ../common/skills/frontend-design;
      unslop = ../common/skills/unslop;
    };
  };
}
