{config, ...}: let
  light = true;
  syntax-theme =
    if light
    then "GitHub"
    else "1337";
  gh-dash-theme =
    if light
    then {
      # https://github.com/catppuccin/gh-dash/blob/main/themes/latte/catppuccin-latte-mauve.yml
      colors = {
        text = {
          primary = "#4c4f69";
          secondary = "#8839ef";
          inverted = "#dce0e8";
          faint = "#5c5f77";
          warning = "#d20f39";
          success = "#40a02b";
        };
        background = {selected = "#ccd0da";};
        border = {
          primary = "#7287fd";
          secondary = "#bcc0cc";
          faint = "#ccd0da";
        };
      };
    }
    else {
      # https://github.com/catppuccin/gh-dash/blob/main/themes/frappe/catppuccin-frappe-green.yml
      colors = {
        text = {
          primary = "#c6d0f5";
          secondary = "#a6d189";
          inverted = "#232634";
          faint = "#b5bfe2";
          warning = "#e78284";
          success = "#a6d189";
        };
        background = {selected = "#414559";};
        border = {
          primary = "#a6d189";
          secondary = "#51576d";
          faint = "#414559";
        };
      };
    };
in {
  programs.git = {
    enable = true;
    userName = "Leander Neiss";
    userEmail = "1871704+lanice@users.noreply.github.com";

    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      file-history = "!f() { git lg --full-history -- $1; }; f";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = false;
        syntax-theme = syntax-theme;
        light = light;
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      commit.gpgsign = true;
      gpg.format = "ssh";
      # Need to make sure ~/.ssh/allowed_signers exists and contains:
      # * <content of id_ed25519.pub>
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };

  programs.gh.enable = true;
  programs.gh-dash = {
    enable = true;
    settings = {
      theme = gh-dash-theme;
    };
  };
}
