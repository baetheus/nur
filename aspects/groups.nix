{ lib, ... }:
{
  flake.modules.generic.groups = { lib, ... }: {
    options.aspects.groups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = {};
      description = "Groups with lists of usernames as members";
    };
  };
}
