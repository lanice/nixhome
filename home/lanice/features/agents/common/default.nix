{lib, ...}: let
  skills =
    lib.mapAttrs
    (name: _: ./skills/${name})
    (lib.filterAttrs (name: type: type == "directory" && !(lib.hasPrefix "_" name)) (builtins.readDir ./skills));
in {
  programs = {
    claude-code.skills = skills;
    codex.skills = skills;
    omp.skills = skills;
    opencode.skills = skills;
    pi-coding-agent.skills = skills;
  };
}
