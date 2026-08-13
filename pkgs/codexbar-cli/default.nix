{
  lib,
  stdenvNoCC,
  fetchurl,
}: let
  pname = "codexbar-cli";
  version = "0.49.4";
in
  # Prebuilt static musl binary; the upstream CLI is Swift, which is not
  # practical to build from source with nixpkgs. The nixpkgs `codexbar`
  # package is the macOS menu-bar app (aarch64-darwin only).
  stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/steipete/CodexBar/releases/download/v${version}/CodexBarCLI-v${version}-linux-musl-x86_64.tar.gz";
      hash = "sha256-OoaH4V+TkeGZn/1t4aDdhoon4ofyAULgcWIaqzrqwrg=";
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      # Swift locates the resource bundle next to the real executable
      # (via /proc/self/exe), so keep them together under libexec.
      mkdir -p $out/libexec $out/bin
      cp CodexBarCLI $out/libexec/
      cp -r CodexBar_CodexBarCore.bundle $out/libexec/
      cp VERSION $out/libexec/
      ln -s ../libexec/CodexBarCLI $out/bin/codexbar

      runHook postInstall
    '';

    meta = with lib; {
      description = "CLI reporting usage stats and limits for AI coding providers (Claude Code, Codex, ...)";
      homepage = "https://github.com/steipete/CodexBar";
      license = licenses.mit;
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      mainProgram = "codexbar";
      maintainers = with maintainers; [lanice];
    };
  }
