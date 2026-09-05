{
  autoPatchelfHook,
  buildNpmPackage,
  fetchurl,
  jq,
  lib,
  openssl,
  stdenv,
  zlib,
}: let
  release = import ./release.nix;
in
  buildNpmPackage {
    pname = "t3code-server";
    inherit (release) version;

    src = fetchurl {
      url = "https://registry.npmjs.org/t3/-/t3-${release.version}.tgz";
      hash = release.serverHash;
    };

    # The release bundles JS; these are upstream's runtime-external roots.
    postPatch = ''
      ${lib.getExe jq} --from-file ${./runtime-package.jq} package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';

    inherit (release) npmDepsHash;
    dontNpmBuild = true;
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib openssl zlib];

    meta = {
      description = "Headless T3 Code server and administration CLI";
      homepage = "https://github.com/pingdotgg/t3code";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${release.version}";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux" "aarch64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryBytecode binaryNativeCode];
      mainProgram = "t3";
    };
  }
