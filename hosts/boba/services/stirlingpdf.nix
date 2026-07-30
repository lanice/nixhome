{config, ...}: {
  services.stirling-pdf = {
    enable = true;

    environment = {
      SERVER_PORT = 8090;
    };
  };

  homelab.published.stirlingpdf = {
    subdomain = "pdf";
    # environment values may be str, int or bool; SERVER_PORT is set as an int
    # above, so quoting it there would fail this option's port type check.
    proxyTo = config.services.stirling-pdf.environment.SERVER_PORT;
  };
}
