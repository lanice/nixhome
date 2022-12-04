{
  pkgs,
  targetPkg,
  name,
}:
pkgs.symlinkJoin {
  inherit name;
  paths = [
    (pkgs.writeShellScriptBin name
      ''
        ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${targetPkg}/bin/${name}
      '')
    targetPkg
  ];
}
