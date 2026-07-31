# Vendored from nixpkgs pull request 531375 (bookorbit: init at 2.3.0),
# unmerged as of 2026-07-31. Deliberately not a URL or repo#number reference:
# either would surface this public repo on the PR's GitHub timeline.
# Delete this package (and hosts/boba/services/bookorbit/vendored-module.nix)
# once the PR lands and pkgs.bookorbit exists upstream.
{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  ffmpeg,
  makeWrapper,
}: let
  pnpm = pnpm_10;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "bookorbit";
    version = "2.3.0";
    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "bookorbit";
      repo = "bookorbit";
      tag = "v${finalAttrs.version}";
      hash = "sha256-vJNIYffdDvCnIw/jiJC+/6g6RcwrT0bIxAkOxLIzlh4=";
    };

    pnpmWorkspaces = [
      "client..."
      "server..."
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit
        (finalAttrs)
        pname
        version
        src
        pnpmWorkspaces
        ;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-c5F9ppiUB5nw+HJZXrksXutminQ47ZBvvdAjpKSGk7Q=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      ffmpeg
      makeWrapper
    ];

    # This workaround turns the `pnpmWorkspaces` array into a space-separated
    # string. This format is supported by both `pnpmConfigHook` and `pnpmBuildHook`.
    # TODO: remove this when`pnpmConfigHook` supports `___structuredAttrs = true;`
    # (nixpkgs issue 528547 — plain text to avoid a GitHub backlink)
    preConfigure = ''
      __pnpmWorkspaces="''${pnpmWorkspaces[@]}"
      unset pnpmWorkspaces
      declare -g pnpmWorkspaces="$__pnpmWorkspaces"
    '';

    postPatch =
      ''
        # Restrict optional platform-specific dependencies to the target platform.
        # Without this, pnpm resolves @parcel/watcher-darwin-x64, @parcel/watcher-win32-x64, etc.
        # during its headless install, causing network errors in the sandboxed build.
        echo "supported-architectures.os[]=${stdenv.hostPlatform.node.platform}" >> .npmrc
        echo "supported-architectures.cpu[]=${stdenv.hostPlatform.node.arch}" >> .npmrc
      ''
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        echo "supported-architectures.libc[]=${
          if stdenv.hostPlatform.isMusl
          then "musl"
          else "glibc"
        }" >> .npmrc
      '';

    buildPhase = ''
      runHook preBuild

      pnpm config set inject-workspace-packages true

      pnpm --filter client run build-only
      pnpm --filter server run build

      mkdir ./deploy
      pnpm --filter server deploy --prod ./deploy

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r deploy/* $out/lib/
      cp -r client/dist $out/lib/public
      cp -r server/src/db/migrations $out/lib/migrations

      makeWrapper ${nodejs}/bin/node $out/bin/bookorbit \
        --run "cd $out/lib" \
        --set NODE_ENV production \
        --add-flags "$out/lib/dist/main.js"

      makeWrapper ${nodejs}/bin/node $out/bin/bookorbit-migrate \
        --set NODE_ENV production \
        --add-flags "$out/lib/dist/scripts/migrate.js"

      runHook postInstall
    '';

    passthru = {
      updateScript = nix-update-script {};
    };

    meta = {
      description = "BookOrbit, self-hosted library management and reading platform for ebooks, PDFs, audiobooks, and comics.";
      homepage = "https://github.com/bookorbit/bookorbit";
      changelog = "https://github.com/bookorbit/bookorbit/releases/tag/${finalAttrs.src.tag}";
      license = lib.licenses.agpl3Only;
      mainProgram = "bookorbit";
      platforms = lib.platforms.all;
    };
  })
