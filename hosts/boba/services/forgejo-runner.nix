{
  inputs,
  config,
  pkgs,
  ...
}: {
  # Instance-level registration token from https://git.lanice.dev/-/admin/actions/runners.
  # The token is reusable; the durable credential the registration produces
  # lives in /var/lib/gitea-runner/boba/.runner. The module re-registers on
  # token or label changes.
  age.secrets.forgejo-runner-token.file = "${inputs.self}/secrets/forgejo-runner-token.age";

  # The runner daemon runs natively (not as a container) because it polls
  # Forgejo on taro over the tailnet, which the podman bridge can't reach
  # (Tailscale's ts-input chain drops !tailscale0 → CGNAT). Jobs themselves
  # still run in podman containers via /run/podman/podman.sock.
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;

    instances.boba = {
      enable = true;
      name = "boba";
      # taro's published Forgejo (homelab.published.git in
      # hosts/taro/services/forgejo.nix) — each host evaluates its own
      # publishing registry, so the URL is a literal here.
      url = "https://git.lanice.dev";
      tokenFile = config.age.secrets.forgejo-runner-token.path;

      labels = [
        # GitHub-runner-like image; covers most `uses:` actions out of the box.
        "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
      ];

      settings = {
        container = {
          # Same CGNAT constraint as above, one layer down: actions/checkout
          # runs *inside* the job container and clones from git.lanice.dev, so
          # job containers need host networking to route via tailscale0.
          network = "host";

          # The runner creates anonymous workspace and environment volumes for
          # jobs. They are disposable execution state and deliberately excluded
          # from backups; durable build cache uses the host bind mount below.
          # Allowlist for volumes workflows may request via their
          # `jobs.*.container.volumes` (theorangeexplorer mounts this as a
          # persistent build cache). Requests outside this list are silently
          # dropped, surfacing only as a runner-log warning.
          valid_volumes = ["/var/cache/theorangeexplorer"];
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    # Job containers run as root (rootful podman), so cache contents end up
    # root-owned on the host.
    "d /var/cache/theorangeexplorer 0755 root root -"
  ];
}
