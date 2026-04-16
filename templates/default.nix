{ self, inputs, ... }: {
  flake.templates = {
    # Simple nix flake with a stdenv.devShell and flake-utils
    simple = {
      path = ./simple;
      description = "nix flake new -t github:baetheus/.nix#simple .";
    };
    # A nix flake setup for rust
    rust = {
      path = ./rust;
      description = "nix flake new -t github:baetheus/.nix#rust .";
    };
  };
}
