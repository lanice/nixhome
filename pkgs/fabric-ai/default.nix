{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}: let
  version = "1.4.32";
in
  buildGoModule {
    pname = "fabric-ai";
    inherit version;

    src = fetchFromGitHub {
      owner = "danielmiessler";
      repo = "fabric";
      rev = "v${version}";
      hash = "sha256-2Njlh9Sg94jNrXNRMUzAG5Y4Y0vs9Bu5sSUcatwcxOk=";
    };

    vendorHash = "sha256-uWq+S6J/RInAaQOO0T3LkpQ89mHq0Wj+wXw+Tioxy70=";

    ldflags = [
      "-s"
      "-w"
    ];

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "Fabric is an open-source framework for augmenting humans using AI. It provides a modular framework for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere";
      homepage = "https://github.com/danielmiessler/fabric";
      license = lib.licenses.mit;
      mainProgram = "fabric";
    };
  }
