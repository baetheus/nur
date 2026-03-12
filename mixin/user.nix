let
  # Type validation helpers
  isString = x: builtins.typeOf x == "string";
  isList = x: builtins.typeOf x == "list";
  isNonEmptyString = x: isString x && builtins.stringLength x > 0;

  # Validate user data with descriptive errors
  validateUser = me:
    let
      errors = builtins.concatLists [
        (if !(builtins.isAttrs me) then
          ["User data must be an attribute set, got: ${builtins.typeOf me}"]
        else [])

        (if !(me ? username) then
          ["Missing required field: 'username'"]
        else if !(isNonEmptyString me.username) then
          ["Field 'username' must be a non-empty string, got: ${builtins.typeOf me.username}"]
        else [])

        (if !(me ? name) then
          ["Missing required field: 'name'"]
        else if !(isString me.name) then
          ["Field 'name' must be a string, got: ${builtins.typeOf me.name}"]
        else [])

        (if !(me ? email) then
          ["Missing required field: 'email'"]
        else if !(isString me.email) then
          ["Field 'email' must be a string, got: ${builtins.typeOf me.email}"]
        else [])

        (if !(me ? signingkey) then
          ["Missing required field: 'signingkey'"]
        else if !(isString me.signingkey) then
          ["Field 'signingkey' must be a string, got: ${builtins.typeOf me.signingkey}"]
        else [])

        (if !(me ? keys) then
          ["Missing required field: 'keys'"]
        else if !(isList me.keys) then
          ["Field 'keys' must be a list, got: ${builtins.typeOf me.keys}"]
        else if !(builtins.all isString me.keys) then
          ["Field 'keys' must be a list of strings"]
        else [])
      ];

      errorMsg = builtins.concatStringsSep "\n  - " errors;
    in
    if errors == [] then me
    else builtins.throw "Invalid user data:\n  - ${errorMsg}";

  # Internal implementation

  user = import ../user;
  profile = import ../profile;
in
rec {
  # Make default user and home-manager
  mkUser = { me, profile, pkgs, overrides ? {} }:
    let
      validatedMe = validateUser me;
      isDarwin = pkgs.stdenv.isDarwin;
      homeDir = if isDarwin then "/Users/${validatedMe.username}" else "/home/${validatedMe.username}";
    in
    {
      users.users.${validatedMe.username} = (if isDarwin then {
        home = homeDir;
      } else {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = validatedMe.keys;
      }) // overrides;

      home-manager.users.${validatedMe.username} = profile { me = validatedMe; inherit pkgs; };
    };

  # Make user with zsh shell
  mkZshUser = { me, profile, pkgs, overrides ? {} }:
    (mkUser {
      inherit me profile pkgs;
      overrides = {
        shell = pkgs.zsh;
      } // overrides;
    }) // {
      programs.zsh.enable = true;
    };

  # Groupings of users and home directories
  users = {
    default = { pkgs, overrides ? {} }: mkZshUser {
      inherit pkgs overrides;
      me = user.brandon;
      profile = profile.desktop;
    };
  };

  # Export validator for external use
  inherit validateUser;
}
