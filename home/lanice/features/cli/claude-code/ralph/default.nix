{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "ralph-once" (builtins.readFile ./ralph-once.sh))
    (pkgs.writeShellScriptBin "ralph-afk" (builtins.readFile ./ralph-afk.sh))
  ];
}
