# Dependencies to launch AUTOMATIC1111's stable-diffusion-webui, taken from: https://github.com/virchau13/automatic1111-webui-nix
# plus some extra config and helper script
{
  pkgs,
  config,
  ...
}: let
  ldLibs = with pkgs; [
    stdenv.cc.cc.lib
    stdenv.cc
    ncurses5
    linuxPackages.nvidia_x11
    libGL
    glib
  ];
in {
  systemd.user.services = {
    sdnext = {
      Unit = {
        Description = "SD.Next";
        After = "network.target";
      };
      Service = {
        # ExecStart = "${pkgs.writeShellScript "sdnext-launch" ''
        #   export COMMANDLINE_ARGS="--listen --port 9000 --insecure"
        #   source $HOME/automatic/venv/bin/activate
        #   python3 $HOME/automatic/launch.py
        # ''}";
        ExecStart = "${pkgs.writeShellScript "sdnext-launch" ''
          export COMMANDLINE_ARGS="--listen --port 9000 --insecure"
          $HOME/automatic/webui.sh
        ''}";
        WorkingDirectory = "$HOME/automatic";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };

    invoke = {
      Unit = {
        Description = "InvokeAI";
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.writeShellScript "invoke-launch" ''
          export INVOKEAI_PORT=9000
          source $HOME/invokeai/.venv/bin/activate
          invokeai-web &
        ''}";
      };
      Install = {
        WantedBy = [];
      };
    };
  };

  programs.fish = {
    shellAliases = {
      sdnext-logs = "journalctl --user -u sdnext -f | ${pkgs.ccze}/bin/ccze -A";
      sdnext-start = "systemctl --user start sdnext";
      sdnext-stop = "systemctl --user stop sdnext";

      invoke-logs = "journalctl --user -u invoke -f | ${pkgs.ccze}/bin/ccze -A";
      invoke-start = "systemctl --user start invoke";
      invoke-stop = "systemctl --user stop invoke";
    };
  };

  home = {
    file."sdnext-launcher.sh".source = ./sdnext-launcher.sh;

    sessionVariables = {
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath ldLibs;
      CUDA_PATH = pkgs.cudatoolkit;
      EXTRA_LDFLAGS = "-L${pkgs.linuxPackages.nvidia_x11}/lib";
    };

    packages = with pkgs; [
      git
      python311
      stdenv.cc.cc.lib
      stdenv.cc
      ncurses5
      binutils
      gitRepo
      gnupg
      autoconf
      curl
      procps
      gnumake
      util-linux
      m4
      gperf
      unzip
      cudatoolkit
      linuxPackages.nvidia_x11
      libGLU
      libGL
      xorg.libXi
      xorg.libXmu
      freeglut
      xorg.libXext
      xorg.libX11
      xorg.libXv
      xorg.libXrandr
      zlib
      glib
      mariadb-embedded # for the Unprompted extension
    ];
  };
}
