{ self, inputs, ... }:
{
  perSystem =
    { config, pkgs, inputs', ... }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs;[
          age-plugin-yubikey
          nixos-anywhere
          ragenix
        ];
      };
    };
}
