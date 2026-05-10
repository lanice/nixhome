{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [nixd alejandra maple-mono.NF];

  programs.zed-editor = {
    enable = true;

    extensions = ["nix" "catppuccin" "catppuccin-icons" "oxc"];

    mutableUserSettings = true;
    mutableUserKeymaps = true;

    userSettings = {
      ui_font_size = 18;
      buffer_font_size = 16;
      buffer_font_family = "Maple Mono NF";

      terminal.font_family = config.fontProfiles.monospace.family;

      autosave.after_delay.milliseconds = 1000;

      base_keymap = "VSCode";
      show_whitespaces = "all";

      minimap = {
        show = "always";
        thumb = "always";
        thumb_border = "left_open";
      };

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
