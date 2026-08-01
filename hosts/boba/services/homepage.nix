{
  inputs,
  config,
  ...
}: let
  pub = config.homelab.published;
in {
  age.secrets.homepage.file = "${inputs.self}/secrets/homepage.age";

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8081;
    environmentFiles = [config.age.secrets.homepage.path];
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
            columns = 5;
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
              url = pub.jellyfin.url;
            in {
              href = url;
              icon = "jellyfin";
              siteMonitor = url;
              description = "Media Library";
              widget = {
                type = "jellyfin";
                inherit url;
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
              url = pub.seerr.url;
            in {
              href = url;
              icon = "seerr";
              siteMonitor = url;
              description = "Movie & TV Show Requests";
              widget = {
                type = "seerr";
                inherit url;
                fields = ["pending" "approved" "issues"];
                key = "{{HOMEPAGE_VAR_JELLYSEERR_KEY}}";
              };
            };
          }
          {
            Audiobookshelf = let
              url = pub.audiobookshelf.url;
            in {
              href = url;
              icon = "audiobookshelf";
              siteMonitor = url;
              description = "Audiobook Library";
              widget = {
                type = "audiobookshelf";
                inherit url;
                fields = ["books" "booksDuration"];
                key = "{{HOMEPAGE_VAR_AUDIOBOOKSHELF_KEY}}";
              };
            };
          }
          {
            BookOrbit = let
              url = pub.bookorbit.url;
            in {
              href = url;
              icon = "bookorbit";
              siteMonitor = url;
              description = "Book Library & Reader";
            };
          }
          {
            Navidrome = let
              url = pub.navidrome.url;
            in {
              href = url;
              icon = "navidrome";
              siteMonitor = url;
              description = "Music Streaming Server";
              widget = {
                type = "navidrome";
                inherit url;
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
              url = pub.sonarr.url;
            in {
              href = url;
              icon = "sonarr";
              siteMonitor = url;
              description = "TV Shows";
              widget = {
                type = "sonarr";
                inherit url;
                key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                fields = ["wanted" "queued" "series"];
              };
            };
          }
          {
            Radarr = let
              url = pub.radarr.url;
            in {
              href = url;
              icon = "radarr";
              siteMonitor = url;
              description = "Movies";
              widget = {
                type = "radarr";
                inherit url;
                key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                fields = ["wanted" "missing" "queued" "movies"];
              };
            };
          }
          {
            Lidarr = let
              url = pub.lidarr.url;
            in {
              href = url;
              icon = "lidarr";
              siteMonitor = url;
              description = "Music";
              widget = {
                type = "lidarr";
                inherit url;
                key = "{{HOMEPAGE_VAR_LIDARR_KEY}}";
                fields = ["wanted" "queued" "artists"];
              };
            };
          }
          {
            SABnzbd = let
              url = pub.sabnzbd.url;
            in {
              href = url;
              icon = "sabnzbd";
              siteMonitor = url;
              description = "Usenet Downloader";
              widget = {
                type = "sabnzbd";
                inherit url;
                key = "{{HOMEPAGE_VAR_SABNZBD_KEY}}";
                fields = ["rate" "queue" "timeleft"];
              };
            };
          }
          {
            slskd = let
              url = pub.slskd.url;
            in {
              href = url;
              icon = "slskd";
              siteMonitor = url;
              description = "Soulseek";
              widget = {
                type = "slskd";
                inherit url;
                key = "{{HOMEPAGE_VAR_SLSKD_KEY}}";
                fields = ["slskStatus" "downloads" "sharedFiles"];
              };
            };
          }
          {
            Shelfmark = let
              url = pub.shelfmark.url;
            in {
              href = url;
              icon = "shelfmark";
              siteMonitor = url;
              description = "Book Downloader";
            };
          }
          {
            Prowlarr = let
              url = pub.prowlarr.url;
            in {
              href = url;
              icon = "prowlarr";
              siteMonitor = url;
              description = "Indexer Aggregator";
            };
          }
          {
            Bazarr = let
              url = pub.bazarr.url;
            in {
              href = url;
              icon = "bazarr";
              siteMonitor = url;
              description = "Subtitles";
            };
          }
          {
            "NZBHydra 2" = let
              url = pub.nzbhydra.url;
            in {
              href = url;
              icon = "nzbhydra2";
              siteMonitor = url;
              description = "Usenet Meta Search";
            };
          }
          {
            Aurral = let
              url = pub.aurral.url;
            in {
              href = url;
              icon = "aurral";
              siteMonitor = url;
              description = "Music Discovery";
            };
          }
          {
            Explo = let
              url = pub.explo.url;
            in {
              href = url;
              icon = "explo";
              siteMonitor = url;
              description = "Music Discovery";
            };
          }
          {
            Tracearr = let
              url = pub.tracearr.url;
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
              url = pub.paperless.url;
            in {
              href = url;
              icon = "sh-paperless-ngx";
              siteMonitor = url;
              description = "Document Management";
            };
          }
          {
            StirlingPDF = let
              url = pub.stirlingpdf.url;
            in {
              href = url;
              icon = "stirling-pdf";
              siteMonitor = url;
              description = "PDF manipulation tool";
            };
          }
          {
            "Uptime-Kuma unstable" = let
              url = pub.uptime-kuma.url;
            in {
              href = url;
              icon = "uptime-kuma";
              description = "Server Monitoring";
              widget = {
                type = "uptimekuma";
                inherit url;
                slug = "unstable";
              };
            };
          }
          {
            "Uptime-Kuma boba" = let
              url = pub.uptime-kuma.url;
            in {
              href = url;
              icon = "uptime-kuma";
              description = "Server Monitoring";
              widget = {
                type = "uptimekuma";
                inherit url;
                slug = "boba";
              };
            };
          }
          {
            LibreChat = let
              url = pub.librechat.url;
            in {
              href = url;
              icon = "https://raw.githubusercontent.com/danny-avila/LibreChat/main/client/public/assets/logo.svg";
              siteMonitor = url;
              description = "All-In-One AI Conversations";
            };
          }
          {
            Scrutiny = let
              url = pub.scrutiny.url;
            in {
              href = url;
              icon = "scrutiny";
              siteMonitor = url;
              description = "Hard Drive S.M.A.R.T Monitoring";
            };
          }
          {
            "Adguard Home" = let
              url = pub.adguard.url;
            in {
              href = url;
              icon = "adguard-home";
              siteMonitor = url;
              description = "Network-wide ads & trackers blocking DNS server";
              widget = {
                type = "adguard";
                inherit url;
                username = "admin";
                password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
                fields = ["queries" "blocked" "filtered" "latency"];
              };
            };
          }
          {
            "Speedtest" = let
              url = pub.speedtest.url;
            in {
              href = url;
              icon = "speedtest-tracker";
              siteMonitor = url;
              description = "Speedtest Tracker";
              widget = {
                type = "speedtest";
                inherit url;
                version = 2;
                key = "{{HOMEPAGE_VAR_SPEEDTEST_KEY}}";
                fields = ["download" "upload" "ping"];
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

  homelab.published.dashboard = {
    subdomain = "home";
    proxyTo = config.services.homepage-dashboard.listenPort;
  };
}
