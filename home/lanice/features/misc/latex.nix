{pkgs, ...}: let
  tex = pkgs.texlive.combine {
    inherit
      (pkgs.texlive)
      scheme-basic
      preprint
      titlesec
      marvosym
      enumitem
      latexindent
      latexmk
      fontawesome5
      ;
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  };
in {
  home.packages = [tex];
}
