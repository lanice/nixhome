{}: [
  {
    name = "NixOS Search";
    tags = ["nix"];
    keyword = "@nix";
    url = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=%s";
  }
  {
    name = "wikipedia";
    tags = ["wiki"];
    keyword = "wiki";
    url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
  }
  {
    name = "kernel.org";
    url = "https://www.kernel.org";
  }
  {
    name = "Nix sites";
    toolbar = true;
    bookmarks = [
      {
        name = "homepage";
        url = "https://nixos.org/";
      }
      {
        name = "wiki";
        tags = ["wiki" "nix"];
        url = "https://nixos.wiki/";
      }
      {
        name = "OT repos";
        bookmarks = [
          {
            name = "frontend";
            url = "https://github.com/ottertune/frontend";
          }
          {
            name = "service";
            url = "https://github.com/ottertune/service";
          }
          {
            name = "models";
            url = "https://github.com/ottertune/models";
          }
        ];
      }
      {
        name = "OT docs";
        bookmarks = [
          {
            name = "Employee Handbook";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/EN/pages/1605733/Employee+Handbook";
          }
          {
            name = "Django Admin";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/EN/pages/9666579/Django+Admin";
          }
          {
            name = "OtterTune Test AWS Account";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/EN/pages/4718593/Accessing+the+OtterTune+Test+AWS+Account";
          }
          {
            name = "Customer Success";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/Marketing/pages/161054721/Customer+Success";
          }
          {
            name = "Releases";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/EN/pages/1933318/Releases";
          }
        ];
      }
      {
        name = "OT orga";
        bookmarks = [
          {
            name = "Insperity";
            url = "https://portal.insperity.com/cs/nsp/index";
          }
          {
            name = "Opsgenie";
            url = "https://ottertune.app.opsgenie.com/settings/schedule/detail/4e998f94-1827-42f4-9009-2c900d39dfe8";
          }
          {
            name = "Carta";
            url = "https://app.carta.com/";
          }
        ];
      }
      {
        name = "OT planning";
        bookmarks = [
          {
            name = "Responsibilities";
            url = "https://docs.google.com/document/d/1tp8VPGhYFa4H_axIieAiq2Im_ndtaVu1Ts2ouHf9JwI/edit";
          }
          {
            name = "Engineering Planning";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/EN/pages/17301505/Engineering+Planning+Discussion+Meeting+Notes";
          }
          {
            name = "Roadmap Planning";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/PROD/pages/161972225/Roadmap+Planning+Meeting+Notes";
          }
          {
            name = "Sprint Kickoff Meeting Notes";
            url = "https://ottertune-docs.atlassian.net/wiki/spaces/EN/pages/32210945/Sprint+Kickoff+Meeting+Notes";
          }
        ];
      }
      {
        name = "OT dev";
        bookmarks = [
          {
            name = "Django Admin (dev)";
            url = "https://dev.service.ottertune.com/admin";
          }
          {
            name = "Django Admin (prod)";
            url = "https://admin.service.ottertune.com/admin";
          }
          {
            name = "ArgoCD";
            url = "https://deploy.internal.ottertune.com/";
          }
          {
            name = "Hotjar";
            url = "https://insights.hotjar.com/sites/2867743/dashboard/";
          }
          {
            name = "Datadog";
            url = "https://app.datadoghq.com/apm/home?env=prod";
          }
          {
            name = "Segment";
            url = "https://app.segment.com/ottertune-prod/overview";
          }
        ];
      }
      {
        name = "FE Active Sprint";
        url = "https://ottertune.atlassian.net/jira/software/c/projects/FE/boards/10";
      }
    ];
  }
]
