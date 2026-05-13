{ self, inputs, ... }:
{
  flake.nixosConfigurations.grace = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.diskoConfigurations.grace
      self.modules.nixos.boot-systemd
      self.modules.nixos.base
      self.modules.nixos.brandon-desktop
      self.modules.nixos.grace
    ];
  };

  flake.modules.nixos.grace =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {

      # General
      system.stateVersion = "25.11";
      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config.allowUnfree = true;
      hardware.facter.reportPath = ./facter.json;
      services.pcscd.enable = true;

      # Networking
      networking.hostName = "grace";
      networking.hostId = "007f0215";
      networking.interfaces.enp0s31f6.useDHCP = true;
      networking.networkmanager.enable = true;

      # Firewall
      networking.firewall.enable = true;
      networking.firewall.allowedUDPPorts = [ ];
      networking.firewall.allowedTCPPorts = [
        22
        22000
      ];

      # Immutability
      fileSystems."/persist".neededForBoot = true;
      environment.persistence."/persist" = {
        enable = true;
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
        directories = [
          "/var/lib/nixos"
          "/var/log"
          "/var/lib/NetworkManager"
          "/etc/NetworkManager/system-connections"
          # Tailscale - uses root!
          "/var/lib/tailscale"
        ];
      };

      # Tailscale
      age.secrets.headscale-preauth-brandon.file = ../../secrets/headscale-preauth-brandon.age;
      services.tailscale = {
        enable = true;
        openFirewall = true;
        disableUpstreamLogging = true;
        useRoutingFeatures = "both";
        extraUpFlags = [ "--login-server=https://net.null.pub" ];
        authKeyFile = config.age.secrets.headscale-preauth-brandon.path;
      };

      # Shutdown if the lid is closed
      services.logind.settings.Login = {
        HandleLidSwitch = "poweroff";
        HandleLidSwitchExternalPower = "poweroff";
        HandleLidSwitchDocked = "poweroff";
      };

      # Prevent overheating of cpu
      services.thermald.enable = true;

      # Automate performance/powersave based on cpu freq
      services.auto-cpufreq.enable = true;
      services.auto-cpufreq.settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };

      # Fix caps:escape - capslock key maps to escape systemwide
      services.interception-tools =
        let
          inherit (pkgs.interception-tools-plugins) caps2esc;
          inherit (pkgs) interception-tools;
        in
        {
          enable = true;
          plugins = [ caps2esc ];
          udevmonConfig = lib.strings.toJSON [
            {
              JOB = builtins.concatStringsSep " | " [
                "${interception-tools}/bin/intercept -g $DEVNODE"
                "${lib.getExe caps2esc} -m 1 -t 0"
                "${interception-tools}/bin/uinput -d $DEVNODE"
              ];
              DEVICE.EVENTS.EV_KEY = [
                "KEY_CAPSLOCK"
                "KEY_ESC"
              ];
            }
          ];
        };

      # Niri
      programs.niri.enable = true;

      # Desktop Things
      hardware.bluetooth.enable = true;

      # Battery
      services.upower.enable = true;

      # Packages
      environment.systemPackages = with pkgs; [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        xwayland-satellite
        brightnessctl
        firefox
        plexamp
      ];

    };
}
