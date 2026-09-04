{lib, ...}: let
  commonSkills =
    lib.mapAttrs
    (name: _: ./common/skills/${name})
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./common/skills));
in {
  imports = [
    ./claude-code
    ./codex
    ./omp
    ./t3code
  ];

  programs = {
    claude-code.skills = commonSkills;
    codex.skills = commonSkills;
    omp.skills = commonSkills;
  };
}
