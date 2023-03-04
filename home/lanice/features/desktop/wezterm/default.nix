{
  home.file.".config/wezterm/wezterm.lua".source = ./wezterm.lua;

  programs.bash = {
    initExtra = ''
      founderterms () {
        cd /home/lanice/dev/projects/founderbuddies
        wezterm cli split-pane --right --cwd /home/lanice/dev/projects/founderbuddies
        wezterm cli split-pane --bottom --cwd /home/lanice/dev/projects/founderbuddies
        pscale connect founderbuddies dev --port 3309
      }
    '';
  };
}
