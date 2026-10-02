{lib, ...}: {
  # Merged from platform/host modules; feeds claude-code, codex, omp, opencode and pi.
  options.agents.context = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Global context shared by all coding agents.";
  };
}
