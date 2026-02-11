{ ... }:

{
  imports = [ ./common.nix ];

  programs.zsh.initContent = ''
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  '';

  programs.zsh.shellAliases.hms = "home-manager switch --flake ~/projects/nixhome";
}
