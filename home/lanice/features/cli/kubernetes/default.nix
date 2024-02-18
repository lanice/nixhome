{pkgs, ...}: {
  imports = [./k9s];

  home.packages = with pkgs; [
    kubectl
    kubectx
  ];
}
