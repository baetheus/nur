{ self, inputs, ... }:
{
  flake.modules.generic.base =
    { pkgs, ... }:
    {
      # Locale
      time.timeZone = "America/Los_Angeles";

      # Nix
      nix = {
        package = pkgs.nixVersions.stable;
        optimise.automatic = true;

        settings = {
          trusted-users = [ "@wheel" ];
          substituters = [
            "https://cache.nixos.org/"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
        };

        gc = {
          automatic = true;
        };

        extraOptions = ''
          experimental-features = nix-command flakes
          keep-outputs = true
          keep-derivations = true
        '';
      };

      # System Packages
      environment.systemPackages = with pkgs; [
        vim
        git
        wget
        watch
        bottom
        ripgrep
        jujutsu
        openssh
      ];
    };
}
