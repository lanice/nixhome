{
  inputs,
  config,
  ...
}: let
  configDir = "/var/lib/explo";
  mediaDir = "/data/media";
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 1000 992 - -"
    "d ${mediaDir}/music/explo 0770 1000 992 - -"
  ];

  # Secrets required: SYSTEM_PASSWORD (Navidrome user password),
  # SLSKD_API_KEY, UI_USERNAME, UI_PASSWORD. Add an entry for explo.age
  # in secrets/secrets.nix and `agenix -e secrets/explo.age` to create it.
  age.secrets.explo = {
    file = "${inputs.self}/secrets/explo.age";
    mode = "440";
  };

  # ListenBrainz-driven playlist generator (Discover Weekly / Daily Jams etc.)
  # Pushes generated playlists into Navidrome via its Subsonic API and pulls
  # tracks via slskd. Schedules are managed in the web UI at :7288.
  virtualisation.oci-containers.containers.explo = {
    image = "ghcr.io/lumepart/explo:latest";
    autoStart = true;
    ports = ["7288:7288"];
    environmentFiles = [config.age.secrets.explo.path];
    environment = {
      TZ = "America/New_York";
      WEB_UI = "true";

      LISTENBRAINZ_USER = "lanice"; # ListenBrainz username

      EXPLO_SYSTEM = "subsonic";
      SYSTEM_URL = "http://host.containers.internal:4533";
      SYSTEM_USERNAME = "leander"; # Navidrome username

      DOWNLOAD_SERVICES = "slskd";
      SLSKD_URL = "http://host.containers.internal:5030";
      MIGRATE_DOWNLOADS = "true";
    };
    volumes = [
      "${configDir}:/opt/explo/config:rw"
      # Mounted at /data inside container — same root as Navidrome's library.
      "${mediaDir}/music/explo:/data:rw"
      # slskd's download dir, exposed at the path explo expects.
      "/downloads/soulseek/complete:/slskd:rw"
    ];
    extraOptions = ["--pull=newer"];
  };
}
