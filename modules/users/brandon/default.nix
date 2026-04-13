{
  self,
  inputs,
  withSystem,
  ...
}:
let
  brandon = {
    username = "brandon";
    name = "Brandon Blaylock";
    email = "brandon@null.pub";
    signingkey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL7W3Bg5SHwsLQqOjL3lQWf2F9zqY19g9MusuKXi93VtAAAAC3NzaDpkZWZhdWx0 ssh:default";
    keys = [
      # Keychain Yubkey A
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAetuhFZ8SCOLnYdfZOCFTQLzIh3a25WX991X5aWem5eAAAAC3NzaDpkZWZhdWx0 brandon@rosalind"
      # Folder Yubikey B
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIO1pi4MnWUTF2w9GBbxk7F5uuYmt+uRA7gKMGuKqeQe3AAAAC3NzaDpkZWZhdWx0 brandon@rosalind"
      # Laptop Yubikey C
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL7W3Bg5SHwsLQqOjL3lQWf2F9zqY19g9MusuKXi93VtAAAAC3NzaDpkZWZhdWx0 brandon@rosalind"
    ];
  };

in
{
  flake.modules.nixos.brandon =
    { pkgs, ... }:
    {
      home-manager.users."${brandon.username}" = self.homeModules.brandon;
      programs.zsh.enable = true;
      users.users."${brandon.username}" = {
        shell = pkgs.zsh;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = brandon.keys;
      };
    };

  flake.modules.darwin.brandon =
    { pkgs, ... }:
    {
      home-manager.users."${brandon.username}" = self.homeModules.brandon;
      programs.zsh.enable = true;
      users.users."${brandon.username}" = {
        shell = pkgs.zsh;
        home = "/Users/${brandon.username}";
      };
    };

  flake.homeModules.brandon =
    { pkgs, ... }:
    {
      home = {
        inherit (brandon) username;
        stateVersion = "25.11";
        sessionVariables = {
          EDITOR = "vim";
        };
        packages = with pkgs; [
          zsh-completions # For completions
        ];
      };

      # home-manager
      programs.home-manager.enable = true;

      # direnv
      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      # zsh
      programs.zsh = {
        enable = true;
        defaultKeymap = "viins"; # Use vi for insert mode
        initContent = ''
          PROMPT="%n@%B%m%b %# "
          RPROMPT="%~"
          COLORTERM=1
        '';

        envExtra = "eval \"$(direnv hook zsh)\"";

        shellAliases = {
          ll = "ls -alhG --color=always"; # Pretty ll
          vi = "vim"; # Prefer vim
          new = "nix flake new -t"; # Quicker templates
          sw =
            if pkgs.stdenv.isDarwin then
              "sudo darwin-rebuild switch --flake github:baetheus/nur"
            else
              "nixos-rebuild switch --use-remote-sudo --flake github:baetheus/nur";
        };

        history = {
          share = true;
          ignoreDups = true;
          path = "$ZDOTDIR/.zsh_history";
        };

        enableCompletion = true;
        syntaxHighlighting.enable = true;
      };

      # vim
      programs.vim = {
        enable = true;
        plugins = with pkgs; [
          # Generic Plugins
          vimPlugins.vim-unimpaired
          vimPlugins.vim-commentary
          vimPlugins.vim-noctu

          # Life Plugins
          vimPlugins.vim-ledger

          # Programming Plugins
          vimPlugins.ale
          vimPlugins.vim-dadbod
          vimPlugins.vim-dadbod-ui
          vimPlugins.vim-dadbod-completion
          vimPlugins.vim-nix
        ];
        extraConfig = builtins.readFile ./vimrc;
      };

      # git
      programs.git = {
        enable = true;
        settings = {
          user.email = brandon.email;
          user.name = brandon.name;
          alias.ll = "log --oneline";
          init.defaultBranch = "main";
        };
        ignores = [
          "*.DS_Store"
          "*~"
          "*.swp"
          ".direnv"
        ];
      };

      # jujutsu
      programs.jujutsu = {
        enable = true;
        package = pkgs.jujutsu;
        settings = {
          user.name = brandon.name;
          user.email = brandon.email;
          # signing = {
          #   behavior = "drop";
          #   backend = "ssh";
          # };
          # git.sign-on-push = true;

          aliases = {
            dlog = [
              "log"
              "-r"
            ];
            l = [
              "log"
              "-r"
              "(trunk()..@):: | (trunk()..@)-"
            ];
            fresh = [
              "new"
              "trunk()"
            ];
            tug = [
              "bookmark"
              "move"
              "--from"
              "closest_bookmark(@)"
              "--to"
              "closest_pushable(@)"
            ];
          };

          "revset-aliases" = {
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
            "closest_pushable(to)" =
              "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
            "desc(x)" = "description(x)";
            "pending()" = ".. ~ ::tags() ~ ::remote_bookmarks() ~ @ ~ private()";
            "private()" =
              "description(glob:'wip:*') | \
            description(glob:'private:*') | \
            description(glob:'WIP:*') | \
            description(glob:'PRIVATE:*') | \
            conflicts() | \
            (empty() ~ merges()) | \
            description('substring-i:\"DO NOT MAIL\"')";
          };
        };
      };

    };

}
