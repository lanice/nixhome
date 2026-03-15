{pkgs, ...}: {
  home.packages = with pkgs; [
    yarn
    bun
    nodejs_24
    pnpm
    biome
    deno
  ];
}
