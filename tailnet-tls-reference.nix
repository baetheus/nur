# =============================================================================
# tailnet-tls-reference.nix
#
# Wildcard TLS (Let's Encrypt, DNS-01 via Porkbun) for internal services,
# with names resolved privately through headscale MagicDNS extra_records.
#
# Layout assumed: hedy = public, runs headscale (+ nginx).
#                 toph = private (home), runs nginx. Outbound-only internet.
# Replace example.com / IPs / hostnames with your own.
#
# -----------------------------------------------------------------------------
# MANUAL STEPS (outside Nix)
# -----------------------------------------------------------------------------
# Porkbun
#   1. Account -> API Access: create an API key + secret key.
#   2. Domain -> Details -> toggle "API ACCESS" ON for example.com
#      (off by default; issuance fails with an auth error if skipped).
#   3. Do NOT create public A records for the internal names. Names resolve
#      only via headscale. The only public DNS touched is the temporary
#      _acme-challenge TXT records lego creates/removes itself.
#   4. Porkbun keys are account-wide, not zone-scoped. Mitigations: use a
#      domain dedicated to this, or CNAME _acme-challenge.<sub> to a zone at
#      a provider with scoped tokens.
#   5. (hedy only) If any hedy service should be PUBLIC, add normal A/AAAA
#      records at Porkbun for those names. Otherwise treat hedy like toph.
#
# Secrets (agenix/sops, one file per host that runs ACME)
#   Env-style credentials file containing:
#       PORKBUN_API_KEY=pk1_...
#       PORKBUN_SECRET_API_KEY=sk1_...
#   Point `age.secrets.porkbun.file` (or sops equivalent) at it.
#
# Headscale
#   6. dns.base_domain must differ from the domain in server_url
#      (e.g. server_url hs.example.com, base_domain tailnet.example.net).
#   7. Record each node's tailnet IP (`headscale nodes list`) and set
#      `tailnet.ip` below. IPs are stable unless the node is deleted.
#   8. If you use ACL policy, allow clients to reach toph/hedy on 443.
#
# Clients (MacBook / iPhone)
#   9. Must accept tailnet DNS (macOS: Tailscale "Use Tailscale DNS settings";
#      iOS: on by default). Otherwise extra_records won't resolve.
#  10. No CA install needed: certs come from Let's Encrypt (publicly trusted).
#
# Firewall
#  11. Open 443 on toph/hedy's tailscale interface only, e.g.
#      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 443 ];
#
# First run
#  12. Test against staging before prod to avoid rate limits:
#      security.acme.defaults.server =
#        "https://acme-staging-v02.api.letsencrypt.org/directory";
#      Staging certs are untrusted; remove the line once issuance works.
#  13. Wildcards cover ONE label: *.toph.example.com does not cover
#      a.b.toph.example.com. Keep service names one level deep.
#
# Troubleshooting
#  - journalctl -u acme-<certname>.service
#  - Porkbun propagation can be slow: raise the wait (see acme module) or set
#    dnsPropagationCheck = false.
# =============================================================================

