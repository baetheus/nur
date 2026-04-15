{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.niri = (inputs.wrappers.wrapperModules.niri.apply {
      inherit pkgs;
      settings = {
        input.keyboard = {
          xkb.layout = "us";
        };

        layout.gaps = 5;

        binds = {
          "Mod+Return".spawn-sh = lib.getExe pkgs.foot;
          "Mod+Q".close-window = null;
        };
      };
    }).wrapper;
  };
}
