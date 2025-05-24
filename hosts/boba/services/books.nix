{
  inputs,
  config,
  ...
}: {
  systemd.tmpfiles.rules = [
    "d /home/books 777 - - - -"
    "d /home/books/RPG 777 - multimedia - -"
  ];

  age.secrets.kavitaKey.file = "${inputs.self}/secrets/kavitakey.age";

  services.komga = {
    enable = true;
    group = "multimedia";
    settings = {
      server.port = 8333;
    };
  };

  services.kavita = {
    enable = true;
    tokenKeyFile = config.age.secrets.kavitaKey.path;
    settings = {
      Port = 5000;
    };
  };
}
