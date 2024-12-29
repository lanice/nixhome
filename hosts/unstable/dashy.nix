{
  services.dashy = {
    enable = true;
    virtualHost = {
      enableNginx = true;
      domain = "localhost";
    };
    settings = {
      pageInfo = {
        title = "Treuenbrietzen Server";
        description = "Dashboard";
      };
      appConfig = {
        disableUpdateChecks = true;
        preventWriteToDisk = true;

        theme = "tiger";

        defaultOpeningMethod = "newtab";

        defaultIcon = "generative";
        layout = "auto";
        startingView = "default";
        language = "en";
        hideComponents = {
          hideFooter = true;
          hideHeading = false;
          hideNav = false;
          hideSearch = false;
          hideSettings = false;
        };
      };
      sections = [
        {
          name = "Misc";
          widgets = [
            {
              type = "joke";
            }
          ];
        }
        {
          name = "Stable Diffusion";
          # icon = "fas fa-traffic-light-go";
          displayData = {
            itemSize = "large";
            sortBy = "default";
            # sectionLayout = "grid";
            # itemCountX = 2;
          };
          items = [
            {
              title = "SD.Next";
              # description = "SD.Next";
              icon = "https://raw.githubusercontent.com/vladmandic/automatic/refs/heads/master/html/logo.svg";
              url = "https://sdnext.lanice.dev/";
            }
            {
              title = "InvokeAI";
              # description = "SD.Next";
              icon = "https://raw.githubusercontent.com/invoke-ai/InvokeAI/refs/heads/main/invokeai/frontend/web/public/assets/images/invoke-symbol-ylw-lrg.svg";
              url = "https://invoke.lanice.dev/";
            }
          ];
        }
        {
          name = "Stuff";
          displayData = {
            itemSize = "large";
            sortBy = "default";
          };
          items = [
            {
              title = "Paperless";
              icon = "https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/refs/heads/dev/resources/logo/web/svg/square.svg";
              url = "https://paperless.lanice.dev/";
            }
          ];
        }
      ];
    };
  };

  services.nginx.virtualHosts."localhost" = {
    listen = [
      {
        addr = "0.0.0.0";
        port = 8080;
      }
    ];
  };
}
