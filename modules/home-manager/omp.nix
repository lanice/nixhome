{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.omp;
  configDir = "${config.home.homeDirectory}/.omp/agent";
  yamlFormat = pkgs.formats.yaml {};

  contentType = lib.types.either lib.types.lines lib.types.path;

  mkContentEntry = path: content:
    lib.nameValuePair path (
      if lib.hm.strings.isPathLike content
      then {source = content;}
      else {text = content;}
    );

  mkSkillEntry = name: content:
    if lib.isPath content && lib.pathIsDirectory content
    then
      lib.nameValuePair "${configDir}/skills/${name}" {
        source = content;
        recursive = true;
      }
    else if lib.isPath content
    then lib.nameValuePair "${configDir}/skills/${name}/SKILL.md" {source = content;}
    else if lib.hm.strings.isPathLike content
    then
      lib.nameValuePair "${configDir}/skills/${name}" {
        source = pkgs.runCommandLocal "omp-skill-${lib.strings.sanitizeDerivationName name}" {} ''
          source=${lib.escapeShellArg "${content}"}
          if [[ -d "$source" ]]; then
            ln -s "$source" "$out"
          elif [[ -f "$source" ]]; then
            mkdir -p "$out"
            ln -s "$source" "$out/SKILL.md"
          else
            echo "OMP skill source '$source' is neither a file nor a directory" >&2
            exit 1
          fi
        '';
        recursive = true;
      }
    else
      lib.nameValuePair "${configDir}/skills/${name}/SKILL.md" {
        text = content;
      };
in {
  options.programs.omp = {
    enable = lib.mkEnableOption "Oh My Pi terminal coding agent";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "OMP package to install. Set to null to manage configuration only.";
    };

    settings = lib.mkOption {
      inherit (yamlFormat) type;
      default = {};
      description = "Configuration written to ~/.omp/agent/config.yml.";
    };

    context = lib.mkOption {
      type = contentType;
      default = "";
      description = "Global context written to ~/.omp/agent/AGENTS.md.";
    };

    rules = lib.mkOption {
      type = contentType;
      default = "";
      description = "Always-applied rules written to ~/.omp/agent/RULES.md.";
    };

    skills = lib.mkOption {
      type = lib.types.attrsOf contentType;
      default = {};
      description = ''
        OMP skills. Each attribute creates ~/.omp/agent/skills/<name> from
        inline SKILL.md content, a SKILL.md file, or a skill directory.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;

    home.file =
      lib.optionalAttrs (cfg.settings != {}) {
        "${configDir}/config.yml".source = yamlFormat.generate "omp-config.yml" cfg.settings;
      }
      // lib.optionalAttrs (cfg.context != "") (
        lib.listToAttrs [
          (mkContentEntry "${configDir}/AGENTS.md" cfg.context)
        ]
      )
      // lib.optionalAttrs (cfg.rules != "") (
        lib.listToAttrs [
          (mkContentEntry "${configDir}/RULES.md" cfg.rules)
        ]
      )
      // lib.mapAttrs' mkSkillEntry cfg.skills;
  };
}
