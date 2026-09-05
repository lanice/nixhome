{pkgs, ...}: {
  home.packages = with pkgs; [
    bun
    nodejs
    pnpm
    biome
    deno
  ];
}
