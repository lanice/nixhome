# The frame server is plain HTTP on the home LAN only

The Inkplate board uses home Wi-Fi without Tailscale, so boba serves its frames and
status page at `http://192.168.4.41:8460` over plain HTTP. This is deliberately not a
published service: no subdomain, HTTPS, authentication, nginx proxy or tailnet
access. Keeping the board's battery-powered check-in simple outweighs encryption
inside the trusted home network; photos and the skip action are accessible to
anyone on that network.

The listener binds only boba's reserved LAN IPv4 address. Firewall guards require
both `enp95s0` and a source in `192.168.4.0/22` in IPv4 raw prerouting, before
Tailscale's own `ts-input` accept chain and the fleet's blanket `tailscale0` trust
rule, so neither tailnet access to the LAN address nor routed internet traffic
bypasses the boundary. There is no IPv6 listener. Do not port
forward this service or add it to `homelab.published`.

Only longjing and boba share the Syncthing folder `inkplate-photos`: add photos in
`~/Sync/inkplate-photos` on longjing; boba receives them in
`/var/lib/inkplate-photos`. No phone or other workstation is a peer of this folder.
This folder is a service-specific input feed, deliberately outside the media
estate: Syncthing supplies a single consumer, not a library shared with the media
services. Syncthing-group read access keeps it isolated; enrolling it in the media
estate would grant unrelated media services access to the photos. This narrows the
estate's earlier definition, which treated any directory used by two services as
a share.

The service reads that folder without write access and keeps its rotation, frame
and JIT cache separately in `/var/lib/frameserver`. Eastern time and quiet hours
04:00–11:00 are explicit command-line settings, not inherited from the host.
