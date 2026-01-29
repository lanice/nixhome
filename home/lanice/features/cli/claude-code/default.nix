{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./ralph-wiggum
  ];

  programs.claude-code = {
    enable = true;

    memory.text = ''
      ## General
      - In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

      ## Plans
      - At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.
    '';

    settings = {
      alwaysThinkingEnabled = true;
      includeCoAuthoredBy = false;
      cleanupPeriodDays = 700;

      statusLine = {
        type = "command";
        command = "input=$(cat); echo \"[$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir')\")\"";
        padding = 0;
      };
    };
  };
}
