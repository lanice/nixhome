{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  # Zen's presets want "Macchiato"/"Teal"; theme.* uses lowercase.
  capitalize = s: lib.toUpper (lib.substring 0 1 s) + lib.substring 1 (-1) s;
  isDefault = config.browser.default == "zen";
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};

  # containers.<name>.id, referenced by pins.
  ctr = {
    my = 1;
    dbos = 2;
    amzn = 3;
    lemanda = 4;
  };
  containerOrder = ["my" "DBOS" "amzn" "lemanda"];

  personalSpace = "3a04984a-a80f-49ec-b935-792d422bf815";
  dbosSpace = "ecb9807d-11ca-4939-96e6-2b6c2f4cda03";
  tmpSpace = "f723b4be-6893-41ba-8b56-7b41ac08aecf";
in {
  # ⚠ Close Zen before `nh os switch`: spaces/pins/containers/extension
  # buttons live in files Zen holds locked; the activation step skips them
  # (with a warning) while it runs. Extension buttons also need one
  # launch-and-quit of a fresh profile before they apply.
  imports = [inputs.zen-browser.homeModules.beta];

  assertions = [
    {
      assertion =
        map (container: container.name)
        (lib.attrValues config.programs.zen-browser.profiles.lanice.containers)
        == containerOrder;
      message = "Zen container keys must sort as: ${lib.concatStringsSep ", " containerOrder}";
    }
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = isDefault;
    enablePrivateDesktopEntry = false;

    # Locked (policies.json). Everything the user must never flip back.
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableFeedbackCommands = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    profiles.lanice = {
      id = 0;
      isDefault = true;

      presets.betterfox.enable = true;
      presets.catppuccin = lib.mkIf config.theme.catppuccin.enable {
        enable = true;
        flavor = capitalize config.theme.catppuccin.flavor;
        accent = capitalize config.theme.catppuccin.accent;
      };

      # Defaults (prefs.js); changeable in the browser.
      settings = {
        "zen.welcome-screen.seen" = true;
        "zen.workspaces.continue-where-left-off" = true;
        # Puzzle button, so panel-only extensions are reachable.
        "zen.theme.hide-unified-extensions-button" = false;
        "privacy.userContext.enabled" = true;
        # Container colour bar on every container tab, declared pins included.
        "zen.workspaces.hide-default-container-indicator" = false;
        # Enable HM-installed extensions without a per-addon click.
        "extensions.autoDisableScopes" = 0;

        "browser.startup.page" = 3; # Resume last session.
        "browser.download.panel.shown" = true;
        "browser.download.autohideButton" = false;
        "browser.newtabpage.enabled" = false;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.translations.automaticallyPopup" = false;
        "dom.security.https_only_mode" = true;
        "signon.rememberSignons" = false;
        "beacon.enabled" = false;
      };

      extensions.packages = with addons; [
        ublock-origin
        bitwarden
        kagi-search
        toolkit-for-ynab
        multi-account-containers # site→container rules are set in its panel
      ];

      extensionButtons = with addons; {
        "nav-bar" = map (p: p.addonId) [ublock-origin bitwarden];
        "unified-extensions-area" = map (p: p.addonId) [kagi-search toolkit-for-ynab multi-account-containers];
      };

      search = {
        force = true;
        default = "kagi";
        engines = {
          kagi = {
            name = "Kagi";
            urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
            icon = "https://kagi.com/favicon.ico";
            definedAliases = ["@kagi"];
          };
          nixpkgs = {
            name = "NixOS Packages";
            urls = [{template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@nix"];
          };
          mui = {
            name = "MUI Icons";
            urls = [{template = "https://mui.com/material-ui/material-icons/?query={searchTerms}";}];
            definedAliases = ["@mui"];
          };
          dict = {
            name = "dict.cc";
            urls = [{template = "https://www.dict.cc/?s={searchTerms}";}];
            definedAliases = ["@dict"];
          };
          wikipedia = {
            name = "Wikipedia";
            urls = [{template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}&go=Go";}];
            definedAliases = ["wiki"];
          };
        };
      };

      bookmarks = {
        force = true;
        settings = [
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
          {
            name = "kernel.org";
            url = "https://www.kernel.org";
          }
        ];
      };

      containersForce = true;
      containers = {
        "1-my" = {
          name = "my";
          id = ctr.my;
          color = "blue";
          icon = "fingerprint";
        };
        "2-DBOS" = {
          name = "DBOS";
          id = ctr.dbos;
          color = "orange";
          icon = "briefcase";
        };
        "3-amzn" = {
          name = "amzn";
          id = ctr.amzn;
          color = "purple";
          icon = "cart";
        };
        "4-lemanda" = {
          name = "lemanda";
          id = ctr.lemanda;
          color = "red";
          icon = "pet";
        };
      };

      # Spaces deliberately not bound to a container.
      # Zen orders spaces by array order, not `position`, and the module emits
      # them in attr-name order — hence the numeric key prefixes.
      spacesForce = true;
      spaces = {
        "1-personal" = {
          name = "personal";
          id = personalSpace;
          position = 1000;
          icon = "🏠";
          pins = {
            "YNAB DE" = {
              id = "1342d3a6-8998-4097-9c7f-8dea632e0d3c";
              url = "https://app.ynab.com/03debbfd-396e-41cf-b9c2-e18199e0d012/budget/202608";
              position = 101;
              editedTitle = true;
            };
            "YNAB US" = {
              id = "f4f08500-dc20-4fd7-8a0e-a36374818c55";
              url = "https://app.ynab.com/6ca81d32-b850-4e47-9ad0-7dd42e5ada08/accounts/67440e2d-9c1a-412d-81af-807c91089b29";
              position = 102;
              editedTitle = true;
            };
            "Gmail (lemanda)" = {
              id = "037db2bf-7442-4df1-88fc-a5121a21dd79";
              url = "https://mail.google.com/";
              container = ctr.lemanda;
              position = 103;
              editedTitle = true;
            };
            "Gmail" = {
              id = "7cc0275b-2bdf-4b19-847c-9b8396542e39";
              url = "https://mail.google.com/";
              container = ctr.my;
              position = 104;
              editedTitle = true;
            };
            "Calendar" = {
              id = "c9cc8dc2-24ae-4495-9997-4cb58e6db8cb";
              url = "https://calendar.google.com/";
              container = ctr.my;
              position = 105;
              editedTitle = true;
            };
            "Kagi News" = {
              id = "0baf635e-0d82-4a64-9e6f-3b78a576a2d7";
              url = "https://news.kagi.com/";
              position = 106;
              editedTitle = true;
            };
          };
        };
        "2-DBOS" = {
          name = "DBOS";
          id = dbosSpace;
          position = 2000;
          icon = "💼";
          pins = {
            "Gmail" = {
              id = "b4317bd5-027b-4708-9af1-4d1c6d39f6ad";
              url = "https://mail.google.com/";
              container = ctr.dbos;
              position = 201;
              editedTitle = true;
            };
            "Calendar" = {
              id = "f5b9cd2e-289c-4394-8c07-f1994d5be835";
              url = "https://calendar.google.com/";
              container = ctr.dbos;
              position = 202;
              editedTitle = true;
            };
          };
        };
        "3-tmp" = {
          name = "tmp";
          id = tmpSpace;
          position = 3000;
          icon = "🧪";
        };
      };

      # Essentials strip (cross-space). Ad-hoc pins made in the browser get
      # demoted to normal tabs on the next switch — declare them here instead.
      pinsForce = true;
      pinsForceAction = "demote";
      pins = {};

      spaceRouting = {
        defaultExternalRoute = "most-recent-space";
        routes.amazon = {
          # Store only; *.aws.amazon.com is work and stays put.
          reference = "^https?://(www\\.|smile\\.)?amazon\\.";
          matchType = "regex";
          openIn = tmpSpace;
        };
      };
    };
  };
}
