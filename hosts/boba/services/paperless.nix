{
  config,
  lib,
  pkgs,
  ...
}: {
  # torchcodec 0.16.0: mp3@8000Hz test_audio_against_cli tolerance failures break paperless-ngx (via sentence-transformers). Drop once fixed upstream.
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [
          (pyFinal: pyPrev: {
            torchcodec = pyPrev.torchcodec.overridePythonAttrs (old: {
              disabledTests =
                (old.disabledTests or [])
                ++ lib.optional (old.version == "0.16.0") "test_audio_against_cli";
            });
          })
        ];
    })
  ];

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;

    dataDir = "/home/paperless";
    consumptionDir = "/home/paperless/consume";

    consumptionDirIsPublic = true;

    settings = {
      PAPERLESS_DEBUG = false;
      PAPERLESS_OCR_LANGUAGE = "eng+deu";
      PAPERLESS_CSRF_TRUSTED_ORIGINS = config.homelab.published.paperless.url;
    };
  };

  homelab.published.paperless.proxyTo = config.services.paperless.port;
}
