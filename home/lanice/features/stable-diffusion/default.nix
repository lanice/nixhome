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
  sdLauncher = "${config.home.homeDirectory}/sd-launcher.sh";
  sdnextLauncher = "${config.home.homeDirectory}/sdnext-launcher.sh";
in {
  programs.bash = {
    shellAliases = {
      stable-diffusion = "${sdLauncher}";
      stable-diffusion-admin = "SD_ADMIN=true ${sdLauncher}";
      sdnext = "${sdnextLauncher}";
      sdnext-admin = "SD_ADMIN=true ${sdnextLauncher}";
    };

    profileExtra = ''
      ${pkgs.tmux}/bin/tmux start-server
    '';
  };

  programs.fish = {
    shellAliases = {
      stable-diffusion = "${sdLauncher}";
      stable-diffusion-admin = "SD_ADMIN=true ${sdLauncher}";
      sdnext = "${sdnextLauncher}";
      sdnext-admin = "SD_ADMIN=true ${sdnextLauncher}";
    };

    shellAbbrs = {
      sd = "sdnext";
      sda = "sdnext-admin";
    };
  };

  programs.tmux = {
    enable = true;

    extraConfig = ''
      new-session
      new-window ${sdLauncher}
    '';
  };

  home = {
    file."sd-launcher.sh".source = ./sd-launcher.sh;
    file."sdnext-launcher.sh".source = ./sdnext-launcher.sh;

    sessionVariables = {
      LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath ldLibs;
      CUDA_PATH = pkgs.cudatoolkit;
      EXTRA_LDFLAGS = "-L${pkgs.linuxPackages.nvidia_x11}/lib";
    };

    packages = with pkgs; [
      git
      python310
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
