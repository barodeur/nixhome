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
    '';
    shellAliases.hms = "home-manager switch --flake ~/projects/nixhome";
  };

  programs.starship.enable = true;
}
