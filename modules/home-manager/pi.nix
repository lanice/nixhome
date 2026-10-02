{
  config,
  lib,
  ...
}: let
  cfg = config.programs.pi-coding-agent;

  mkSkillEntry = name: source:
    if lib.pathIsDirectory source
    then
      lib.nameValuePair "${cfg.configDir}/skills/${name}" {
        inherit source;
        recursive = true;
      }
    else lib.nameValuePair "${cfg.configDir}/skills/${name}/SKILL.md" {inherit source;};
in {
  # Extends Home Manager's pi-coding-agent module with skills.
  options.programs.pi-coding-agent.skills = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = {};
    description = ''
      Pi skills. Each attribute links <configDir>/skills/<name> from a skill
      directory or a SKILL.md file. Per-file links keep the directory writable.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mapAttrs' mkSkillEntry cfg.skills;
  };
}
