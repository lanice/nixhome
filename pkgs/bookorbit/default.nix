# Vendored from the unmerged nixpkgs BookOrbit package/module PR, last synced
# 2026-08-24, then advanced locally from the PR's 2.6.0 to 2.7.0. Deliberately
# not a URL or repo#number reference: either would surface this public repo on
# the PR's GitHub timeline.
# Delete this package (and hosts/boba/services/bookorbit/vendored-module.nix)
# once the PR lands and pkgs.bookorbit exists upstream.
{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nodejs,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  ffmpeg,
  makeWrapper,
}: let
  pnpm = pnpm_11;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "bookorbit";
    version = "2.7.0";
    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "bookorbit";
      repo = "bookorbit";
      # Upstream repointed every v2.3.0-v2.7.0 tag to this commit. Pin the
      # object, not the mutable tag, so the fixed-output source stays stable.
      rev = "7668f46c42bba6d9f91fd8fada2774e50b5ff876";
      hash = "sha256-p75+BQVBm4zi/yeF73B/NSoG9+8wwjxNPumYI7mRFZE=";
    };
    patches = [./koreader-plugin-origin.patch];

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
      fetcherVersion = 4;
      hash = "sha256-3jPKAZFMu8eC4IAakQ/6f6tAxJJ3Ar/4yhZhShL4MeE=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      ffmpeg
      makeWrapper
    ];

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

      pnpm --filter client run build-only
      pnpm --filter server run build

      runHook postBuild
    '';
    doCheck = true;
    checkPhase = ''
      runHook preCheck

      pnpm --filter server exec vitest run \
        src/config/config.test.ts \
        src/modules/koreader/koreader-package.service.test.ts
      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      pnpm --filter server \
        --config.inject-workspace-packages=true \
        --prod \
        deploy $out/lib
      cp -r client/dist $out/lib/public
      cp -r server/src/db/migrations $out/lib/migrations
      cp -r koreader-plugin $out/lib/koreader-plugin

      makeWrapper ${nodejs}/bin/node $out/bin/bookorbit \
        --run "cd $out/lib" \
        --set NODE_ENV production \
        --set APP_VERSION ${finalAttrs.version} \
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
      changelog = "https://github.com/bookorbit/bookorbit/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.agpl3Only;
      mainProgram = "bookorbit";
      platforms = lib.platforms.all;
    };
  })
