{ pkgs, ... }:
let
  brandon = import ./brandon.nix;
in
{
  programs.zsh.enable = true;

  users.users.${brandon.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = brandon.keys;
    shell = pkgs.zsh;
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
