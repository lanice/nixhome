{
  config,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fish_add_path -g ${config.home.homeDirectory}/.cargo/bin

      if test -e ${config.home.homeDirectory}/.env.fish
        source ${config.home.homeDirectory}/.env.fish
      end

      thefuck --alias | source
    '';

    shellAbbrs = {
      aptgrade = "sudo apt update && sudo apt upgrade";

      cat = "bat";
      df = "duf";

      zj = "zellij";
      db = "distrobox";
      dbe = "distrobox enter";

      sshu = "ssh -t unstable fish";

      hm = "home-manager";
      hms = "home-manager --flake . switch";
      nfu = "nix flake update";

      # Git
      gs = "git status";
      gf = "git fetch";
      gp = "git pull";
      gd = "git diff";
      gauc = "git add -u && git commit";
      gcan = "git commit --amend --no-edit";
      gpr = "git pull --rebase";
      gw = "git worktree";
      gwa = "git worktree add";

      # eza
      ls = "eza";
      la = "eza -a";
      ll = "eza -l";
      lla = "eza -la";
      lt = "eza --tree";
      lld = "eza -alF --group-directories-first";

      github-last-commit = "echo \"[$(git rev-parse --short HEAD)]($(gh browse --no-browser $(git rev-parse HEAD)))\" | ${pkgs.xclip}/bin/xclip -sel clip";
    };

    functions = {
      fish_greeting = ''
        begin
            echo (date) " @ " (hostname)
            # echo
            # ${pkgs.fortune}/bin/fortune art goedel wisdom tao literature songs-poems paradoxum
            # echo
        end | ${pkgs.lolcat}/bin/lolcat
      '';

      wh = "readlink -f (which $argv)";
    };

    plugins = [
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
      {
        name = "pisces";
        src = pkgs.fishPlugins.pisces.src;
      }
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
      {
        name = "puffer-fish";
        src = pkgs.fetchFromGitHub {
          owner = "nickeb96";
          repo = "puffer-fish";
          rev = "fd0a9c95da59512beffddb3df95e64221f894631";
          sha256 = "aij48yQHeAKCoAD43rGhqW8X/qmEGGkg8B4jSeqjVU0=";
        };
      }
    ];
  };
}
