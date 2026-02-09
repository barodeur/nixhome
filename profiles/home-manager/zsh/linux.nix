{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";
    initContent = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      bindkey '^R' history-incremental-search-backward

      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd 'vv' edit-command-line
    '';
    shellAliases = {
      l = "ls -l";
      ll = "ls -la";

      gl = "git l";
      gst = "git st";

      hms = "home-manager switch --flake ~/projects/nixhome";
    };
  };

  programs.starship.enable = true;
}
