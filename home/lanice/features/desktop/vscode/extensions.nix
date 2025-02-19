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
    {
      name = "vscode-todo-plus";
      publisher = "fabiospampinato";
      version = "4.19.1";
      sha256 = "sha256-3ykOShGBZ8X4ra5EtZWf8EhVYEIy2Ji5+G3k2seL+1Y=";
    }
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
      version = "3.16.0";
      sha256 = "sha256-eZwi5qONiH+XVZj7u2cjJm+Liv1q07AEd8d4nXEQgLw=";
    }
    {
      name = "catppuccin-vsc-icons";
      publisher = "catppuccin";
      version = "1.17.0";
      sha256 = "sha256-CSAIDlZNrelBf891ztK4n9IaRdtXqpeXnI00hG0/nfA=";
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
      version = "3.4.1";
      sha256 = "sha256-CNaHdnJWvNKkmaL+UsKhl74PhhGZgMEINIzlznSBj4k=";
    }

    # {
    #     name = "new-package";
    #     publisher = "someone";
    #     version = "x.x.x";
    #     sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will complain and show actual hash
    # }
  ]
