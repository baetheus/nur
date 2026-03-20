{
  description = "Nix User Repository for Brandon Blaylock";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-images.url = "github:nix-community/nixos-images";
    nixos-images.inputs.nixos-stable.follows = "nixpkgs-stable";
    nixos-images.inputs.nixos-unstable.follows = "nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      nix-darwin,
      disko,
      sops-nix,
      nixos-images,
      ...
    }@inputs:
    let
      darwinSystem =
        module:
        nix-darwin.lib.darwinSystem {
          modules = [
            home-manager.darwinModules.home-manager
            module
          ];
        };

      nixosSystem =
        module:
        nixpkgs.lib.nixosSystem {
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            module
          ];
        };
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        shell =
          with pkgs;
          mkShell {
            buildInputs = [
              nixos-anywhere
              age-plugin-yubikey
              age
              sops
              nixfmt
              statix
              claude-code
            ];
          };
      in
      {
        devShells.default = shell;

      }
    ))
    // {
      # macOS hosts
      darwinConfigurations = {
        diane = darwinSystem ./host/diane;
        rosalind = darwinSystem ./host/rosalind;
      };

      # nixos hosts
      nixosConfigurations = {
        # systems
        toph = nixosSystem ./host/toph;
        abigail = nixosSystem ./host/abigail;
        bartleby = nixosSystem ./host/bartleby;
        clementine = nixosSystem ./host/clementine;
      };

      # Quick templates that I use
      templates = rec {
        simple = {
          path = ./template/simple;
          description = "nix flake new -t github:baetheus/.nix#simple .";
        };
        rust = {
          path = ./template/rust;
          description = "nix flake new -t github:baetheus/.nix#rust .";
        };
      };

      # Images: TODO hoist to own file
      packages."x86_64-linux" = {
        live-iso =
        (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-images.nixosModules.kexec-installer
            nixos-images.nixosModules.noninteractive
            ./host/live
          ];
        }).config.system.build.kexecTarball;
        live-kexec =
        (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-images.nixosModules.image-installer
            nixos-images.nixosModules.noninteractive
            ./host/live
          ];
        }).config.system.build;
      };
    };
}
