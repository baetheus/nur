{ self, inputs, ... }:
{
  flake.modules.darwin.base =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        inputs.ragenix.darwimModules.default
        inputs.agenix-rekey.darwinModules.default
        self.modules.generic.base
      ];

      # Default Shell
      programs.zsh.enable = true;

      # Firewall
      networking.applicationFirewall = {
        enable = true;
        allowSigned = true;
        allowSignedApp = true;
        enableStealthMode = true;
      };

      # System defaults
      system.defaults = {
        NSGlobalDomain = {
          AppleMetricUnits = 1;
          AppleMeasurementUnits = "Centimeters";
          AppleTemperatureUnit = "Celsius";
          AppleShowScrollBars = "Automatic";
          AppleFontSmoothing = 2;
          AppleShowAllExtensions = true;
          NSScrollAnimationEnabled = true;
          PMPrintingExpandedStateForPrint = true;

          "com.apple.sound.beep.feedback" = 0;
          "com.apple.sound.beep.volume" = 0.4;
          "com.apple.springing.enabled" = false;
          "com.apple.swipescrolldirection" = false;
          "com.apple.trackpad.scaling" = 2.0;
        };

        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

        dock = {
          autohide = true;
          expose-group-apps = false;
          mru-spaces = false;
          tilesize = 32;
          showhidden = true;
          # Disable all hot corners
          wvous-bl-corner = 1;
          wvous-br-corner = 1;
          wvous-tl-corner = 1;
          wvous-tr-corner = 1;
        };

        finder = {
          AppleShowAllExtensions = true;
          FXEnableExtensionChangeWarning = false;
        };

        loginwindow = {
          GuestEnabled = false;
          DisableConsoleAccess = false;
          SHOWFULLNAME = true;
        };

        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = true;
        };
      };

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
    };
}
