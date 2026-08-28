{
  config,
  pkgs,
  ...
}: {
  services.stirling-pdf = {
    enable = true;

    # 2.14.3 test suite fails on expired bundled test certs (CertificateExpiredException);
    # runtime is unaffected. Drop once nixpkgs fixes it.
    package = pkgs.stirling-pdf.overrideAttrs {doCheck = false;};

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
