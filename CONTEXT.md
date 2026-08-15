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

### Mail archive

**Mail archive**:
The homelab's permanent, read-only store of household mail. For mail older than the reclaim window it is the *only* copy; for younger mail it is a second copy alongside the provider.
_Avoid_: mail backup, mail server

**Source account**:
A provider-hosted mailbox the archive mirrors. Source accounts are a distinct set from the workstation email module's accounts.
_Avoid_: mailbox (ambiguous with the archive's own store)

**Mirror pass**:
The nightly copy of a source account's mail into the archive. A mirror pass only ever adds — it deletes nothing on either side.
_Avoid_: sync, import

**Reclaim pass**:
The deletion, from a source account, of mail older than the reclaim window — the step that frees provider quota. Runs only for armed accounts and only after verification that the mail is in the archive.
_Avoid_: cleanup, purge, delete pass

**Reclaim window**:
The age below which mail stays on the provider. Currently two years, global across all source accounts.
_Avoid_: retention (the backup concept), cutoff

**Retention**:
The keep policy on the archive's restic backup repo (7 daily / 4 weekly / 12 monthly snapshots).
_Avoid_: reclaim window (the source-account concept)

**Armed**:
Said of a source account whose reclaim pass is enabled. Unarmed accounts mirror only; arming is a deliberate per-account act, never a default.
_Avoid_: enabled, live

**Grant**:
The assignment of a source account's archive tree to the household members who may read it. An account granted to both members is how mail is shared; there is no other sharing mechanism.
_Avoid_: share (a media-estate term), permission, ACL (the mechanism, not the concept)

**Curation**:
The flip-switch that temporarily widens every grant from read-only to read-write so mail can be pruned from the archive by hand. Never a steady state: set, deploy, prune, unset, deploy. Distinct from a reclaim pass, which deletes from source accounts — curation is the only sanctioned way anything leaves the archive.
_Avoid_: edit mode, write access, maintenance mode

**Private input**:
The non-flake flake input `nixhome-private` — a private GitHub repo holding data that must not appear in this public repo, starting with the source-account addresses, their hosts, and grants. It carries dumb data only; all module logic stays public. Distinct from agenix: the private input holds identifying data, agenix holds secrets.
_Avoid_: secrets repo, private flake (it is not a flake)
