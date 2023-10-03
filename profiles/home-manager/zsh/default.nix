{ pkgs, ... }: {
  programs = {
    zsh = {
      enable = true;

      autocd = true;
      defaultKeymap = "viins";
      enableSyntaxHighlighting = true;

      shellAliases = {
        l = "ls -l";
        ll = "ls -la";

        gl = "git l";
        gst = "git st";
      };

      initExtra = ''
        source ~/.p10k.zsh
        export GPG_TTY=$(tty)
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        bindkey '^r' history-incremental-search-backward
        eval "$(/opt/homebrew/bin/brew shellenv)"
        . /opt/homebrew/opt/asdf/libexec/asdf.sh
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"

        export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
        export PKG_CONFIG_PATH="/opt/homebrew/opt/libpq/lib/pkgconfig"

        export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
        export ANDROID_HOME=$HOME/Library/Android/sdk
        export PATH=$PATH:$ANDROID_HOME/emulator
        export PATH=$PATH:$ANDROID_HOME/platform-tools
        export JAVA_HOME=/opt/homebrew/Cellar/openjdk/21/libexec/openjdk.jdk/Contents/Home
      '';

      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
        ];
      };

      history = {
        extended = true;
        save = 10000;
        size = 10000;
        share = true;
        expireDuplicatesFirst = true;
      };

      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          };
        }
      ];
    };
  };
}
