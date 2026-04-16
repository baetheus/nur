{ inputs, ... }:
{
  imports = [
    inputs.disko.flakeModules.default
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
  ];

  config = {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x66_64-darwin"
      "aarch64-darwin"
    ];
  };

}
