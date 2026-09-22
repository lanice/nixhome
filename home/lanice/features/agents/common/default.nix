{lib, ...}: let
  skills =
    lib.mapAttrs
    (name: _: ./skills/${name})
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills));
in {
  programs = {
    claude-code.skills = skills;
    codex.skills = skills;
    omp.skills = skills;
  };
}
