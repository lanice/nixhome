{pkgs, ...}: {
  # Sunshine game-stream host (pair with Moonlight on the TV).
  # sencha is an Optimus laptop: the desktop is composited on the Intel iGPU and
  # the NVIDIA RTX A1000 is on PRIME render-offload. Sunshine grabs the
  # framebuffer via DRM/KMS (needs CAP_SYS_ADMIN on Wayland/COSMIC) and encodes
  # with the Intel iGPU's VA-API (Quick Sync) — the same-GPU path, so no
  # cross-GPU copy. (The A1000 has NVENC, but capturing the iGPU-composited
  # desktop and encoding on the dGPU would force a GPU->RAM->GPU copy for no win.)
  services.sunshine = {
    enable = false;
    openFirewall = true; # 47984-47990/tcp, 48010/tcp, 47998-48000/udp, 48010/udp
    capSysAdmin = true; # required for DRM/KMS screen capture under Wayland
    autoStart = true;
  };

  # Pin capture to the laptop panel (eDP-1 = "Monitor 1" in Sunshine's KMS list).
  # Without this Sunshine grabbed Monitor 0 — the external ultrawide on DP-7,
  # which is driven by the NVIDIA GPU (forcing a GPU->RAM->GPU copy) and is NOT
  # where new windows open. New apps (incl. Ryujinx) open on the primary eDP-1,
  # so that's the display the stream must show.
  services.sunshine.settings.output_name = "1";

  # Apps exposed to Moonlight. Declaring this takes over the app list: the web UI
  # app editor is locked and Sunshine's built-in defaults are replaced by exactly
  # what's below — hence the explicit Desktop tile.
  services.sunshine.applications.apps = [
    {
      name = "Desktop";
      image-path = "desktop.png";
    }
    {
      # nvidia-offload (PRIME offload wrapper, enableOffloadCmd in default.nix)
      # runs Ryujinx on the RTX A1000 instead of the Intel iGPU.
      name = "Ryujinx";
      cmd = "nvidia-offload ${pkgs.ryubing}/bin/Ryujinx";
      auto-detach = "true";
    }
  ];
}
