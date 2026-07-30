# The media estate: the directories holding media, and media in transit, that
# boba's services hold in common. A share is a directory more than one service
# reads or writes; a service's own state directory has a single writer and is
# not one, however much media flows through it.
#
# Every share is group-owned by the media group and mode 0770 — that is what
# makes it reachable by everything that needs it, and it is why neither is an
# option here.
{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.media;

  share = {
    name,
    config,
    ...
  }: {
    options = {
      under = lib.mkOption {
        type = lib.types.str;
        description = "Which root this share sits under.";
      };

      owner = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          User that owns the directory. `null` leaves ownership alone, which is
          what the library directories want — they predate the services that
          fill them and are not any one service's to claim.
        '';
      };

      path = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Absolute path, derived from the root and the share name.";
      };
    };

    config.path = let
      root =
        cfg.roots.${config.under}
        or (throw "homelab.media.shares.\"${name}\": no root named \"${config.under}\".");
    in "${root}/${name}";
  };

  # tmpfiles takes `-` for "leave this field as it is".
  rule = owner: mode: path: "d ${path} ${mode} ${
    if owner == null
    then "-"
    else owner
  } ${cfg.group} - -";

  # Parents before children, so a share's root and intermediate directories
  # exist before systemd-tmpfiles tries to adjust the leaf.
  byPath = lib.sort (a: b: a.path < b.path) (lib.attrValues cfg.shares);
in {
  options.homelab.media = {
    group = lib.mkOption {
      type = lib.types.str;
      default = "multimedia";
      description = "The media group. Every share is group-owned by it.";
    };

    gid = lib.mkOption {
      type = lib.types.int;
      default = 992;
      description = ''
        Pinned so it is knowable at evaluation time and survives a rebuild from
        scratch. See docs/adr/0002-pinned-media-identity.md — this number is
        expensive to change.
      '';
    };

    owner = lib.mkOption {
      type = lib.types.str;
      default = "lanice";
      description = "The estate's owner. Containers run as this user.";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      readOnly = true;
      description = "The owner's uid, for containers that want a numeric PUID.";
    };

    roots = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Directories the estate is rooted at. Each is created and group-owned.";
    };

    shares = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule share);
      default = {};
      description = "Directories more than one service reads or writes.";
    };
  };

  config = {
    homelab.media = {
      uid = config.users.users.${cfg.owner}.uid;

      roots = {
        media = "/data/media";
        downloads = "/downloads";
      };

      # The library directories. No single service owns them — jellyfin,
      # sonarr, radarr and navidrome all read and write here — so they are
      # declared with the estate rather than travelling with a service.
      shares = {
        movies.under = "media";
        shows.under = "media";
        anime.under = "media";
        books.under = "media";
        music.under = "media";
        audiobooks.under = "media";
      };
    };

    users.groups.${cfg.group}.gid = cfg.gid;
    users.users.${cfg.owner}.extraGroups = [cfg.group];

    systemd.tmpfiles.rules =
      map (rule "root" "0770") (lib.attrValues cfg.roots)
      ++ map (s: rule s.owner "0770" s.path) byPath;

    assertions =
      [
        {
          assertion = config.users.users ? ${cfg.owner};
          message = "homelab.media.owner is \"${cfg.owner}\", which is not a declared user.";
        }
        {
          assertion = cfg.uid != null;
          message = ''
            homelab.media requires ${cfg.owner}'s uid to be pinned — it is null,
            so the estate cannot hand out a numeric PUID. Set users.users.${cfg.owner}.uid.
          '';
        }
      ]
      ++ lib.mapAttrsToList (name: _: {
        assertion = !(lib.hasInfix ".." name) && !(lib.hasPrefix "/" name);
        message = "homelab.media.shares.\"${name}\" must be a path relative to its root.";
      })
      cfg.shares
      ++ lib.mapAttrsToList (name: s: {
        assertion = s.owner == null || config.users.users ? ${s.owner};
        message = "homelab.media.shares.\"${name}\" is owned by \"${toString s.owner}\", which is not a declared user.";
      })
      cfg.shares
      ++ [
        {
          assertion =
            lib.all (g: g.gid != cfg.gid)
            (lib.attrValues (lib.filterAttrs (n: _: n != cfg.group) config.users.groups));
          message = "gid ${toString cfg.gid} is claimed by a group other than ${cfg.group}.";
        }
      ];
  };
}
