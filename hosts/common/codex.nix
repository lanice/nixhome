{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.any (home: home.programs.codex.enable) (lib.attrValues config.home-manager.users)) {
    environment.etc."codex/config.toml".source = (pkgs.formats.toml {}).generate "codex-system-config" {
      check_for_update_on_startup = false;
      analytics.enabled = false;
      project_doc_fallback_filenames = ["CLAUDE.local.md" "CLAUDE.md"];
      agents.max_concurrent_threads_per_session = 16;
      features.hooks = true;
    };
  };
}
