{
  appimageTools,
  fetchurl,
  lib,
}: let
  pname = "t3code";
  version = "0.0.38";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-HxzNkisu+v/VBEewKO4NbiUlUCkFCHz4rj/kHv6+NG8=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPreBwrapCmds = ''
      export T3CODE_DISABLE_AUTO_UPDATE=1
    '';

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/t3code.desktop $out/share/applications/t3code.desktop
      substituteInPlace $out/share/applications/t3code.desktop \
        --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=t3code %U"
      cp -r ${appimageContents}/usr/share/icons $out/share/
    '';

    meta = {
      description = "Agentic coding desktop application";
      homepage = "https://github.com/pingdotgg/t3code";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
      downloadPage = "https://github.com/pingdotgg/t3code/releases";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "t3code";
    };
  }
