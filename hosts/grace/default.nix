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
      # services.gnome.gcr-ssh-agent.enable = false;

      # Networking
      networking.hostName = "grace";
      networking.hostId = "007f0215";
      networking.interfaces.enp0s31f6.useDHCP = true;
      networking.networkmanager.enable = true;

      # Firewall
      networking.firewall.enable = true;
      networking.firewall.allowedUDPPorts = [ ];
      networking.firewall.allowedTCPPorts = [ 22 ];

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

      # Setup the desktop
      environment.systemPackages = with pkgs; [
        xwayland-satellite
        brightnessctl
        librewolf
        plexamp
      ];

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${config.programs.niri.package}/bin/niri-session";
            user = "brandon";
          };
        };
      };

      programs.niri.enable = true;

      # For the hotkeys
      services.playerctld.enable = true;
      services.pipewire.enable = true;
      services.pipewire.audio.enable = true;
      services.pipewire.alsa.enable = true;
      services.pipewire.wireplumber.enable = true;

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
    };
}
