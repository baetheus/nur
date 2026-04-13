{ self, inputs, ... }:
{
  flake.darwinConfigurations.rosalind = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      self.modules.darwin.base
      self.modules.darwin.brandon
      self.modules.darwin.rosalind
    ];
  };

  flake.modules.darwin.rosalind = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    system.primaryUser = "brandon";
    system.stateVersion = 6;
  };
}
