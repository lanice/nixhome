{
  lib,
  pkgs,
  rustPlatform,
}: let
  pname = "dirstat-rs";
  version = "v0.3.7";
in
  rustPlatform.buildRustPackage {
    inherit pname;
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "scullionw";
      repo = pname;
      rev = version;
      sha256 = "sha256-gDIUYhc+GWbQsn5DihnBJdOJ45zdwm24J2ZD2jEwGyE=";
    };

    cargoHash = "sha256-SdxTiIrsK3U4mcrcilOhMkkp12yEUkWlXmlT+C75dZw=";

    meta = with lib; {
      description = "Fast, cross-platform disk usage CLI";
      homepage = "https://github.com/scullionw/dirstat-rs";
      license = licenses.mit;
      platforms = platforms.all;
      maintainers = with maintainers; [lanice];
    };
  }
