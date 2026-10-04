{
  config,
  inputs,
  pkgs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  # settings/keybindings/models stay unset: pi rewrites those files itself.
  programs.pi-coding-agent = {
    enable = true;
    package = llm-agents.pi;
    # npm for `pi install npm:...`.
    extraPackages = [pkgs.nodejs];

    inherit (config.agents) context;
  };
}
