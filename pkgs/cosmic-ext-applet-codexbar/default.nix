{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
}: let
  pname = "cosmic-ext-applet-codexbar";
  version = "0.2.1";
in
  rustPlatform.buildRustPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "andrew-verde";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-TS3/e1/vGXhWivxh85LQZ2sEz9fUIrgi0uwJFRoIyxM=";
    };

    cargoHash = "sha256-JkCpJoKJFusiByAmCc5sn0tlqq5e0SO8Fqd9Fbj7JT8=";

    nativeBuildInputs = [just libcosmicAppHook];

    dontUseJustBuild = true;
    dontUseJustCheck = true;

    # Layout regression tests measure rendered text width and fail
    # without the fonts they expect available in the sandbox.
    doCheck = false;

    justFlags = [
      "--set"
      "prefix"
      (placeholder "out")
      "--set"
      "targetdir"
      "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
    ];

    meta = with lib; {
      description = "COSMIC panel applet showing AI coding-assistant usage limits via the CodexBar CLI";
      homepage = "https://github.com/andrew-verde/cosmic-ext-applet-codexbar";
      license = licenses.mit;
      platforms = platforms.linux;
      mainProgram = pname;
      maintainers = with maintainers; [lanice];
    };
  }
