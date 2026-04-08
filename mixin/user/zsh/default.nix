{ pkgs, ... }:
{
  home.packages = with pkgs; [
    openssh # For a good ssh-agent
    zsh # Because
    zsh-completions # For completions
  ];

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins"; # Use vi for insert mode
    initContent = ''
      export PATH="/Users/brandon/.deno/bin:$PATH"
      PROMPT="%n@%B%m%b %# "
      RPROMPT="%~"
      COLORTERM=1

      new() {
        nix flake new -t github:baetheus/nur#$1 $2
      }
    '';

    envExtra = "eval \"$(direnv hook zsh)\"";

    shellAliases = {
      ll = "ls -alhG --color=always"; # Pretty ll
      vi = "vim"; # Prefer vim
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
}
