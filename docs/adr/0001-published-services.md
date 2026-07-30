# Publishing is one seam, and it is narrower than it looks

Services on the homelab used to be made reachable by editing five to seven files
per service: the service module, an nginx vhost, a second entry for the ACME
cert, a dashboard tile, a firewall rule, and a secrets entry. The two helpers
that would have prevented the repetition were `let`-scoped inside `nginx.nix`
and so unreachable from any other module — which is why `peertube.nix`,
`speedtest-tracker.nix` and `hosts/unstable/nginx.nix` each hand-copied them,
and why all three dropped the `:80` listen entry that the original documents as
required.

We replaced this with a single interface, `homelab.published.<name>`, declared by
each service in its own module and owning the whole publishing stack: nginx,
ACME defaults, the porkbun secret, the `ip_nonlocal_bind` cold-boot guard, every
vhost and every certificate.

## What publishing deliberately does not cover

The scope is narrow on purpose. Each exclusion was considered and rejected:

- **The dashboard.** Tiles are heterogeneous (widgets, keys, custom icons) and
  span hosts — `homepage.nix` renders tiles for services published by `unstable`,
  and omits tiles for several that boba does publish. Neither set contains the
  other, so the dashboard is a curated view, not a generated index. It now reads
  `homelab.published.<name>.url` instead of hardcoding domains, but keeps its own
  tiles.
- **Raw ports open to the internet.** A published service has a subdomain and
  HTTPS. Minecraft's `25565` has neither. Modelling it here would force the
  interface into a union type with mutually-exclusive fields. It stays the
  one-liner it already was; if a second raw public port ever appears, that is
  when the concept earns a name.
- **Container egress.** The `podman0` ports let containers reach host services —
  the opposite direction from publishing. They stay separate, but now reference
  `homelab.published.<name>.proxyTo` rather than repeating port literals.
- **`unstable`.** It runs server workloads but sits in a different physical
  location and is not part of the homelab. Its diverged nginx copy, including the
  missing `:80` and the missing cold-boot guard, is untouched and still broken.

## Two shapes behind one interface

`proxyTo` is nullable. A port means "generate a plain reverse-proxy vhost" — 26
of 28 services. `null` means the service's own NixOS module generates the vhost
body and publishing owns only reachability and the certificate. Two services
need this and cannot be expressed any other way: peertube generates ~20 location
blocks (resumable uploads, `client_max_body_size 12G`, HLS streaming paths) and
speedtest-tracker generates a PHP-FPM vhost. Upstream expects exactly this split
— the peertube module *reads* `virtualHosts.<domain>.forceSSL` to generate its
own settings and never sets `enableACME` itself.

## Reachability is a field, not a fork

`reachable = "tailnet" | "public"` defaults to tailnet. Nothing is public today,
so the public branch is unexercised until peertube flips. It exists because the
module is otherwise hardwired to the tailnet, and the first public web service
would have had to hand-roll its vhost — reproducing the exact divergence this
ADR exists to end. It also gives public exposure an audit surface: one grep
lists it, where previously it was spread across listen addresses and
`openFirewall` flags in unrelated modules.

Aliases remain separate certificates rather than one certificate with SANs, so
that migrating 28 domains caused zero ACME re-issuance.
