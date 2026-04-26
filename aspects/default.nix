{ self, ... }:
{
  flake.modules.generic.aspects = { ... }: {
    imports = [
      self.modules.generic.users
      self.modules.generic.groups
    ];
  };
}
