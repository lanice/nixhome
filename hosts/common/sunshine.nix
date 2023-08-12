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
    unitConfig = {
      Description = "Sunshine is a Game stream host for Moonlight.";
      StartLimitIntervalSec = 500;
      StartLimitBurst = 5;
    };

    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";

      ExecStart = "${config.security.wrapperDir}/sunshine";
    };
  };
}
#
# In case of problems, check sunshine status:
# systemctl --user status sunshine
# If it can't find any working encoder, manually restart, that seems to solve it:
# systemctl --user restart sunshine

