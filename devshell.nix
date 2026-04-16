{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      inputs',
      ...
    }:
    let
      pkgs' = import inputs.nixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs'; [
          # For secrets
          ragenix
          age-plugin-yubikey

          # For initial installations
          nixos-anywhere

          # For vim
          nil

          # For vibing and questions I guess
          claude-code
        ];
      };
    };
}
