{pkgs, ...}: {
  home.packages = [pkgs.distrobox];

  # https://github.com/nix-community/home-manager/issues/4430#issuecomment-1732681618
  home.file.".config/distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro /etc/static/profiles/per-user:/etc/profiles/per-user:ro"
  '';
}
