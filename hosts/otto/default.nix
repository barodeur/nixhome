{ pkgs, ... }:

{
  imports = [
    ../../profiles/home-manager/git
    ../../profiles/home-manager/git/paul.nix
    ../../profiles/home-manager/gpg/linux.nix
    ../../profiles/home-manager/zsh/linux.nix
    ../../profiles/home-manager/vim
    ../../profiles/home-manager/direnv
    ../../profiles/home-manager/environment
    ../../profiles/home-manager/kubernetes
    ../../profiles/home-manager/tmux
    ../../profiles/home-manager/mise
    ../../profiles/home-manager/vscode
    ../../profiles/home-manager/hyprland
    ../../profiles/home-manager/waybar
  ];

  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "25.11";

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
  };

  home.packages = with pkgs; [
    wget
    grim
    slurp
    nerd-fonts.jetbrains-mono
    pavucontrol
    bluetui
    brightnessctl
    bibata-cursors
    gh
    zed-editor
    libnotify
    jq
    dnsutils
    glow
    btop
    bottom
    opentofu
    sops
    age
    socat

    # Virtualization
    qemu
    virt-manager

    # Build dependencies for compiling language runtimes
    gcc
    gnumake
    python3
    pkg-config
    openssl
    zlib
    readline
    libyaml
    perl
  ];

  xdg.desktopEntries.whatsapp = {
    name = "WhatsApp";
    exec = "flatpak run org.chromium.Chromium --app=https://web.whatsapp.com";
    icon = "org.chromium.Chromium";
    comment = "WhatsApp Web";
    categories = [ "Network" "InstantMessaging" ];
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      HostName = "github.com";
      User = "git";
    };
  };

  services.flatpak.enable = true;
  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "org.chromium.Chromium"
    "org.mozilla.firefox"
    "org.prismlauncher.PrismLauncher"
    "org.scummvm.ScummVM"
    "org.signal.Signal"
    "org.telegram.desktop"
  ];

  # Permissions are declared here rather than clicked into Flatseal, so they
  # survive a reinstall. Flatseal still works for experimenting; write the
  # result back here afterwards.
  services.flatpak.overrides = {
    global.Context.sockets = [ "wayland" "!x11" "fallback-x11" ];
  };

  programs.kitty.enable = true;
  programs.ghostty.enable = true;
  programs.home-manager.enable = true;
}
