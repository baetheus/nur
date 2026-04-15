{ self, inputs, ...  }: {
  flake.nixosConfigurations.grace = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.diskoConfigurations.grace
      self.modules.nixos.boot-systemd
      self.modules.nixos.base
      self.modules.nixos.brandon-desktop
      self.modules.nixos.grace
    ];
  };

  flake.modules.nixos.grace = { config, pkgs, ... }:
  {

    # General
    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = "x86_64-linux";
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
        "/etc/NetworkManager/system-connections"
      ];
    };

    # Setup the desktop
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      foot
      fuzzel
      brightnessctl
    ];

    fonts.packages = [ pkgs.font-awesome_4 ];

    programs.niri.enable = true;
    programs.niri.package =
      self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    programs.waybar.enable = true;

    services.playerctld.enable = true;
    services.pipewire.enable = true;
    services.pipewire.audio.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.wireplumber.enable = true;
  };
}
