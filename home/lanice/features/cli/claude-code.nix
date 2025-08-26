{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [pkgs.claude-code];

  # home.file.".claude/settings.json".text = ''
  #   {
  #     "cleanupPeriodDays": 700,
  #     "includeCoAuthoredBy": false
  #   }
  # '';
}
