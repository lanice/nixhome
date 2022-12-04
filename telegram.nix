{pkgs}: let
  wrapped =
    pkgs.writeShellScriptBin "telegram-desktop"
    ''
      ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.tdesktop}/bin/telegram-desktop
    '';
in
  pkgs.symlinkJoin {
    name = "telegram-desktop";
    paths = [
      wrapped
      pkgs.tdesktop
    ];
  }
