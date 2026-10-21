{
  inputs,
  config,
  pkgs,
  ...
}: {
  # Runner token (just the token, no `TOKEN=`), paired with `uuid` below. Both
  # come from the original registration's /var/lib/private/gitea-runner/boba/.runner;
  # re-register via https://git.lanice.dev/-/admin/actions/runners to replace them.
  age.secrets.forgejo-runner-token.file = "${inputs.self}/secrets/forgejo-runner-token.age";

  # The runner daemon runs natively (not as a container) because it polls
  # Forgejo on taro over the tailnet, which the podman bridge can't reach
  # (Tailscale's ts-input chain drops !tailscale0 → CGNAT). Jobs themselves
  # still run in podman containers via /run/podman/podman.sock.
  services.forgejo-runner.instances.boba = {
    enable = true;

    secrets.server.connections.default.token_url = config.age.secrets.forgejo-runner-token.path;

    # Module default plus nix; setting the option replaces the default.
    hostPackages = with pkgs; [
      bash
      coreutils
      curl
      gawk
      gnused
      nodejs
      wget
      config.nix.package
    ];

    settings = {
      # taro's published Forgejo (homelab.published.git in
      # hosts/taro/services/forgejo.nix) — each host evaluates its own
      # publishing registry, so the URL is a literal here.
      server.connections.default = {
        url = "https://git.lanice.dev";
        uuid = "fad74fba-2e8a-4ab6-b950-d1ca1cb6493e";
        token = null;
      };

      runner = {
        labels = [
          # GitHub-runner-like image; covers most `uses:` actions out of the box.
          "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
          # Unsandboxed on boba, building via the nix daemon, so outputs land in
          # the store binary-cache.nix serves.
          "nix:host"
        ];

        # nix:host jobs keep their outputs alive by --out-link here, so the
        # weekly GC can't drop them before other hosts fetch them. Inside the
        # runner's StateDirectory (only the instance dir, not its parent), the
        # only place its DynamicUser can write.
        envs.NIX_GCROOT_DIR = "/var/lib/forgejo-runner/boba/gcroots";
      };

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

  # The old gitea-actions-runner module set this for podman; this one doesn't.
  systemd.services.forgejo-runner-boba.environment.DOCKER_HOST = "unix:///run/podman/podman.sock";

  systemd.tmpfiles.rules = [
    # Job containers run as root (rootful podman), so cache contents end up
    # root-owned on the host.
    "d /var/cache/theorangeexplorer 0755 root root -"
  ];
}
