{ nixpkgs, disko, home-manager, nix-darwin, agenix, ... } @ inputs: let
  darwinSystem = module: nix-darwin.lib.darwinSystem {
    modules = [
      home-manager.darwinModules.home-manager
      module
    ];
  };

  nixosSystem = module: nixpkgs.lib.nixosSystem {
    modules = [
      home-manager.nixosModules.home-manager
      agenix.nixosModules.age
    ];
  };
in {
  darwinConfigurations = {
    diane = darwinSystem ./host/diane;
    rosalind = darwinSystem ./host/rosalind;
  };

  nixosConfigurations = {
    toph = nixosSystem ./host/toph; # Home
    abigail = nixosSystem ./host/abigail; # (Cloud) Personal Services
    bartleby = nixosSystem ./host/bartleby; # (Cloud) Public Services
    clementine = nixosSystem ./host/clementine; # (Cloud) Test Server
  };
}
