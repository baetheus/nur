{ pkgs, ... }:
let
  brandon = import ./brandon.nix;
in
rec {
  programs.zsh.enable = true;

  users.users.${brandon.username} = {
    home = "/Users/${brandon.username}";
  };

  home-manager.users.${brandon.username} = {
    programs.home-manager.enable = true;

    home = {
      inherit (brandon) username;
      stateVersion = "25.11";
      sessionVariables.EDITOR = "vim";
    };

    imports = [
      ./zsh
      ./vim
      ./direnv
      ./zellij
      ./git
      ./jujutsu
    ];
  };
}
