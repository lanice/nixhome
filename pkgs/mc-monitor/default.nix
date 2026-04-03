{
  lib,
  pkgs,
  buildGoModule,
}: let
  pname = "mc-monitor";
  version = "0.16.1";
in
  buildGoModule {
    inherit pname version;

    src = pkgs.fetchFromGitHub {
      owner = "itzg";
      repo = pname;
      rev = version;
      hash = "sha256-/94+Z9FTFOzQHynHiJuaGFiidkOxmM0g/FIpHn+xvJM=";
    };

    vendorHash = "sha256-qq7rIpvGRi3AMnBbi8uAhiPcfSF4McIuqozdtxB5CeQ=";

    env.CGO_ENABLED = 0;

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    meta = with lib; {
      description = "Minecraft server monitor with Prometheus export and health checks";
      homepage = "https://github.com/itzg/mc-monitor";
      license = licenses.asl20;
      platforms = platforms.linux;
    };
  }
