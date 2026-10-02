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
    package = llm-agents.pi.overrideAttrs (old: {
      # Bun subagents also need the unbundled SDK.
      postInstall =
        builtins.replaceStrings
        [
          ''rm -rf "$out/lib" "$out/bin"''
          ''--set PI_PACKAGE_DIR "$pkgdir"''
        ]
        [
          ''rm -rf "$out/bin"''
          ''--set PI_PACKAGE_DIR "$pkgdir" --set PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT "$out/lib/node_modules/@earendil-works/pi-coding-agent"''
        ]
        old.postInstall;
    });
    # npm for `pi install npm:...`.
    extraPackages = [pkgs.nodejs];

    inherit (config.agents) context;
  };
}
