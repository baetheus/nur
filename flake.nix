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

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        shell = with pkgs; mkShell {
          buildInputs = [
            nixos-anywhere
            claude-code
          ];
        };
      in
      {
        devShells.default = shell;
      }))
    // (import ./system/default.nix inputs)
    // (import ./template/default.nix inputs);
}
