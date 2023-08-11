{
  pkgs,
  config,
  ...
}: {
  boot.kernelModules = ["uinput"];

  services.udev.enable = true;
  services.udev.extraRules = ''
    # Your rule goes here
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  security.wrappers = {
    sunshine = {
      source = "${pkgs.sunshine}/bin/sunshine";
      capabilities = "cap_sys_admin+ep";
      owner = "root";
      group = "root";
    };
  };

  systemd.user.services.sunshine = {
    # script = "/run/current-system/sw/bin/env /run/wrappers/bin/sunshine";

    unitConfig = {
      Description = "Sunshine is a Game stream host for Moonlight.";
      StartLimitIntervalSec = 500;
      StartLimitBurst = 5;
    };

    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      # Environment = "WAYLAND_DISPLAY=wayland-1";
      # auto restart
      # Restart = "on-failure";
      # RestartSec = "5s";

      ExecStart = "${config.security.wrapperDir}/sunshine";

      # ExecStart = pkgs.writeShellScript "sunshine" ''
      #   . /etc/set-environment
      #   ${config.security.wrapperDir}/sunshine
      # '';
      RestartSec = 3;
      Restart = "always";

      # DeviceAllow = pkgs.lib.mkForce ["char-drm rw" "char-nvidia-frontend rw" "char-nvidia-uvm rw"];
      # PrivateDevices = pkgs.lib.mkForce false;
      # RestrictAddressFamilies = pkgs.lib.mkForce ["AF_UNIX" "AF_NETLINK" "AF_INET" "AF_INET6"];
    };
  };
}
