{
  inputs,
  pkgs,
  ...
}: let
  # Reject AI co-author trailers (agents ignore attribution settings sometimes)
  noAiCoauthor = pkgs.writeShellScript "no-ai-coauthor" ''
    if ${pkgs.gnugrep}/bin/grep -qiE '^co-authored-by:.*(claude|anthropic)' "$1"; then
      echo "commit-msg: remove the Claude/Anthropic Co-Authored-By trailer" >&2
      exit 1
    fi
  '';
in {
  programs.git = {
    enable = true;
    signing.format = "ssh";

    settings = {
      user = {
        name = "Leander Neiss";
        email = (import (inputs.nixhome-private + "/contacts.nix")).github;
        signingkey = "~/.ssh/id_ed25519.pub";
      };

      alias = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        co = "checkout";
        file-history = "!f() { git lg --full-history -- $1; }; f";
      };

      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      commit.gpgsign = true;
      gpg.format = "ssh";
      # Populate manually with: * <content of id_ed25519.pub>
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      push.autoSetupRemote = true;

      # Config-based hook: runs alongside repo-local .git/hooks
      hook.no-ai-coauthor = {
        event = "commit-msg";
        command = "${noAiCoauthor}";
      };
    };
  };
}
