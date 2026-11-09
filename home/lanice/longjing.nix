{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.age

    ./global # includes features/cli,features/helix

    ./features/agents
    ./features/agents/herdr
    ./features/agents/herdr/resume.nix
    ./features/agents/opencode
    ./features/agents/pi

    ./features/cli/ssh.nix
    ./features/cli/forgejo.nix
    ./features/cli/fabric.nix
    ./features/cli/rex.nix
    ./features/cli/typst.nix
    ./features/cli/webdev.nix

    ./features/email
    ./features/distrobox

    ./features/desktop/firefox
    ./features/desktop/zen
    ./features/desktop/zed
    ./features/desktop/ghostty
    ./features/desktop/office
    ./features/desktop/vicinae

    ./features/desktop/cosmic

    ./themes/catppuccin-mocha
  ];

  browser.default = "zen";

  programs.fish.shellAbbrs.sshs = ''ghostty --theme="Catppuccin Macchiato" -e ssh sencha'';

  # Speakers and USB-C/DP audio share one card profile; toggle between them.
  programs.fish.functions.audio-toggle = ''
    set -l card alsa_card.pci-0000_00_1f.3
    if ${pkgs.pulseaudio}/bin/pactl list short sinks | string match -q '*1f.3.hdmi*'
      ${pkgs.pulseaudio}/bin/pactl set-card-profile $card output:analog-stereo+input:analog-stereo
      and echo "Audio: laptop speakers"
    else
      ${pkgs.pulseaudio}/bin/pactl set-card-profile $card output:hdmi-stereo+input:analog-stereo
      and echo "Audio: USB-C / DisplayPort"
    end
  '';

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "ghostty";
    };

    packages = let
      colmena-unstable = inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena;
      dbosctl = inputs.dbosctl.packages.${pkgs.stdenv.hostPlatform.system}.default;
      kenku-fm = inputs.kenku-fm.packages.${pkgs.stdenv.hostPlatform.system}.kenku-fm-experimental;
    in
      with pkgs; [
        slack
        discord
        telegram-desktop
        zoom-us

        google-chrome

        obsidian
        gimp
        lumen

        dbosctl

        sxiv
        # bitwarden-desktop
        xrandr
        python3
        terraform
        colmena-unstable
        prismlauncher
        seventeenlands
        filezilla
        jellyfin-desktop
        feishin
        kooha
        kenku-fm
        herdr-core
        herdr-desktop
      ];

    stateVersion = lib.mkDefault "26.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
