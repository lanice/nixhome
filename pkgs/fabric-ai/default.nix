{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}: let
  version = "1.4.69";
in
  buildGoModule {
    pname = "fabric-ai";
    inherit version;

    src = fetchFromGitHub {
      owner = "danielmiessler";
      repo = "fabric";
      rev = "v${version}";
      hash = "sha256-YIsyV5sQ6Z5GAqnDhkM0RFP4hCzqMO4w+N1mv96URY0=";
    };

    vendorHash = "sha256-/nQj0T52xT3MGyM7hsPvvncXlZWjbjA2NBCisidgoWY=";

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
