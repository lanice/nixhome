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
  pypatchmatch = pkgs.python311Packages.callPackage ./pypatchmatch {};
  nixShellWithPyPatchMatch = pkgs.writeText "shell.nix" ''
    {pkgs ? import <nixpkgs> {}}: pkgs.mkShell { buildInputs = [${pypatchmatch}]; }
  '';
in {
  systemd.user.services = {
    sdnext = {
      Unit = {
        Description = "SD.Next";
        After = "network.target";
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "sdnext-launch" ''
          export COMMANDLINE_ARGS="--listen --port 9000 --insecure"
          ${pkgs.bash}/bin/bash -lc $HOME/automatic/webui-override.sh
        ''}";
        WorkingDirectory = "/home/lanice/automatic";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };

    invoke = {
      Unit = {
        Description = "InvokeAI";
        After = [
          "network.target"
          "systemd-udev-settle.service"
          "systemd-user-sessions.service" # Ensure user session is ready
        ];
        Wants = ["systemd-udev-settle.service"];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "invoke-launch" ''
          export INVOKEAI_PORT=9001
          source $HOME/invokeai/.venv/bin/activate
          # ${pkgs.nix}/bin/nix-shell ${nixShellWithPyPatchMatch}
          # ${pkgs.nix}/bin/nix-shell ${nixShellWithPyPatchMatch} --run "distrobox-enter invokebox -e invokeai-web"
          distrobox-enter invokebox -e invokeai-web
        ''}";
        # ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";

        # Restart on failure
        Restart = "on-failure";
        # Wait 5 seconds before restart
        RestartSec = 5;
        # Maximum number of restart attempts within the time window
        StartLimitBurst = 5;
        # Time window for restart attempts (in seconds)
        StartLimitIntervalSec = 30;
      };
      Install = {
        WantedBy = ["default.target"];
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
      python3
      uv
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
