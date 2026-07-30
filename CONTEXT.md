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

**Alias**:
An additional subdomain that resolves to an already-published service. The service keeps one canonical subdomain; aliases are alternative names for the same thing.
_Avoid_: redirect, CNAME

**Dashboard**:
The single homepage that links to services across the whole fleet. It is a curated view, not a generated index: it may link to services the homelab does not publish, and may omit ones it does.
_Avoid_: homepage (ambiguous with the `homepage-dashboard` package), index, portal