{ self, ... }:
{
  # ---------------------------------------------------------------------------
  # Module 1: shared per-host options + wildcard cert via DNS-01 (Porkbun)
  # Import on every host that terminates TLS (hedy and toph).
  # ---------------------------------------------------------------------------
  flake.modules.nixos.tls-wildcard =
    { config, lib, ... }:
    {
      options.tailnet = {
        ip = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "This host's headscale-assigned tailnet IP.";
        };
        domain = lib.mkOption {
          type = lib.types.str;
          example = "toph.example.com";
          description = "Subdomain zone this host serves; cert is *.<domain>.";
        };
      };

      config = {
        security.acme = {
          acceptTerms = true;
          defaults.email = "you@example.com";
          # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

          certs.${config.tailnet.domain} = {
            domain = "*.${config.tailnet.domain}";
            dnsProvider = "porkbun"; # lego provider name
            credentialsFile = config.age.secrets.porkbun.path;
            group = config.services.nginx.group; # lets nginx read the key
            # dnsPropagationCheck = false;        # if issuance times out
            # extraLegoFlags = [ "--dns.propagation-wait" "120s" ];
          };
        };

        # Outbound-only is enough for DNS-01. No inbound 80/443 from the
        # internet is required for issuance.
        # age.secrets.porkbun.file = ./secrets/porkbun.age;
      };
    };

  # ---------------------------------------------------------------------------
  # Module 2: headscale + automatic extra_records from nginx virtualHosts
  # Import ONLY on the headscale host (hedy).
  #
  # Records are generated for:
  #   - this host's own nginx vhosts      -> this host's tailnet.ip
  #   - every other nixosConfiguration in this flake that sets tailnet.ip
  #     (e.g. toph)                       -> that host's tailnet.ip
  # Wildcard vhost names are dropped: extra_records only supports exact names
  # and A/AAAA (no CNAME).
  #
  # Recursion caution: do not import this module on any host whose vhosts you
  # read here (toph must not import headscale-dns).
  # ---------------------------------------------------------------------------
  flake.modules.nixos.headscale-dns =
    { config, lib, ... }:
    let
      otherHosts = lib.filterAttrs (
        name: _: name != config.networking.hostName
      ) self.nixosConfigurations;

      allConfigs = [ config ] ++ lib.mapAttrsToList (_: c: c.config) otherHosts;

      recordsFor =
        c:
        lib.optionals (c ? tailnet && c.tailnet.ip != null) (
          map
            (name: {
              inherit name;
              type = "A";
              value = c.tailnet.ip;
            })
            (
              lib.filter (n: !(lib.hasInfix "*" n)) (
                lib.attrNames (c.services.nginx.virtualHosts or { })
              )
            )
        );
    in
    {
      services.headscale = {
        enable = true;
        address = "127.0.0.1";
        port = 8080;
        settings = {
          server_url = "https://hs.example.com";

          dns = {
            magic_dns = true;
            base_domain = "tailnet.example.net"; # must differ from server_url domain
            # Needed so clients forward everything else upstream.
            nameservers.global = [ "1.1.1.1" "9.9.9.9" ];
            override_local_dns = true;

            # Rendered into config.yaml; changes require a headscale restart.
            # (Alternative: extra_records_path = "/var/lib/headscale/extra.json"
            #  which headscale watches live.)
            extra_records = lib.concatMap recordsFor allConfigs;
          };
        };
      };

      # Reverse-proxy headscale itself on its public name (hedy is public, so
      # this one can use normal HTTP-01 ACME instead of the wildcard).
      # services.nginx.virtualHosts."hs.example.com" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   locations."/" = {
      #     proxyPass = "http://127.0.0.1:8080";
      #     proxyWebsockets = true;
      #   };
      # };
    };

  # ---------------------------------------------------------------------------
  # Module 3: example nginx vhost using the wildcard cert.
  # This is what feeds Module 2: every vhost name defined here becomes an
  # extra_record automatically.
  # ---------------------------------------------------------------------------
  flake.modules.nixos.example-toph-services =
    { config, ... }:
    {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        virtualHosts."grafana.${config.tailnet.domain}" = {
          useACMEHost = config.tailnet.domain; # reuse the wildcard cert
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
          };
        };
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 443 ];
    };

  # ---------------------------------------------------------------------------
  # Per-host wiring (put in each host's own module/file)
  # ---------------------------------------------------------------------------
  # toph:
  #   imports = with inputs.self.modules.nixos; [ tls-wildcard example-toph-services ];
  #   tailnet = { ip = "100.64.0.2"; domain = "toph.example.com"; };
  #
  # hedy:
  #   imports = with inputs.self.modules.nixos; [ tls-wildcard headscale-dns ];
  #   tailnet = { ip = "100.64.0.1"; domain = "hedy.example.com"; };
}
