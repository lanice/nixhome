# Upstream scripts/lib/cli-external-packages.ts defines these external roots.
del(.overrides) |
.dependencies |= with_entries(select(
  .key == "@ff-labs/fff-node" or
  .key == "msgpackr-extract" or
  .key == "node-pty"
))
