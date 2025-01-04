{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8081;
    settings = {
      title = "Treuenbrietzen Server";
      color = "zinc";
    };
    services = [
      {
        "Stable Diffusion" = [
          {
            "SD.Next" = {
              href = "https://sdnext.lanice.dev/";
              icon = "https://raw.githubusercontent.com/vladmandic/automatic/refs/heads/master/html/logo.svg";
            };
          }
          {
            InvokeAI = {
              href = "https://invoke.lanice.dev/";
              icon = "invoke-ai";
            };
          }
        ];
      }
      {
        Media = [
          {
            Jellyfin = {
              href = "https://jelly.lanice.dev/";
              icon = "jellyfin";
            };
          }
        ];
      }
      {
        Stuff = [
          {
            Paperless = {
              href = "https://paperless.lanice.dev/";
              icon = "sh-paperless-ngx";
            };
          }
        ];
      }
    ];
    widgets = [
      {
        resources = {
          cpu = true;
          cputemp = true;
          memory = true;
          expanded = true;
          uptime = true;
          network = true;
        };
      }
      {
        datetime = {
          # text_size = "xl";
          format = {
            dateStyle = "short";
            timeStyle = "short";
            hour12 = true;
          };
        };
      }
      {
        openmeteo = {
          label = "Tater Hill";
          latitude = "41.47516093341124";
          longitude = "-72.36077195955225";
          units = "imperial";
        };
      }
    ];
    # bookmarks = [
    #   {
    #     Developer = [
    #       {
    #         Github = [
    #           {
    #             icon = "si-github";
    #             href = "https://github.com/";
    #           }
    #         ];
    #       }
    #       {
    #         "Nixos Search" = [
    #           {
    #             icon = "si-nixos";
    #             href = "https://search.nixos.org/packages";
    #           }
    #         ];
    #       }
    #       {
    #         "Nixos Wiki" = [
    #           {
    #             icon = "si-nixos";
    #             href = "https://nixos.wiki/";
    #           }
    #         ];
    #       }
    #       {
    #         "Kubernetes Docs" = [
    #           {
    #             icon = "si-kubernetes";
    #             href = "https://kubernetes.io/docs/home/";
    #           }
    #         ];
    #       }
    #     ];
    #   }
    # ];
  };
}
