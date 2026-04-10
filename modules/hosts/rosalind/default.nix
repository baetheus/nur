{ self, inputs, ... }:
{
  flake.darwinConfigurations.rosalind = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      self.modules.darwin.base
      self.modules.darwin.rosalindConfiguration
    ];
  };

  flake.modules.darwin.rosalindConfiguration =
    { pkgs, lib, ... }:
    {
      nixpkgs.hostPlatform = "aarch64-darwin";
      system.stateVersion = 6;
      system.primaryUser = "brandon";
    };
}
