{
  config,
  pkgs,
  ...
}: let
  autosuggestionColor =
    if config.theme.polarity == "dark"
    then "white"
    else "brblack";
in {
  programs.fish = {
    enable = true;

    shellAbbrs = {
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
      gco = "git checkout";
      gauc = "git add -u && git commit";
      gcan = "git commit --amend --no-edit";
      gpr = "git pull --rebase";
      gw = "git worktree";
      gwa = "git worktree add";
      gbd = "git branch -D";

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
      # Add fish's built-in completions directory to the path
      set -p fish_complete_path ${config.programs.fish.package}/share/fish/completions

      fish_add_path -g ${config.home.homeDirectory}/.cargo/bin

      if test -e ${config.home.homeDirectory}/.env.fish
        source ${config.home.homeDirectory}/.env.fish
      end

      # Custom fish color overrides
      set -g fish_color_autosuggestion      ${autosuggestionColor} --italics  # brblack too low-contrast on dark themes with transparency
      set -g fish_color_command             brgreen              # default: normal
      set -g fish_color_comment             brmagenta            # default: red
      set -g fish_color_end                 brmagenta            # default: green
      set -g fish_color_match               --background=brblue  # default: unset
      set -g fish_color_operator            cyan                 # default: brcyan
      set -g fish_color_param               brblue               # default: cyan
    '';

    plugins = [
      {
        name = "pisces";
        src = pkgs.fishPlugins.pisces.src;
      }
      {
        name = "puffer-fish";
        src = pkgs.fetchFromGitHub {
          owner = "nickeb96";
          repo = "puffer-fish";
          rev = "3cb17caa88270e1bd215d97fbd591155c976f083";
          sha256 = "sha256-kzAFM4rYWGQiFiw4LTnWv8LYBL7VQ9VlPqOw6d9NYe4=";
        };
      }
    ];
  };
}
