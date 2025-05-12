{pkgs}:
with pkgs.vscode-extensions;
  [
    bbenoist.nix
    bradlc.vscode-tailwindcss
    dotjoshjohnson.xml
    prisma.prisma
    tamasfe.even-better-toml
    wholroyd.jinja
    yzhang.markdown-all-in-one
    astro-build.astro-vscode
    bmalehorn.vscode-fish
    # rust-lang.rust-analyzer
    golang.go

    # arrterian.nix-env-selector

    ms-python.python
    ms-python.vscode-pylance
    ms-python.isort
    ms-python.black-formatter
    ms-vscode-remote.remote-ssh
    ms-vsliveshare.vsliveshare

    github.copilot
    github.copilot-chat
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    naumovs.color-highlight
    ryu1kn.partial-diff
    kamadorueda.alejandra
    usernamehw.errorlens
    eamodio.gitlens
    yoavbls.pretty-ts-errors

    github.github-vscode-theme
    pkief.material-icon-theme

    # catppuccin.catppuccin-vsc
    # catppuccin.catppuccin-vsc-icons

    # firefox-devtools.vscode-firefox-debug
    # jnoortheen.nix-ide
    # mkhl.direnv

    jgclark.vscode-todo-highlight
  ]
  ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # {
    #   name = "gitless";
    #   publisher = "maattdd";
    #   version = "11.7.2";
    #   sha256 = "sha256-rYeZNBz6HeZ059ksChGsXbuOao9H5m5lHGXJ4ELs6xc=";
    # }
    # {
    #   name = "vsliveshare";
    #   publisher = "ms-vsliveshare";
    #   version = "1.0.5905";
    #   sha256 = "sha256-y1MMO6fd/4a9PhdBpereEBPRk50CDgdiRc8Vwqn0PXY=";
    # }
    # {
    #   name = "gitlens";
    #   publisher = "eamodio";
    #   version = "14.8.0";
    #   sha256 = "sha256-UVMFCgt082GPcPkhlMgmp5mJaoTSGpWKtQARjHQFjTo=";
    # }

    {
      name = "catppuccin-vsc";
      publisher = "catppuccin";
      version = "3.16.1";
      sha256 = "sha256-qEwQ583DW17dlJbODN8SNUMbDMCR1gUH4REaFkQT65I=";
    }
    {
      name = "catppuccin-vsc-icons";
      publisher = "catppuccin";
      version = "1.18.0";
      sha256 = "sha256-R3gv6mflKe8DUry7JRK+dD7YdxS2auG4BBFDf8u55hk=";
    }

    {
      name = "dbos-ttdbg";
      publisher = "dbos-inc";
      version = "1.4.10";
      sha256 = "sha256-L7/v5Jh3XxaVitb1WBCTUrN11CHuSwr0NH4n7QDzj5I=";
    }

    {
      name = "playwright";
      publisher = "ms-playwright";
      version = "1.1.7";
      sha256 = "sha256-jbMgEzogc/rZskV7WbxRYfCeIKAcZS2ZMPEdO4jAotk=";
    }

    {
      name = "claude-dev";
      publisher = "saoudrizwan";
      version = "3.15.1";
      sha256 = "sha256-VuUvxLiPbdpBko3h/FFc1/kYUdUvy7f/euN+Js/Hp4I=";
    }

    # {
    #     name = "new-package";
    #     publisher = "someone";
    #     version = "x.x.x";
    #     sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will complain and show actual hash
    # }
  ]
