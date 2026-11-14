{ self, inputs, ... }: {
  flake.modules.nixos.photoBrowser =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.services.photoBrowser;
      # main.ts must sit next to this file; it is copied into the Nix store.
      app = pkgs.writeText "photo-browser.ts" (builtins.readFile ./main.ts);
    in
    {
      options.services.photoBrowser = {
        enable = lib.mkEnableOption "simple photo/video browser";

        root = lib.mkOption {
          type = lib.types.path;
          example = "/media";
          default = "/media";
          description = "Media root (YYYY/MM/DD folders). Must be writable by `user`.";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Listen address. No auth: keep on LAN/VPN or behind a proxy.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 8000;
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "media";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "media";
        };
      };

      config = lib.mkIf cfg.enable {
        users.users.${cfg.user} = lib.mkIf (cfg.user == "media") {
          isSystemUser = true;
          group = cfg.group;
        };
        users.groups.${cfg.group} = lib.mkIf (cfg.group == "media") { };

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

        systemd.services.photo-browser = {
          description = "Photo browser";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];

          environment = {
            MEDIA_ROOT = toString cfg.root;
            HOST = cfg.host;
            PORT = toString cfg.port;
            # jsr: imports are fetched on first start (needs internet once), then cached.
            DENO_DIR = "/var/cache/photo-browser/deno";
          };

          serviceConfig = {
            ExecStart = lib.concatStringsSep " " [
              "${pkgs.deno}/bin/deno run"
              "--allow-net=${cfg.host}:${toString cfg.port}"
              "--allow-read=${toString cfg.root}"
              "--allow-write=${toString cfg.root}"
              "${app}"
            ];
            User = cfg.user;
            Group = cfg.group;
            CacheDirectory = "photo-browser";
            Restart = "on-failure";

            # Hardening
            NoNewPrivileges = true;
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ReadWritePaths = [ (toString cfg.root) ];
            ProtectKernelTunables = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];
          };
        };
      };
    };
}
