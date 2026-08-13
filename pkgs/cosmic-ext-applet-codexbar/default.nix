{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
}: let
  pname = "cosmic-ext-applet-codexbar";
  version = "0.1.0";
in
  rustPlatform.buildRustPackage {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "andrew-verde";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-1C2LFN+YR+f/1HYR4YP/TDGvPvieWC15/8UmndHfexo=";
    };

    cargoHash = "sha256-qzZ5o6o+KIM/dHlarKRTgCiUF3hHoG8dIzUDPS1aD2I=";

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
