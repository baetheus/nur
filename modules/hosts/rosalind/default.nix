{ self, inputs, ... }:
{
  flake.darwinConfigurations.rosalind = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.home-manager.darwinModules.home-manager
      self.modules.darwin.base
      self.modules.darwin.brandon
      self.modules.darwin.rosalindConfiguration
    ];

    nixpkgs.hostPlatform = "aarch64-darwin";
    system.stateVersion = 6;
    system.primaryUser = "brandon";
  };
}
