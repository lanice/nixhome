{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [pkgs.claude-code];

  home.file.".claude/CLAUDE.md".text = ''
    ## General
    - In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

    ## Plans
    - At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.
  '';
}
