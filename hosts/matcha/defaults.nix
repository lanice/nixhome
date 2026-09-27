# macOS preferences. Applied on switch; removing a key doesn't reset it.
{config, ...}: let
  home = config.users.users.lanice.home;
  hm = config.home-manager.users.lanice;
in {
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false; # keep Spaces in fixed order
      tilesize = 48;
      minimize-to-application = true;
      persistent-apps = [
        "/Applications/Safari.app"
        "${home}/Applications/Home Manager Apps/Ghostty.app"
        "/System/Applications/System Settings.app"
      ];
      persistent-others = ["${home}/Downloads"];
      wvous-br-corner = 1; # no Quick Note hot corner
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv"; # list view
      FXEnableExtensionChangeWarning = false;
      FXDefaultSearchScope = "SCcf"; # search current folder
      _FXSortFoldersFirst = true;
      NewWindowTarget = "Home";
    };

    NSGlobalDomain = {
      AppleInterfaceStyle =
        if hm.theme.polarity == "dark"
        then "Dark"
        else null;
      ApplePressAndHoldEnabled = false; # key repeat instead of accent popup (hjkl)
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      "com.apple.mouse.tapBehavior" = 1; # tap to click
    };

    trackpad = {
      Clicking = true;
      Dragging = true; # tap-and-drag
    };

    WindowManager.EnableStandardClickToShowDesktop = false; # wallpaper click hides all windows

    CustomUserPreferences."com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };

  # No system sleep on AC (display still sleeps). power.sleep.* uses
  # systemsetup, which would also hit battery.
  system.activationScripts.postActivation.text = ''
    pmset -c sleep 0
  '';
}
