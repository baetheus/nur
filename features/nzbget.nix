{ self, inputs, ... }: {
  flake.modules.nixos.nzbgetService = { config, pkgs, lib, ...  }:
    let
      cfg = config.services.nzbget;
      # Settings we pass to make nzbget runnable as a service
      settings = {
        OutputMode = "loggable";
        WriteLog = "none";
        ErrorTarget = "screen";
        WarningTarget = "screen";
        InfoTarget = "screen";
        DetailTarget = "screen";
        ConfigTemplate = "${cfg.package}/share/nzbget/nzbget.conf";
        WebDir = "${cfg.package}/share/nzbget/webui";
        UpdateCheck = "none";
      };
      configList = lib.mapAttrsToList (name: value: "-o ${name}=${value}") settings;
      configOpts = lib.concatStringsSep " " configList;
    in
    {
      disabledModules = [ "services/misc/nzbget.nix" ];

      options = {
        services.nzbget = {
          enable = lib.mkEnableOption "NZBGet, for downloading files from news servers";

          package = lib.mkPackageOption pkgs "nzbget" { };

          user = lib.mkOption {
            type = lib.types.str;
            default = "nzbget";
            description = "User account under which NZBGet runs";
          };

          group = lib.mkOption {
            type = lib.types.str;
            default = "nzbget";
            description = "Group under which NZBGet runs";
          };

          dataDir = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/nzbget";
            description = ''
              The directory where nzbget stores its data files.
            '';
          };

          configFile = lib.mkOption {
            type = lib.types.path;
            description = ''
              NZBGet configuration file, passed via command line using switch -c. Refer to
              <https://github.com/nzbgetcom/nzbget/blob/develop/nzbget.conf>
              for details on supported values.
            '';
          };
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.services.nzbget = {
          description = "NZBGet Daemon";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          path = with pkgs; [
            unrar
            p7zip
          ];

          serviceConfig = {
            StateDirectory = "nzbget";
            StateDirectoryMode = "0750";
            User = cfg.user;
            Group = cfg.group;
            UMask = "0002";
            Restart = "on-failure";
            ExecStart = "${cfg.package}/bin/nzbget --server --configfile ${cfg.configFile} ${configOpts}";
            ExecStop = "${cfg.package}/bin/nzbget --quit";
          };
        };

        users.users = lib.mkIf (cfg.user == "nzbget") {
          nzbget = {
            home = cfg.dataDir;
            group = cfg.group;
            uid = config.ids.uids.nzbget;
          };
        };

        users.groups = lib.mkIf (cfg.group == "nzbget") {
          nzbget = {
            gid = config.ids.gids.nzbget;
          };
        };
      };
    };
}
