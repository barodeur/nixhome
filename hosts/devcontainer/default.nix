{ pkgs, lib, ... }:

{
  imports = [
    ../../profiles/home-manager/git
    ../../profiles/home-manager/git/paul.nix
    ../../profiles/home-manager/zsh/linux.nix
    ../../profiles/home-manager/direnv
    ../../profiles/home-manager/tmux
  ];

  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    bat
    curl
    fd
    fzf
    gh
    htop
    jq
    mise
    ripgrep
    vim
  ];

  programs.home-manager.enable = true;

  home.file.".bash_env".text = ''
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    export PATH="$HOME/.local/share/mise/shims:$PATH"
  '';

  home.sessionVariablesExtra = ''
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  '';

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.gnupg/S.gpg-agent.ssh";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home.sessionPath = [
    "$HOME/.local/share/mise/shims"
  ];

  home.file.".ssh/known_hosts".text = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';

  programs.tmux.terminal = lib.mkForce "xterm-256color";
  programs.tmux.extraConfig = lib.mkAfter ''
    set-option -g default-command "zsh"
    set -as terminal-overrides ',xterm*:Tc'
    set -q -g status-utf8 on
    setw -q -g utf8 on
  '';

  programs.zsh.initContent = lib.mkAfter ''
    eval "$(mise activate zsh)"
  '';

  programs.zsh.history = {
    path = "$HOME/.zsh_history_dir/.zsh_history";
    size = 10000;
    save = 10000;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(mise activate bash)"
    '';
  };
}
