# lanice's macOS-only home config; imported by nix-darwin hosts (hosts/matcha)
{config, ...}: {
  # nix-darwin has no programs.nh; GC is nix.gc in the darwin host
  programs.nh = {
    enable = true;
    darwinFlake = "${config.home.homeDirectory}/nixhome";
  };

  agents.context = ''
    This is a macOS system (nix-darwin + home-manager). Userland is BSD, not GNU (e.g. `sed -i '''`).
  '';
}
