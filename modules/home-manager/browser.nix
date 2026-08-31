{lib, ...}: {
  # The workstation's default browser (see CONTEXT.md): owns URL/HTML
  # handlers and $BROWSER. Other browsers stay installed and in the dock.
  options.browser.default = lib.mkOption {
    type = lib.types.enum ["firefox" "zen"];
    default = "firefox";
    description = "Browser that web links are handed to.";
  };
}
