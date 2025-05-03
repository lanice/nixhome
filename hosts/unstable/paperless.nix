{
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_DEBUG = false;
      PAPERLESS_OCR_LANGUAGE = "eng+deu";
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperlessx.lanice.dev";
    };
  };
}
