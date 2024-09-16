{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}: let
  version = "1.4.17";
in
  buildGoModule {
    pname = "fabric-ai";
    inherit version;

    src = fetchFromGitHub {
      owner = "danielmiessler";
      repo = "fabric";
      rev = "v${version}";
      hash = "sha256-oH4HL2QQnX8f4w5YFP8XSQGg2tMkJex+mJHpu2Rtl8M=";
    };

    vendorHash = "sha256-CHgeHumWtNt8SrbzzCWqBdLxTmmyDD2bfLkriPeez2E=";

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
