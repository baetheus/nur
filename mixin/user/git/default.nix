let
  brandon = import ../brandon.nix;
in
{
  programs.git = with brandon; {
    enable = true;
    ignores = [
      "*.DS_Store"
      "*~"
      "*.swp"
      ".direnv"
      ".jj"
    ];

    settings = {
      user.email = email;
      user.name = name;
      alias = {
        ll = "log --oneline";
      };
      init.defaultBranch = "main";
    };

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519_sk_rk_default.pub";
      signByDefault = true;
    };
  };
}
