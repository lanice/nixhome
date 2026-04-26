{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server

    protontricks.enable = true;
  };

  # environment.systemPackages = with pkgs; [steam-tui steamcmd];
  programs.gamemode.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
    env = {
      LD_LIBRARY_PATH = "/run/opengl-driver/lib:${pkgs.libglvnd}/lib";
    };
  };
}
