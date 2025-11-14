{
  inputs,
  config,
  ...
}: {
  age.secrets.porkbunApiKey.file = "${inputs.self}/secrets/porkbunApiKey.age";
  age.secrets.porkbunSecretApiKey.file = "${inputs.self}/secrets/porkbunSecretApiKey.age";

  services.oink = {
    enable = false;

    apiKeyFile = config.age.secrets.porkbunApiKey.path;
    secretApiKeyFile = config.age.secrets.porkbunSecretApiKey.path;

    domains = [
      {
        domain = "lanice.dev";
        subdomain = "minecraft";
      }
    ];
  };
}
