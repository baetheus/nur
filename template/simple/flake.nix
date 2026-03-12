{
  description = "CHANGE ME";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-stable";
  };

  outputs = inputs @ { self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      mkScript = pkgs.writeShellScriptBin;

      shell = with pkgs; mkShell {
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

