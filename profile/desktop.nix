{ me, pkgs, ... }:
{
  home = {
    inherit (me) username;
    stateVersion = "23.05";
    sessionVariables.EDITOR = "vim";
    packages = with pkgs; [
      # General CLI Tools
      ripgrep
      bottom
      jujutsu
      git

      # Networking / Backup
      tailscale
      restic
      restic-browser
    ];
  };

  programs = {
    home-manager.enable = true;
  };

  imports = [
    (import ../mixin/git { inherit me pkgs; })
    (import ../mixin/jujutsu { inherit me pkgs; })
    ../mixin/zsh
    ../mixin/vim
    ../mixin/direnv
    ../mixin/zellij
  ];
}
