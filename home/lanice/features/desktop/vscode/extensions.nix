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
    rust-lang.rust-analyzer

    # arrterian.nix-env-selector

    ms-python.python
    ms-python.vscode-pylance
    ms-python.isort
    ms-toolsai.jupyter
    ms-vscode-remote.remote-ssh

    github.copilot
    github.copilot-chat
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    naumovs.color-highlight
    ryu1kn.partial-diff
    kamadorueda.alejandra
    usernamehw.errorlens

    github.github-vscode-theme
    pkief.material-icon-theme

    # firefox-devtools.vscode-firefox-debug
    # jnoortheen.nix-ide
    # mkhl.direnv
  ]
  ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # {
    #   name = "gitless";
    #   publisher = "maattdd";
    #   version = "11.7.2";
    #   sha256 = "sha256-rYeZNBz6HeZ059ksChGsXbuOao9H5m5lHGXJ4ELs6xc=";
    # }
    {
      name = "vscode-todo-highlight";
      publisher = "jgclark";
      version = "2.0.4";
      sha256 = "sha256-+X/ORct/DH2EpALlrWtbFtujdkmgsSysO3Hg+AkP9aM=";
    }
    {
      name = "vscode-todo-plus";
      publisher = "fabiospampinato";
      version = "4.18.4";
      sha256 = "sha256-daKMeFUPZSanrFu9J6mk3ZVmlz8ZZquZa3qaWSTbSjs=";
    }
    {
      name = "pretty-ts-errors";
      publisher = "yoavbls";
      version = "0.5.2";
      sha256 = "sha256-g6JIiXfjQKQEtdXZgsQsluKuJZO0MsD1ijy+QLYE1uY=";
    }
    {
      name = "vsliveshare";
      publisher = "ms-vsliveshare";
      version = "1.0.5905";
      sha256 = "sha256-y1MMO6fd/4a9PhdBpereEBPRk50CDgdiRc8Vwqn0PXY=";
    }
    {
      name = "gitlens";
      publisher = "eamodio";
      version = "14.8.0";
      sha256 = "sha256-UVMFCgt082GPcPkhlMgmp5mJaoTSGpWKtQARjHQFjTo=";
    }

    {
      name = "catppuccin-vsc";
      publisher = "catppuccin";
      version = "3.11.1";
      sha256 = "sha256-wO3UwS2/I3ASNpAS9daBKnltTJfamhsSiOnH0QD8vkA=";
    }
    {
      name = "catppuccin-vsc-icons";
      publisher = "catppuccin";
      version = "1.8.0";
      sha256 = "sha256-H31UtqqiqGm2r60e44KWTI2rmPRVLQ53vbfaDYBLXIs=";
    }

    # {
    #     name = "new-package";
    #     publisher = "someone";
    #     version = "x.x.x";
    #     sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will complain and show actual hash
    # }
  ]
