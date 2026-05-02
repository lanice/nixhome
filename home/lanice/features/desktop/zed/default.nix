{pkgs, ...}: {
  home.packages = [pkgs.nixd pkgs.alejandra];

  programs.zed-editor = {
    enable = true;

    extensions = ["nix" "catppuccin" "catppuccin-icons"];

    mutableUserSettings = true;
    mutableUserKeymaps = true;

    userSettings = {
      ui_font_size = 18;
      buffer_font_size = 18;

      autosave.after_delay.milliseconds = 1000;

      base_keymap = "VSCode";
      show_whitespaces = "all";

      languages.Nix = {
        language_servers = ["nixd" "!nil"];
        formatter = {
          external = {
            command = "alejandra";
            arguments = ["-q"];
          };
        };
      };
    };

    userKeymaps = [
      {
        context = "Editor && mode == full";
        unbind = {
          ctrl-alt-shift-down = "editor::DuplicateLineDown";
          ctrl-alt-shift-up = "editor::DuplicateLineUp";

          alt-down = "editor::MoveLineDown";
          alt-up = "editor::MoveLineUp";
        };
        bindings = {
          ctrl-enter = "editor::NewlineBelow";
          ctrl-shift-enter = "editor::NewlineAbove";

          ctrl-shift-down = "editor::MoveLineDown";
          ctrl-shift-up = "editor::MoveLineUp";

          ctrl-shift-d = "editor::DuplicateLineDown";
        };
      }
      {
        context = "!AcpThread > Editor && mode == full";
        unbind = {
          ctrl-enter = "assistant::InlineAssist";
        };
      }
    ];
  };
}
