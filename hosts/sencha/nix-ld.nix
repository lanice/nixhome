{pkgs, ...}: {
  programs.nix-ld = {
    enable = true;

    libraries = with pkgs; [
      rust-jemalloc-sys # Oxlint, Biome
      libgit2 # Biome
      zlib # Biome
    ];
  };
}
