{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
}: let
  release = import ./release.nix;
  arch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
    }
    .${
      stdenv.hostPlatform.system
    };
in
  stdenv.mkDerivation {
    pname = "t3code-server";
    inherit (release) version;

    src = fetchurl {
      url = "https://github.com/pingdotgg/t3code/releases/download/v${release.version}/t3-${release.version}-linux-${arch}.tar.gz";
      hash = release.serverHashes.${stdenv.hostPlatform.system};
    };

    # The archive also carries musl alternatives, which cannot load into its
    # glibc-linked Node executable. Keep dependency checking strict for the rest.
    postPatch = ''
      rm -rf node_modules/@ff-labs/fff-bin-linux-${arch}-musl
      rm -f node_modules/@msgpackr-extract/msgpackr-extract-linux-${arch}/*.musl.node
    '';

    dontConfigure = true;
    dontBuild = true;
    # Preserve the executable's embedded .note.node.sea payload.
    dontStrip = true;
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib];

    installPhase = ''
      runHook preInstall

      # Node resolves resources and native packages beside the real executable.
      mkdir -p "$out/libexec/t3code" "$out/bin"
      cp -a . "$out/libexec/t3code/"
      ln -s ../libexec/t3code/t3 "$out/bin/t3"

      runHook postInstall
    '';

    meta = {
      description = "Headless T3 Code server and administration CLI";
      homepage = "https://github.com/pingdotgg/t3code";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${release.version}";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux" "aarch64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "t3";
    };
  }
