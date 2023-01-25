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

        gl = "git log";
        gst = "git st";
      };

      initExtra = ''
        source ~/.p10k.zsh
        export GPG_TTY=$(tty)
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        bindkey '^r' history-incremental-search-backward
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
