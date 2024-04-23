# Inspired by misterio's config as well as https://git.sr.ht/~rycee/configurations/tree/master/item/user/firefox.nix
{
  pkgs,
  config,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles.lanice = {
      bookmarks = import ./bookmarks.nix {};
      extensions = with pkgs.inputs.firefox-addons; [
        # https://gitlab.com/rycee/nur-expressions/blob/master/pkgs/firefox-addons/generated-firefox-addons.nix
        ublock-origin
        bitwarden
        addy_io
        skip-redirect
        kagi-search
        toolkit-for-ynab
        multi-account-containers
        link-cleaner

        omnivore

        # Firefox addons come from an external flake and don't respect my nixpkgs.allowUnfree setting
        (lastpass-password-manager.overrideAttrs {meta.license.free = true;})

        # bypass-paywalls-clean
        stylus
      ];
      settings = {
        "beacon.enabled" = false;
        "browser.contentblocking.category" = "strict";
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.autohideButton" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "https://kagi.com/";
        "browser.startup.page" = 3; # Resume last session.
        "browser.download.dir" = "${config.home.homeDirectory}/download";
        "browser.newtabpage.enabled" = false; # Blank new tab page.
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.translations.automaticallyPopup" = false;

        "dom.security.https_only_mode" = true;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
        # "identity.fxaccounts.enabled" = false;
        # "permissions.default.shortcuts" = 2;

        # "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';

        # Fully disable Pocket. See
        # https://www.reddit.com/r/linux/comments/zabm2a.
        "extensions.pocket.enabled" = false;
        "extensions.pocket.api" = "0.0.0.0";
        "extensions.pocket.loggedOutVariant" = "";
        "extensions.pocket.oAuthConsumerKey" = "";
        "extensions.pocket.onSaveRecs" = false;
        "extensions.pocket.onSaveRecs.locales" = "";
        "extensions.pocket.showHome" = false;
        "extensions.pocket.site" = "0.0.0.0";
        "browser.newtabpage.activity-stream.pocketCta" = "";
        "browser.newtabpage.activity-stream.section.highlights.includePocket" =
          false;
        "services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket" =
          false;
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
