{ me, ... }: {
  programs.git = with me; {
    enable = true;
    ignores = [ "*.DS_Store" "*~" "*.swp" ".direnv" ];

    settings = {
      user.email = email;
      user.name = name;
      alias = {
        ll = "log --oneline";
      };
      init.defaultBranch = "main";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowedGitSigners";
    };

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519_sk_rk_default.pub";
      signByDefault = true;
    };
  };
}
