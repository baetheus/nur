{ self, inputs, ... }:
{
  flake.nixosConfigurations.amelia = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.nixos-hardware.nixosModules.apple-t2
      self.modules.nixos.boot-systemd
      self.modules.nixos.base
      self.modules.nixos.brandon
      self.modules.nixos.amelia
    ];
  };

  flake.modules.nixos.amelia =
    { config, pkgs, ... }:
    {
      # General setup
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "25.11";

      # Boot Specials
      boot.loader.efi.efiSysMountPoint = "/boot";

      # Hardware Setup
      hardware.apple-t2.kernelChannel = "latest";
      hardware.facter.reportPath = ./facter.json;
      hardware.firmware = [
        # Apple Firmware
        (pkgs.stdenvNoCC.mkDerivation (final: {
          name = "brcm-firmware";
          src = ../../files/firmware.tar;
          dontUnpack = true;
          installPhase = ''
            mkdir -p $out/lib/firmware/brcm
            tar -xf ${final.src} -C $out/lib/firmware/brcm
          '';
        }))
      ];

      # Filesystems
      fileSystems."/" = {
        neededForBoot = true;
        device = "none";
        fsType = "tmpfs";
      };

      fileSystems."/nix" = {
        neededForBoot = true;
        device = "pool/nix";
        fsType = "zfs";
      };

      fileSystems."/persist" = {
        neededForBoot = true;
        device = "pool/persist";
        fsType = "zfs";
      };

      fileSystems."/home" = {
        neededForBoot = true;
        device = "pool/home";
        fsType = "zfs";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/5F66-17ED";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };

      # Impermanence
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
        ];
      };

      # Networking
      networking.hostName = "amelia";
      networking.hostId = "007f0206";

      # Wifi
      age.secrets."tuna-wifi".file = ../../secrets/wifi-tuna.age;
      networking.wireless.enable = true;
      networking.interfaces.wlp0s20f3.useDHCP = true;
      networking.supplicant.WLAN.configFile.path = config.age.secrets."tuna-wifi".path;

      # Firewall
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [
        22
      ];
    };

}
