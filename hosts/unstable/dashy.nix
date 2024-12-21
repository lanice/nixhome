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
              title = "Stable Diffusion";
              description = "SD.Next / InvokeAI";
              # icon = "https://i.ibb.co/cLfVCQP/dev-env.png";
              url = "https://sdnext.lanice.dev/";
              statusCheck = true;
              statusCheckAllowInsecure = true;
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
