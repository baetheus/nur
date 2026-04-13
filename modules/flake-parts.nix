{ inputs, ... }:
{
  imports = [
    inputs.disko.flakeModules.default
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
    inputs.agenix-rekey.flakeModule
  ];

  config = {
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };

}
