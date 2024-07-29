{}: [
  {
    name = "NixOS Search";
    tags = ["nix"];
    keyword = "@nix";
    url = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=%s";
  }
  {
    name = "MUI Icons Search";
    tags = ["mui"];
    keyword = "@mui";
    url = "https://mui.com/material-ui/material-icons/?query=%s";
  }
  {
    name = "dict.cc Search";
    tags = ["dict"];
    keyword = "@dict";
    url = "https://www.dict.cc/?s=%s";
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
    name = "Bookmarks";
    toolbar = true;
    bookmarks = [
      {
        name = "wiki";
        tags = ["wiki" "nix"];
        url = "https://nixos.wiki/";
      }
      {
        name = "DBOS";
        bookmarks = [
          {
            name = "console GH";
            url = "https://github.com/dbos-inc/dbos-cloud-console";
          }
          {
            name = "cloud GH";
            url = "https://github.com/dbos-inc/dbos-cloud";
          }
          {
            name = "transact GH";
            url = "https://github.com/dbos-inc/dbos-transact";
          }
          {
            name = "AWS";
            url = "https://500883621673.signin.aws.amazon.com/console";
          }
          {
            name = "STAGING Console";
            url = "https://staging.console.dbos.dev";
          }
          {
            name = "PROD Console";
            url = "https://console.dbos.dev";
          }
        ];
      }
    ];
  }
]
