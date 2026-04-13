{ self, inputs, ... }:
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    {
      # Imports
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.ragenix.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        self.modules.generic.base
      ];

      # Locale
      i18n.defaultLocale = "en_US.UTF-8";

      # OpenSSH
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitEmptyPasswords = false;
          PermitTunnel = false;
          UseDns = false;
          KbdInteractiveAuthentication = false;
          X11Forwarding = config.services.xserver.enable;
          MaxAuthTries = 3;
          MaxSessions = 2;
          TCPKeepAlive = false;
          AllowAgentForwarding = false;
          LogLevel = "VERBOSE";
          PermitRootLogin = "no";
          GSSAPIAuthentication = "no";
        };
        extraConfig = "PubkeyAuthOptions verify-required";
      };
      services.fail2ban = {
        maxretry = 5;
        bantime = "1h";
        bantime-increment = {
          enable = true; # Enable increment of bantime after each violation
          multipliers = "1 2 4 8 16 32 64 128 256";
          maxtime = "168h"; # Do not ban for more than 1 week
          overalljails = true; # Calculate the bantime based on all the violations
        };
      };

      # Sudo
      systemd.enableEmergencyMode = false;
      security.sudo.wheelNeedsPassword = false;

      # ZFS
      # Default to latest LTS kernel but update this if needed
      # boot.kernelPackages = pkgs.linuxPackages_6_12;
      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs.devNodes = "/dev/";

      services.zfs.autoScrub.enable = true;
      services.zfs.autoSnapshot.enable = true;

      # Agenix
      age.secrets.msmtp-passwordeval.file = ../secrets/msmtp-passwordeval.age;

      # Setup SMTP Relay
      programs.msmtp = {
        enable = true;
        setSendmail = true;
        defaults = {
          aliases = "/etc/aliases";
          port = 465;
          tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
          tls = "on";
          auth = "plain";
          tls_starttls = "off";
        };
        accounts = {
          default = {
            host = "smtp.fastmail.com";
            passwordeval = "cat ${config.age.secrets.msmtp-passwordeval.path}";
            user = "brandon@nll.sh";
            from = "noreply@null.pub";
          };
        };
      };

      # Setup ZED
      services.zfs.zed.enableMail = false;
      services.zfs.zed.settings = {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
        ZED_EMAIL_ADDR = [ "brandon@null.pub" ];
        ZED_EMAIL_OPTS = "@ADDRESS@";
        ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
        ZED_NOTIFY_INTERVAL_SECS = 3600;

        ZED_NOTIFY_VERBOSE = true;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = true;
      };
    };
}
