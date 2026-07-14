{
  buildPythonPackage,
  pkg-config,
  stdenv,
  fetchzip,
  setuptools,
  numpy,
  opencv4,
  pillow,
  symlinkJoin,
}: let
  # https://github.com/invoke-ai/InvokeAI/blob/34f8117241dc961e78929bda30ce3b4f19e707cf/docs/installation/060_INSTALL_PATCHMATCH.md
  opencv4Fixed = symlinkJoin {
    name = "opencv4Fixed";
    paths = [opencv4];
    postBuild = ''
      cp -r $out/lib/pkgconfig/opencv4.pc $out/lib/pkgconfig/opencv.pc
    '';
  };
  libpatchmatch = stdenv.mkDerivation {
    name = "libpatchmatch";
    sourceRoot = ["source/patchmatch"];
    nativeBuildInputs = [
      pkg-config
      opencv4Fixed
    ];
    src = fetchzip {
      url = "https://github.com/invoke-ai/PyPatchMatch/archive/129863937a8ab37f6bbcec327c994c0f932abdbc.zip";
      sha256 = "sha256-kHYih9fjhtYfyNYzW4kwzm62N+GaOQQOOlSkO4PH3lw=";
    };

    installPhase = ''
      mkdir -p $out/lib
      cp libpatchmatch.so $out/lib/
    '';
  };
in
  buildPythonPackage {
    pname = "pypatchmatch";
    version = "129863937a8ab37f6bbcec327c994c0f932abdbc";
    pyproject = true;
    build-system = [setuptools];

    src = fetchzip {
      url = "https://github.com/invoke-ai/PyPatchMatch/archive/129863937a8ab37f6bbcec327c994c0f932abdbc.zip";
      sha256 = "sha256-kHYih9fjhtYfyNYzW4kwzm62N+GaOQQOOlSkO4PH3lw=";
    };

    propagatedBuildInputs = [
      numpy
      pillow
    ];

    doCheck = false;

    postInstall = ''
      cp ${libpatchmatch}/lib/libpatchmatch.so $out/lib/*/site-packages/patchmatch/
    '';

    meta = {
      description = "This library implements the PatchMatch based inpainting algorithm.";
      homepage = "https://github.com/invoke-ai/PyPatchMatch";
    };
  }
