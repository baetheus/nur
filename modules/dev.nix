{ self, inputs, ... }:
{
  perSystem =
    { config, pkgs, inputs', ... }:
    let
      pkgs' = import inputs.nixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs';[
          age-plugin-yubikey
          nixos-anywhere
          ragenix
          pcsclite
          claude-code
        ];
      };
    };
}
