{inputs, ...}: {
  imports = [inputs.rex.homeManagerModules.default];

  programs.rex.enable = true;
  services.rex.enable = true;
}
