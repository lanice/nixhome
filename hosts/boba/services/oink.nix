{
  inputs,
  config,
  ...
}: {
  age.secrets.porkbunApiKey.file = "${inputs.self}/secrets/porkbunApiKey.age";
  age.secrets.porkbunSecretApiKey.file = "${inputs.self}/secrets/porkbunSecretApiKey.age";

  services.oink = {
    enable = true;

    apiKeyFile = config.age.secrets.porkbunApiKey.path;
    secretApiKeyFile = config.age.secrets.porkbunSecretApiKey.path;

    # Minecraft is reached over a raw public port, not published as a subdomain,
    # so it needs its own DNS record here rather than an nginx vhost.
    domains = [
      {
        domain = config.homelab.defaultDomain;
        subdomain = "minecraft";
      }
    ];
  };
}
