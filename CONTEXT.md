# nixhome

A NixOS + home-manager flake managing a personal fleet: two workstations and the homelab. This glossary pins the terms that the configuration is organised around.

## Language

**Homelab**:
The always-on, self-hosted server set — currently **boba** and **taro**. Membership is about role and location, not deployment tooling: `unstable` runs server workloads but sits in a different physical place and is not part of the homelab.
_Avoid_: server, homeserver, cluster

**Colmena tag**:
A deployment-grouping label used to select hosts for a bulk `colmena apply`. Carries no statement about homelab membership — a host can be in the homelab and untagged, or tagged and not.
_Avoid_: group, role

**Published service**:
A service reachable at its own subdomain over HTTPS. Publishing is what makes a service addressable by name; it says nothing about where the service runs, whether it is containerised, or whether it appears on the dashboard. A raw port opened to the internet — a game server, for instance — is not a published service: it has no subdomain and no HTTPS.
_Avoid_: exposed service, proxied service, vhost

**Reachability**:
Whether a published service answers only on the tailnet, or also from the public internet. Every published service has one or the other; tailnet-only is the default and the overwhelming majority.
_Avoid_: visibility, exposure, scope

**Dashboard**:
The single homepage that links to services across the whole fleet. It is a curated view, not a generated index: it may link to services the homelab does not publish, and may omit ones it does.
_Avoid_: homepage (ambiguous with the `homepage-dashboard` package), index, portal

**Media estate**:
The directories holding media, and media in transit, that the homelab's services hold in common. Membership is about being shared: a service's own state directory has a single writer and is not part of the estate, however much media flows through it.
_Avoid_: storage, library (Jellyfin's and Navidrome's word for a collection), media pool

**Share**:
A directory in the media estate that more than one service reads or writes. Being touched by two services is what makes a directory a share; where it sits and who owns it are details.
_Avoid_: mount, export, network share — nothing in the estate is served over the network

**Media group**:
The single group identity that makes every share co-accessible. Services reach a share by being in this group, not by owning it.
_Avoid_: media user, permissions group

**Fleet**:
Every host this flake manages — the workstations and the homelab together. The fleet is the widest circle; the homelab is a subset of it.
_Avoid_: all hosts, machines, infra

**Fleet registry**:
The one record of fleet identity facts: each host's tailnet address and SSH host key, and each person's or device's public key. A fact belongs here once more than nothing consumes it; everything that reaches or trusts a host reads the registry instead of restating the fact. Entries may be sparse — a host appears with only the facts something actually uses.
_Avoid_: inventory (Ansible's word), address book, hosts file
