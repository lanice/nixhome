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

    ms-python.python
    ms-python.vscode-pylance
    ms-python.isort
    ms-toolsai.jupyter
    ms-vscode-remote.remote-ssh

    github.copilot
    # github.copilot-chat
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    naumovs.color-highlight
    ryu1kn.partial-diff
    kamadorueda.alejandra
    usernamehw.errorlens
    eamodio.gitlens

    catppuccin.catppuccin-vsc
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
      version = "1.0.5883";
      sha256 = "sha256-BNxLINcbat2F4PHCrKHKIuMpXW1q9aP2SDb0oIv48v0=";
    }

    # {
    #     name = "new-package";
    #     publisher = "someone";
    #     version = "x.x.x";
    #     sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will complain and show actual hash
    # }
  ]
