{ self, inputs, ... }:
{
  perSystem =
    { config, pkgs, inputs', ... }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs;[
          config.agenix-rekey.package
          age-plugin-yubikey

          nixos-anywhere
        ];
      };

      agenix-rekey.nixosConfigurations = inputs.self.nixosConfigurations;
      agenix-rekey.darwinConfigurations = inputs.self.darwinConfigurations;
    };
}
