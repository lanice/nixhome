{pkgs, ...}: let
  # The dock's xHCI USB controller sits behind the integrated Thunderbolt
  # switch. On surprise unplug, the kernel marks it dead and only a reboot
  # recovers it. Removing the PCIe device cleanly before unplugging avoids
  # the zombie state; replug then re-enumerates via normal PCIe hotplug.
  dockXhciPci = "0000:25:00.0";

  undock = pkgs.writeShellApplication {
    name = "undock";
    text = ''
      pci=${dockXhciPci}
      path=/sys/bus/pci/devices/$pci

      if [[ $EUID -ne 0 ]]; then
        exec sudo "$0" "$@"
      fi

      if [[ ! -e $path ]]; then
        echo "Dock xHCI ($pci) not present — nothing to do." >&2
        exit 0
      fi

      echo "Removing dock xHCI controller ($pci)…"
      echo 1 > "$path/remove"
      echo "Done. Safe to unplug the dock cable."
      echo "If USB doesn't come back on replug, run:"
      echo "  sudo sh -c 'echo 1 > /sys/bus/pci/rescan'"
    '';
  };
in {
  environment.systemPackages = [undock];
}
