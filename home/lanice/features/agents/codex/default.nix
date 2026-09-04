{
  programs.codex = {
    enable = true;

    context = ''
      This is a NixOS system.
    '';

    skills = {
      unslop = ../common/skills/unslop;
      frontend-design = ../common/skills/frontend-design;
    };
  };
}
