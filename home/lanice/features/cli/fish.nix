{
  config,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;

    shellAbbrs = {
      aptgrade = "sudo apt update && sudo apt upgrade";

      cat = "bat";
      df = "duf";

      zj = "zellij";
      zjf = "zellij --layout ot-frontend";

      db = "distrobox";
      dbe = "distrobox enter";

      sshu = "ssh -t unstable fish";
      sshb = "ssh -t boba";

      nfu = "nix flake update";
      nr = "nixos-rebuild --flake .";
      nrb = "nixos-rebuild --flake . build";
      nrs = "nixos-rebuild --flake . switch";
      snr = "sudo nixos-rebuild --flake .";
      snrs = "sudo nixos-rebuild --flake . switch";
      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";

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

      k = "kubectl";
      kgp = "kubectl get pods";
      kx = "kubectl exec -it";
      kns = "kubens";
      kctx = "kubectx";

      p = "pnpm";

      # github-last-commit = "echo \"[$(git rev-parse --short HEAD)]($(gh browse --no-browser $(git rev-parse HEAD)))\" | ${pkgs.xclip}/bin/xclip -sel clip";
    };

    functions = {
      fish_greeting = ''
        begin
            echo (date) " @ " (hostname)
            # echo
            # ${pkgs.fortune}/bin/fortune art goedel wisdom tao literature songs-poems paradoxum
            # echo
        end | ${pkgs.clolcat}/bin/clolcat
      '';

      wh = "readlink -f (which $argv)";
    };

    interactiveShellInit = ''
      fish_add_path -g ${config.home.homeDirectory}/.cargo/bin

      if test -e ${config.home.homeDirectory}/.env.fish
        source ${config.home.homeDirectory}/.env.fish
      end

      set -U fish_features qmark-noglob

      # Use terminal colors
      set -U fish_color_autosuggestion      brblack
      set -U fish_color_cancel              -r
      set -U fish_color_command             brgreen
      set -U fish_color_comment             brmagenta
      set -U fish_color_cwd                 green
      set -U fish_color_cwd_root            red
      set -U fish_color_end                 brmagenta
      set -U fish_color_error               brred
      set -U fish_color_escape              brcyan
      set -U fish_color_history_current     --bold
      set -U fish_color_host                normal
      set -U fish_color_match               --background=brblue
      set -U fish_color_normal              normal
      set -U fish_color_operator            cyan
      set -U fish_color_param               brblue
      set -U fish_color_quote               yellow
      set -U fish_color_redirection         bryellow
      set -U fish_color_search_match        'bryellow' '--background=brblack'
      set -U fish_color_selection           'white' '--bold' '--background=brblack'
      set -U fish_color_status              red
      set -U fish_color_user                brgreen
      set -U fish_color_valid_path          --underline
      set -U fish_pager_color_completion    normal
      set -U fish_pager_color_description   yellow
      set -U fish_pager_color_prefix        'white' '--bold' '--underline'
      set -U fish_pager_color_progress      'brwhite' '--background=cyan'
    '';

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
