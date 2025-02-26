{
  config,
  pkgs,
  lib,
  ...
}: let
  librechatPort = "3080";
  ragPort = "8000";
  meilisearchPort = "7700";

  librechatDir = "/var/lib/librechat";
  librechatNetwork = "librechat-network";
in {
  age.secrets.librechat-env.file = ../../../secrets/librechat.env.age;

  systemd.tmpfiles.rules = [
    "d /var/lib/containers/storage/volumes/pgdata2/_data 0700 999 999 - -"
    "d ${librechatDir} 0770 1000 1000 - -"
    "d ${librechatDir}/data-node 0770 1000 1000 - -"
    "d ${librechatDir}/images 0770 1000 1000 - -"
    "d ${librechatDir}/logs 0770 1000 1000 - -"
    "d ${librechatDir}/meili_data_v1.12 0770 1000 1000 - -"
  ];

  virtualisation.oci-containers.containers = {
    librechat = {
      image = "ghcr.io/danny-avila/librechat-dev:latest";
      ports = ["${librechatPort}:${librechatPort}"];
      environment = {
        HOST = "0.0.0.0";
        MONGO_URI = "mongodb://mongodb:27017/LibreChat";
        MEILI_HOST = "http://meilisearch:${meilisearchPort}";
        RAG_PORT = "${ragPort}";
        RAG_API_URL = "http://rag_api:${ragPort}";
      };
      environmentFiles = [config.age.secrets.librechat-env.path];
      volumes = [
        "${librechatDir}/images:/app/client/public/images"
        "${librechatDir}/logs:/app/api/logs"
      ];
      dependsOn = ["mongodb" "rag_api"];

      extraOptions = ["--pull=newer"];
    };

    mongodb = {
      image = "mongo";
      volumes = [
        "${librechatDir}/data-node:/data/db"
      ];
      cmd = ["mongod" "--noauth"];
    };

    meilisearch = {
      image = "getmeili/meilisearch:v1.12.3";
      environment = {
        MEILI_HOST = "http://meilisearch:${meilisearchPort}";
        MEILI_NO_ANALYTICS = "true";
      };
      environmentFiles = [config.age.secrets.librechat-env.path];
      volumes = [
        "${librechatDir}/meili_data_v1.12:/meili_data"
      ];
    };

    vectordb = {
      image = "ankane/pgvector:latest";
      environment = {
        POSTGRES_DB = "mydatabase";
        POSTGRES_USER = "myuser";
        POSTGRES_PASSWORD = "mypassword";
      };
      volumes = [
        "pgdata2:/var/lib/postgresql/data"
      ];
    };

    rag_api = {
      image = "ghcr.io/danny-avila/librechat-rag-api-dev-lite:latest";
      environment = {
        DB_HOST = "vectordb";
        RAG_PORT = "${ragPort}";
      };
      environmentFiles = [config.age.secrets.librechat-env.path];
      dependsOn = ["vectordb"];
    };
  };
}
