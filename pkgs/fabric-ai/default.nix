{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule {
  pname = "fabric-ai";
  version = "1.4.12";

  src = fetchFromGitHub {
    owner = "danielmiessler";
    repo = "fabric";
    rev = "v1.4.12";
    hash = "sha256-4KOJ2Pt6ClPVzaDDOTaN/OqX0YwzI3yrtCiK82bU7rY=";
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
