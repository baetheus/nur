{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.niri = inputs.wrappers.wrappers.niri.wrap {
      settings = {
        input.keyboard = {
          xkb.layout = "us,ua";
        };

        layout.gaps = 3;

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.foot;
          "Mod+Q".close-window = null;
        };
      };
    };
  };
}
