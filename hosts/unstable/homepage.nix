{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8081;
    settings = {
      title = "Treuenbrietzen Server";
      color = "zinc";
      statusStyle = "dot";
      background = {
        image = "https://i.postimg.cc/HsS3HKW7/orange-alley.webp";
        opacity = 50;
      };
    };
    services = [
      {
        "Stable Diffusion" = [
          {
            "SD.Next" = {
              href = "https://sdnext.lanice.dev/";
              icon = "https://raw.githubusercontent.com/vladmandic/automatic/refs/heads/master/html/logo.svg";
              siteMonitor = "https://sdnext.lanice.dev/";
              description = "All-in-one for AI generative image";
            };
          }
          {
            InvokeAI = {
              href = "https://invoke.lanice.dev/";
              icon = "invoke-ai";
              siteMonitor = "https://invoke.lanice.dev/";
              description = "The Gen AI Platform for Pro Studios";
            };
          }
        ];
      }
      {
        Media = [
          {
            Jellyfin = let
              url = "https://watch.lanice.dev";
            in {
              href = url;
              icon = "jellyfin";
              siteMonitor = url;
              description = "Media Library";
              widget = {
                type = "jellyfin";
                url = url;
                fields = ["movies" "series" "episodes"];
                enableBlocks = true;
                enableNowPlaying = true;
                enableUser = true;
                key = "";
              };
            };
          }
          {
            Jellyseerr = let
              url = "https://jellyseerr.lanice.dev";
            in {
              href = url;
              icon = "jellyseerr";
              siteMonitor = url;
              description = "Movie & TV Show Requests";
            };
          }
          {
            Sonarr = let
              url = "https://sonarr.lanice.dev";
            in {
              href = url;
              icon = "sonarr";
              siteMonitor = url;
              description = "TV Shows";
              widget = {
                type = "sonarr";
                url = url;
                key = "";
                fields = ["wanted" "queued" "series"];
              };
            };
          }
          {
            Radarr = let
              url = "https://radarr.lanice.dev";
            in {
              href = url;
              icon = "radarr";
              siteMonitor = url;
              description = "Movies";
            };
          }
          {
            Readarr = let
              url = "https://readarr.lanice.dev";
            in {
              href = url;
              icon = "readarr";
              siteMonitor = url;
              description = "Books";
            };
          }
          {
            Bazarr = let
              url = "https://bazarr.lanice.dev";
            in {
              href = url;
              icon = "bazarr";
              siteMonitor = url;
              description = "Subtitles";
            };
          }
          {
            Prowlarr = let
              url = "https://prowlarr.lanice.dev";
            in {
              href = url;
              icon = "prowlarr";
              siteMonitor = url;
              description = "Indexer Aggregator";
            };
          }
          {
            "NZBHydra 2" = let
              url = "https://nzbhydra.lanice.dev";
            in {
              href = url;
              icon = "nzbhydra2";
              siteMonitor = url;
              description = "Usenet Meta Search";
            };
          }
          {
            SABnzbd = let
              url = "https://sabnzbd.lanice.dev";
            in {
              href = url;
              icon = "sabnzbd";
              siteMonitor = url;
              description = "Usenet Downloader";
              widget = {
                type = "sabnzbd";
                url = url;
                key = "";
                fields = ["rate" "queue" "timeleft"];
              };
            };
          }
        ];
      }
      {
        Stuff = [
          {
            Paperless = let
              url = "https://paperless.lanice.dev";
            in {
              href = url;
              icon = "sh-paperless-ngx";
              siteMonitor = url;
              description = "Document Management";
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
