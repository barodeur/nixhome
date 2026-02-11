{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    shellAliases = {
      l = "ls -l";
      ll = "ls -la";
      gl = "git l";
      gst = "git st";
    };

    initContent = ''
      bindkey '^R' history-incremental-search-backward

      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'vv' edit-command-line

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      export PATH=$PATH:$HOME/bin
      export GOPATH=$HOME/go
      export PATH=$PATH:$GOPATH/bin
      export PATH=$PATH:$HOME/.cargo/bin
      export PATH=$PATH:$HOME/.local/bin
      eval "$(mise activate zsh)"
    '';

    history = {
      extended = true;
      save = 10000;
      size = 10000;
      share = true;
      expireDuplicatesFirst = true;
    };
  };

  programs.starship.enable = true;
}
