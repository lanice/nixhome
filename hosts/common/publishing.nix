# Publishing: making a service reachable at its own subdomain over HTTPS.
#
# Importing this module gives a host the whole publishing stack — nginx, ACME
# defaults, the porkbun secret, the cold-boot bind guard — so that declaring a
# service is the only per-service cost. See docs/adr/0001-published-services.md
# for what this deliberately does not cover.
{
  inputs,
  config,
  lib,
  ...
}: let
  cfg = config.homelab;

  acmeEmail = "leanderneiss@gmail.com";

  # Values repeated in an assertion message are more useful than a bare count.
  duplicates = list: lib.unique (lib.filter (x: lib.count (y: y == x) list > 1) list);

  publishedService = {
    name,
    config,
    ...
  }: {
    options = {
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Canonical subdomain this service answers on.";
      };

      aliases = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          Additional subdomains resolving to the same service. Each gets its own
          vhost and its own certificate.
        '';
      };

      proxyTo = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        description = ''
          Localhost port to reverse-proxy to.

          Null means the service's own NixOS module generates the vhost body
          (peertube, speedtest-tracker); publishing then contributes only the
          listen addresses, forceSSL, and the certificate, and leaves the
          locations to that module.
        '';
      };

      reachable = lib.mkOption {
        type = lib.types.enum ["tailnet" "public"];
        default = "tailnet";
        description = ''
          Whether the service answers only on the tailnet, or from the public
          internet as well. Public means the service's own authentication is the
          only thing in front of it — `grep 'reachable = "public"'` to audit.
        '';
      };

      fqdn = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Canonical fully-qualified domain name. Derived.";
      };

      url = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Canonical HTTPS URL. Derived; read this instead of writing the domain out.";
      };
    };

    config = {
      fqdn = "${config.subdomain}.${cfg.domain}";
      url = "https://${config.fqdn}";
    };
  };
in {
  options.homelab = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain that published services are subdomains of.";
    };

    tailscaleIP = lib.mkOption {
      type = lib.types.str;
      description = "This host's tailnet address. Tailnet-reachable services bind here.";
    };

    published = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule publishedService);
      default = {};
      description = "Services reachable at their own subdomain over HTTPS.";
    };
  };

  config = lib.mkIf (cfg.published != {}) (let
    services = lib.attrValues cfg.published;

    hasPublic = lib.any (svc: svc.reachable == "public") services;

    # Explicit listen on both 443 (TLS) and 80. With forceSSL the module emits a
    # redirect server block on the plain-HTTP port; without a non-SSL listen
    # entry nothing listens on :80 and http:// URLs are refused. ACME uses
    # DNS-01 (porkbun), so no HTTP-01 challenge competes for port 80.
    mkListen = svc: let
      addr =
        if svc.reachable == "public"
        then "0.0.0.0"
        else cfg.tailscaleIP;
    in [
      {
        inherit addr;
        port = 443;
        ssl = true;
      }
      {
        inherit addr;
        port = 80;
        ssl = false;
      }
    ];

    mkVirtualHost = svc:
      {
        enableACME = true;
        forceSSL = true;
        listen = mkListen svc;
      }
      // lib.optionalAttrs (svc.proxyTo != null) {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString svc.proxyTo}";
          proxyWebsockets = true;
        };
      };

    domainsOf = svc: [svc.fqdn] ++ map (alias: "${alias}.${cfg.domain}") svc.aliases;

    allDomains = lib.concatMap domainsOf services;

    proxiedPorts = lib.filter (port: port != null) (map (svc: svc.proxyTo) services);
  in {
    assertions =
      [
        {
          assertion = duplicates allDomains == [];
          message = "homelab.published: domain declared more than once: ${lib.concatStringsSep ", " (duplicates allDomains)}";
        }
        {
          assertion = duplicates proxiedPorts == [];
          message = "homelab.published: proxyTo port used by more than one service: ${lib.concatStringsSep ", " (map toString (duplicates proxiedPorts))}";
        }
      ]
      ++ lib.mapAttrsToList (name: svc: {
        assertion = svc.proxyTo != null || svc.aliases == [];
        message = ''
          homelab.published.${name} has proxyTo = null, so its own module owns the
          vhost body. An alias vhost would inherit no locations and serve nothing —
          drop the aliases, or give it a proxyTo.
        '';
      })
      cfg.published;

    age.secrets.porkbun.file = "${inputs.self}/secrets/porkbun.age";

    # nginx binds exclusively to the Tailscale IP. On a cold boot nginx can start
    # before tailscaled has assigned that CGNAT address to tailscale0, so bind()
    # fails with EADDRNOTAVAIL and systemd gives up after hitting the restart
    # limit — leaving nginx dead until a manual restart. Allowing non-local binds
    # lets nginx listen on the address before it exists; the socket goes live once
    # Tailscale brings the interface up.
    boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

    services.nginx = {
      enable = true;
      defaultListenAddresses = [cfg.tailscaleIP];

      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      commonHttpConfig = ''
        access_log syslog:server=unix:/dev/log;
        # Silences the "could not build optimal proxy_headers_hash" warning that
        # recommendedProxySettings + many vhosts trigger at the default bucket size.
        proxy_headers_hash_bucket_size 128;
      '';

      virtualHosts = lib.listToAttrs (lib.concatMap (svc:
        map (domain: lib.nameValuePair domain (mkVirtualHost svc)) (domainsOf svc))
      services);
    };

    security.acme = {
      acceptTerms = true;

      defaults = {
        email = acmeEmail;
        environmentFile = config.age.secrets.porkbun.path;
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
      };

      certs = lib.listToAttrs (map (domain:
        lib.nameValuePair domain {
          dnsProvider = "porkbun";
          webroot = null;
        })
      allDomains);
    };

    # Redundant while tailscale0 is a trusted interface, kept as documentation of
    # what publishing actually needs open.
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80 443];
    networking.firewall.allowedTCPPorts = lib.optionals hasPublic [80 443];
  });
}
