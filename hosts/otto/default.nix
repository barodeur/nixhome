{ pkgs, ... }:

{
  imports = [
    ../../profiles/home-manager/git
    ../../profiles/home-manager/git/paul.nix
    ../../profiles/home-manager/gpg/linux.nix
    ../../profiles/home-manager/zsh/linux.nix
    ../../profiles/home-manager/vim
    ../../profiles/home-manager/environment
    ../../profiles/home-manager/hyprland
    ../../profiles/home-manager/waybar
  ];

  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "25.11";

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables.SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";

  home.packages = with pkgs; [
    nodejs
    wget
    prismlauncher
    grim
    slurp
    nerd-fonts.jetbrains-mono
    pavucontrol
    bluetui
    brightnessctl
    bibata-cursors
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
    };
  };

  programs.kitty.enable = true;
  programs.ghostty.enable = true;
  programs.firefox.enable = true;
  programs.home-manager.enable = true;
}
