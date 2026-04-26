{ lib, ... }:
{
  flake.modules.generic.users = { lib, ... }: {
    options.aspects.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          username = lib.mkOption {
            type = lib.types.str;
            description = "Unix username";
          };
          name = lib.mkOption {
            type = lib.types.str;
            description = "Full display name";
          };
          email = lib.mkOption {
            type = lib.types.str;
            description = "Email address";
          };
          signingkey = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "SSH signing key";
          };
          keys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "SSH public keys for authorized_keys";
          };
        };
      });
      default = {};
      description = "User data aspects";
    };
  };
}
