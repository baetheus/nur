{ self, inputs, ... }: {
  perSystem = { pkgs, lib, inputs', ... }: {
    packages.foot = (inputs.wrappers.wrapperModules.foot.apply {
      inherit pkgs;
      settings.colors.alpha = 0.9;
    }).wrapper;
  };
}
