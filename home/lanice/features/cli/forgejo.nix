{pkgs, ...}: let
  forgejo-cli = pkgs.symlinkJoin {
    name = "${pkgs.forgejo-cli.name}-fixed-completions";
    paths = [pkgs.forgejo-cli];
    postBuild = ''
      # fj loads keys before generating completions and pollutes stdout.
      for completion in \
        $out/share/bash-completion/completions/fj.bash \
        $out/share/fish/vendor_completions.d/fj.fish \
        $out/share/zsh/site-functions/_fj
      do
        target=$(readlink -f "$completion")
        rm "$completion"
        sed '1{/^Could not find keys file\. Creating a new file\.$/d;}' \
          "$target" > "$completion"
      done
    '';
  };
in {
  # New mirrored repo, from a committed checkout without origin:
  #   fj repo create NAME --private --push --ssh
  #   gh repo create lanice/NAME --private
  # Add it to the GitHub PAT, then add the HTTPS push mirror in Forgejo.

  home.packages = [forgejo-cli];
  home.sessionVariables.FJ_FALLBACK_HOST = "https://git.lanice.dev";
}
