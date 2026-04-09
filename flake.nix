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

    ragenix.url = "github:yaxitech/ragenix";
    ragenix.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.inputs.home-manager.follows = "home-manager";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      nix-darwin,
      disko,
      ragenix,
      impermanence,
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
            ragenix.nixosModules.default
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
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
              ragenix.packages.${system}.default
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
        live = nixosSystem ./host/live;
        toph = nixosSystem ./host/toph;
        hedy = nixosSystem ./host/hedy;
        grace = nixosSystem ./host/grace;
        abigail = nixosSystem ./host/abigail;
        bartleby = nixosSystem ./host/bartleby;
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
    };
}
