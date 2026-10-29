{
  lib,
  inputs,
  ...
}: let
  skills =
    lib.mapAttrs
    (name: _: ./skills/${name})
    (lib.filterAttrs (name: type: type == "directory" && !(lib.hasPrefix "_" name)) (builtins.readDir ./skills))
    // {
      screencast = "${inputs.lanice-skills}/skills/dev/screencast";
    };
in {
  programs = {
    claude-code.skills = skills;
    codex.skills = skills;
    omp.skills = skills;
    opencode.skills = skills;
    pi-coding-agent.skills = skills;
  };
}
