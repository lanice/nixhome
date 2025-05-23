{
  inputs,
  config,
  ...
}: {
  age.secrets.homepage.file = "${inputs.self}/secrets/homepage.age";

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8081;
    environmentFile = config.age.secrets.homepage.path;
    settings = {
      title = "Homelab";
      color = "zinc";
      statusStyle = "dot";
      background = {
        image = "https://i.postimg.cc/HsS3HKW7/orange-alley.webp";
        opacity = 50;
      };
      layout = [
        {
          "Stable Diffusion" = {
            style = "row";
            columns = 2;
          };
        }
        {
          Media = {
            style = "row";
            columns = 2;
          };
        }
        {
          "Media Management" = {
            style = "row";
            columns = 4;
          };
        }
        {
          Stuff = {
            style = "row";
            columns = 2;
          };
        }
      ];
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
                fields = ["pending" "approved" "available"];
                enableBlocks = true;
                enableNowPlaying = true;
                enableUser = true;
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
              };
            };
          }
          {
            Jellyseerr = let
              url = "https://browse.lanice.dev";
            in {
              href = url;
              icon = "jellyseerr";
              siteMonitor = url;
              description = "Movie & TV Show Requests";
              widget = {
                type = "jellyseerr";
                url = url;
                fields = ["pending" "approved" "available"];
                key = "{{HOMEPAGE_VAR_JELLYSEERR_KEY}}";
              };
            };
          }
        ];
      }
      {
        "Media Management" = [
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
                key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
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
              widget = {
                type = "radarr";
                url = url;
                key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                fields = ["wanted" "missing" "queued" "movies"];
              };
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
              widget = {
                type = "bazarr";
                url = url;
                key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
                fields = ["missingEpisodes" "missingMovies"];
              };
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
                key = "{{HOMEPAGE_VAR_SABNZBD_KEY}}";
                fields = ["rate" "queue" "timeleft"];
              };
            };
          }
          {
            Lidarr = let
              url = "https://lidarr.lanice.dev";
            in {
              href = url;
              icon = "lidarr";
              siteMonitor = url;
              description = "TV Shows";
              widget = {
                type = "lidarr";
                url = url;
                key = "{{HOMEPAGE_VAR_LIDARR_KEY}}";
                fields = ["wanted" "queued" "artists"];
              };
            };
          }
          {
            "Calibre Web" = let
              url = "https://books.lanice.dev";
            in {
              href = url;
              icon = "calibre-web";
              siteMonitor = url;
              description = "eBook Library";
              widget = {
                type = "calibreweb";
                url = url;
                username = "lanice";
                password = "{{HOMEPAGE_VAR_CWA_PASSWORD}}";
                fields = ["books" "authors" "categories" "series"];
              };
            };
          }
          {
            Komga = let
              url = "https://komga.lanice.dev";
            in {
              href = url;
              icon = "komga";
              siteMonitor = url;
              description = "Media Server for comics, mangas, BDs, magazines and eBooks";
              widget = {
                type = "komga";
                url = url;
                username = "";
                password = "";
                fields = ["libraries" "series" "books"];
              };
            };
          }
          {
            "CWA Book Downloader" = let
              url = "https://cwa-download.lanice.dev";
            in {
              href = url;
              icon = "calibre-web-automated-book-downloader";
              siteMonitor = url;
              description = "eBook Downloader";
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
          {
            StirlingPDF = let
              url = "https://pdf.lanice.dev";
            in {
              href = url;
              icon = "stirling-pdf";
              siteMonitor = url;
              description = "PDF manipulation tool";
            };
          }
          {
            "Tailscale - boba" = {
              icon = "tailscale";
              widget = {
                type = "tailscale";
                deviceid = "nafZuSQg4D21CNTRL";
                key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
                fields = ["address" "last_seen" "expires"];
              };
            };
          }
          {
            "Tailscale - unstable" = {
              icon = "tailscale";
              widget = {
                type = "tailscale";
                deviceid = "nGjCi22CNTRL";
                key = "{{HOMEPAGE_VAR_TAILSCALE_KEY}}";
                fields = ["address" "last_seen" "expires"];
              };
            };
          }
          {
            "Uptime-Kuma unstable" = let
              url = "https://uptime.lanice.dev";
            in {
              href = url;
              icon = "uptime-kuma";
              description = "Server Monitoring";
              widget = {
                type = "uptimekuma";
                url = url;
                slug = "unstable";
              };
            };
          }
          {
            "Uptime-Kuma boba" = let
              url = "https://uptime.lanice.dev";
            in {
              href = url;
              icon = "uptime-kuma";
              description = "Server Monitoring";
              widget = {
                type = "uptimekuma";
                url = url;
                slug = "boba";
              };
            };
          }
          {
            LibreChat = let
              url = "https://chat.lanice.dev";
            in {
              href = url;
              icon = "https://raw.githubusercontent.com/danny-avila/LibreChat/main/client/public/assets/logo.svg";
              siteMonitor = url;
              description = "All-In-One AI Conversations";
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
  };
}
