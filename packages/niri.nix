{ self, inputs, ... }: {
  perSystem = { pkgs, lib, inputs', ... }: {
    packages.niri = (inputs.wrappers.wrapperModules.niri.apply {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          "${lib.getExe pkgs.swaybg} -i ${../files/default_bg.jpg} -m fill"
        ];

        input.keyboard = {
          xkb.layout = "us";
          xkb.options = "caps,escape";
        };

        layout.gaps = 4;
        layout.default-column-width = { proportion = 0.4; };

        animations.off = null;

        outputs = {
          "eDP-1" = {
            scale = 1.1;
          };
        };
        
        window-rules = [
          {
            focus-ring = {
              on = null;
              width = 2;
              active-gradient._attrs = {
                from = "#80c8ff";
                to = "#bbddff";
                angle = 45;
              };
              inactive-gradient._attrs  = {
                from = "#505050";
                to = "#808080";
                angle = 45;
                relative-to = "workspace-view";
              };
              urgent-gradient._attrs  = {
                from = "#800";
                to = "#a33";
                angle = 45;
              };
            };
            border.off = null;
            geometry-corner-radius = 2;
            clip-to-geometry = true;
          }
          {
            match._attrs.title = "LibreWolf";
            default-column-width.proportion = 0.6;
          }
          {
            match._attrs.title = "Plexamp";
            default-column-width.proportion = 0.3;
          }
        ];

        binds = {
          "Mod+Return" = {
            _attrs = {
              hotkey-overlay-title = "Open a Terminal: foot";
            };
            spawn = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.foot;
          };
          "Mod+Space" = {
            _attrs = {
              hotkey-overlay-title = "Launch a Program: fuzzel";
            };
            spawn = lib.getExe pkgs.fuzzel;
          };


          "Mod+Q".close-window = null;
          "Mod+Shift+Slash".show-hotkey-overlay = null;

          "Mod+H".focus-column-left = null;
          "Mod+J".focus-window-down = null;
          "Mod+K".focus-window-up = null;
          "Mod+L".focus-column-right = null;

          "Mod+Left".consume-or-expel-window-left = null;
          "Mod+Down".move-window-down = null;
          "Mod+Up".move-window-up = null;
          "Mod+Right".consume-or-expel-window-right = null;

          # workspace numbers
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;


          "Mod+Comma".consume-window-into-column = null;
          "Mod+Period".expel-window-from-column = null;

          "Mod+R".reset-window-height = null;

          "Mod+F".maximize-column = null;
          "Mod+Shift+F".fullscreen-window = null;
          "Mod+Ctrl+F".expand-column-to-available-width = null;

          "Mod+C".center-column = null;
          "Mod+Ctrl+C".center-visible-columns = null;

          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";

          "Print".screenshot = null;
          "Ctrl+Print".screenshot-screen = null;
          "Alt+Print".screenshot-window = null;

          "Mod+Escape" = {
            _attrs = {
              allow-inhibiting = false;
            };
            toggle-keyboard-shortcuts-inhibit = null;
          };

          "Mod+Shift+E".quit = null;
          "Ctrl+Alt+Delete".quit = null;

          "Mod+Shift+P".power-off-monitors = null;

          # volume
          "XF86AudioRaiseVolume" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          };
          "XF86AudioLowerVolume" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          };
          "XF86AudioMute" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };
          "XF86AudioMicMute" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          };

          # media
          "XF86AudioPlay" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "playerctl play-pause";
          };
          "XF86AudioStop" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "playerctl stop";
          };
          "XF86AudioPrev" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "playerctl previous";
          };
          "XF86AudioNext" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "playerctl next";
          };

          # brightness
          "XF86MonBrightnessUp" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "brightnessctl --class=backlight set +10%";
          };
          "XF86MonBrightnessDown" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "brightnessctl --class=backlight set 10%-";
          };
        };

        extraConfig = ''prefer-no-csd'';

      };
    }).wrapper;
  };
}
