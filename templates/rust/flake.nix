{
  description = "CHANGE ME";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-stable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };
  };

  outputs = inputs @ { self, nixpkgs, utils, rust-overlay, ... }:
    utils.lib.eachDefaultSystem (system: let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
      rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      mkScript = pkgs.writeShellScriptBin;

      shell = with pkgs; mkShell {
        buildInputs = [ rustToolchain ];
        packages = [
          # Insert packages here

          # Insert shell aliases here
          (mkScript "hello" ''echo $MY_ENV'')
        ];

        shellHook = ''
          export MY_ENV="world"
        '';
      };
    in {
      devShells.default = shell;
    });
}

