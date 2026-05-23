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
            columns = 4;
          };
        }
        {
          "Media Management" = {
            style = "row";
            columns = 5;
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
              icon = "https://raw.githubusercontent.com/vladmandic/sdnext/refs/heads/master/html/logo-dark.svg";
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
                enableMediaControl = false;
                showEpisodeNumber = true;
                expandOneStreamToTwoRows = true;
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
              };
            };
          }
          {
            Seerr = let
              url = "https://browse.lanice.dev";
            in {
              href = url;
              icon = "seerr";
              siteMonitor = url;
              description = "Movie & TV Show Requests";
              widget = {
                type = "seerr";
                url = url;
                fields = ["pending" "approved" "issues"];
                key = "{{HOMEPAGE_VAR_JELLYSEERR_KEY}}";
              };
            };
          }
          {
            Audiobookshelf = let
              url = "https://audiobookshelf.lanice.dev";
            in {
              href = url;
              icon = "audiobookshelf";
              siteMonitor = url;
              description = "Audiobook Library";
              widget = {
                type = "audiobookshelf";
                url = url;
                fields = ["books" "booksDuration"];
                key = "{{HOMEPAGE_VAR_AUDIOBOOKSHELF_KEY}}";
              };
            };
          }
          {
            Navidrome = let
              url = "https://music.lanice.dev";
            in {
              href = url;
              icon = "navidrome";
              siteMonitor = url;
              description = "Music Streaming Server";
              widget = {
                type = "navidrome";
                url = url;
                user = "leander";
                token = "{{HOMEPAGE_VAR_NAVIDROME_TOKEN}}";
                salt = "{{HOMEPAGE_VAR_NAVIDROME_SALT}}";
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
            Lidarr = let
              url = "https://lidarr.lanice.dev";
            in {
              href = url;
              icon = "lidarr";
              siteMonitor = url;
              description = "Music";
              widget = {
                type = "lidarr";
                url = url;
                key = "{{HOMEPAGE_VAR_LIDARR_KEY}}";
                fields = ["wanted" "queued" "artists"];
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
            slskd = let
              url = "https://slskd.lanice.dev";
            in {
              href = url;
              icon = "slskd";
              siteMonitor = url;
              description = "Soulseek";
              widget = {
                type = "slskd";
                url = url;
                key = "{{HOMEPAGE_VAR_SLSKD_KEY}}";
                fields = ["slskStatus" "downloads" "sharedFiles"];
              };
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
            Aurral = let
              url = "https://aurral.lanice.dev";
            in {
              href = url;
              icon = "aurral";
              siteMonitor = url;
              description = "Music Discovery";
            };
          }
          {
            Explo = let
              url = "https://explo.lanice.dev";
            in {
              href = url;
              icon = "explo";
              siteMonitor = url;
              description = "Music Discovery";
            };
          }
          {
            Tracearr = let
              url = "https://tracearr.lanice.dev";
            in {
              href = url;
              icon = "tracearr";
              siteMonitor = url;
              description = "Media Server Analytics";
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
          {
            Scrutiny = let
              url = "https://scrutiny.lanice.dev";
            in {
              href = url;
              icon = "scrutiny";
              siteMonitor = url;
              description = "Hard Drive S.M.A.R.T Monitoring";
            };
          }
          {
            "Adguard Home" = let
              url = "https://adguard.lanice.dev";
            in {
              href = url;
              icon = "adguard-home";
              siteMonitor = url;
              description = "Network-wide ads & trackers blocking DNS server";
              widget = {
                type = "adguard";
                url = url;
                username = "admin";
                password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
                fields = ["queries" "blocked" "filtered" "latency"];
              };
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
    ];
  };
}
