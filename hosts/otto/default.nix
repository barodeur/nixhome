{ config, pkgs, ... }:

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
    ../../profiles/home-manager/theme
    ../../profiles/home-manager/hyprland
    ../../profiles/home-manager/waybar
    ../../profiles/home-manager/eden
  ];

  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "25.11";

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
  };

  home.packages = with pkgs; [
    # Home-manager runs as a NixOS module on this host, so one rebuild
    # applies system and home together.
    (writeShellScriptBin "otto-rebuild" ''
      set -euo pipefail
      flake="''${FLAKE_DIR:-$HOME/projects/nixhome}"
      sudo nixos-rebuild switch --flake "$flake#otto"
    '')

    nautilus
    wget
    grim
    slurp
    nerd-fonts.jetbrains-mono
    pavucontrol
    bluetui
    brightnessctl
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
    nixpkgs-fmt

    # Runs AppImages under an FHS sandbox. Their bundled binaries are prebuilt
    # against a standard filesystem layout and can't resolve their libraries on
    # NixOS — the wt desktop app's Electron misses 27 of them without this.
    # ~/.local/share/applications/wt.desktop (written by wt's `make install`)
    # invokes it directly, so the launcher entry is dead until this is present.
    appimage-run

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

  # Hand-edited mimeapps.list had drifted: http/https pointed at
  # "firefox.desktop" and sgnl:// at "signal.desktop", neither of which exists
  # — the flatpaks export org.mozilla.firefox.desktop and
  # org.signal.Signal.desktop. A dangling association is skipped in silence
  # rather than reported, so https fell through to Chromium, which is only
  # installed to host WhatsApp.
  xdg.mimeApps =
    let
      firefox = [ "org.mozilla.firefox.desktop" ];
      signal = [ "org.signal.Signal.desktop" ];
      telegram = [ "org.telegram.desktop.desktop" ];
    in
    {
      enable = true;
      defaultApplications = {
        "text/html" = firefox;
        "application/xhtml+xml" = firefox;
        "application/x-extension-htm" = firefox;
        "application/x-extension-html" = firefox;
        "application/x-extension-shtml" = firefox;
        "application/x-extension-xht" = firefox;
        "application/x-extension-xhtml" = firefox;
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
        "x-scheme-handler/chrome" = firefox;

        "x-scheme-handler/sgnl" = signal;
        "x-scheme-handler/signalcaptcha" = signal;
        "x-scheme-handler/tg" = telegram;
        "x-scheme-handler/tonsite" = telegram;

        # Written by Claude Code into ~/.local/share/applications, not by this
        # config; the association is ours to keep, the .desktop file is not.
        "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
      };
    };

  # profileDirectory resolves to /etc/profiles/per-user/paul under the NixOS
  # module's useUserPackages; ~/.nix-profile no longer has hm-session-vars.sh.
  programs.bash = {
    enable = true;
    initExtra = ''
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
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
    "com.valvesoftware.Steam"
    "com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
    "im.riot.Riot"
    "net.lutris.Lutris"
    "org.chromium.Chromium"
    # Runtime extension, so the ref carries the runtime version rather than a
    # "stable" branch. When Steam's runtime moves off 25.08 this ref stops
    # resolving and the install fails loudly; bump the branch to match.
    "runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/25.08"
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

    "com.valvesoftware.Steam".Context = {
      # The Steam client is X11-only and so are many games. The global
      # "fallback-x11" only grants X11 when no Wayland socket exists, and under
      # Hyprland one always does. It must be negated as well as granting x11:
      # flatpak checks fallback-x11 first and, when Wayland is up, that branch
      # denies X11 outright and the plain "x11" grant never gets consulted.
      # The cost is that anything Steam runs can snoop other Xwayland clients'
      # input; native Wayland apps stay out of reach.
      sockets = [ "x11" "!fallback-x11" ];

      # Drop the removable-media and secondary-mount access the manifest ships
      # with. Games live in ~/.var/app/com.valvesoftware.Steam on the single
      # internal disk, so nothing needs these.
      filesystems = [ "!/mnt" "!/media" "!/run/media" ];
    };

    "im.riot.Riot" = {
      # Element keeps the pickle key that unlocks the local session in
      # Electron's safeStorage, which reaches gnome-keyring over the Secret
      # Service bus name. The manifest never requests that name, so inside the
      # sandbox it does not resolve at all and Element degrades to storing the
      # key in the clear.
      "Session Bus Policy"."org.freedesktop.secrets" = "talk";

      # Reaching the daemon is only half of it. Chromium picks its password
      # store from XDG_CURRENT_DESKTOP and does not recognise "Hyprland", so it
      # would still select the plaintext backend; claiming GNOME is what makes
      # it choose gnome-libsecret. Element records the backend it wrote with
      # and passes --password-store itself on subsequent starts.
      Environment.XDG_CURRENT_DESKTOP = "GNOME";
    };

    "net.lutris.Lutris".Context = {
      # Same X11 reasoning as Steam: Lutris runs Wine games, which are X11-only.
      sockets = [ "x11" "!fallback-x11" ];

      # Lutris ships filesystems=home, i.e. read-write over ~/.ssh, ~/.gnupg and
      # everything else. That is the whole reason we went to Flatpak, so revoke
      # it and hand back only a game directory. Its own ~/.var/app data and the
      # read-only Steam library it imports from are unaffected by "!home".
      filesystems = [ "!home" "~/Games:create" "!/media" "!/run/media" ];
    };

    "org.prismlauncher.PrismLauncher".Context = {
      # The launcher itself is Qt and happy on Wayland, but the Minecraft it
      # spawns initializes GLFW on the X11 platform, so without a DISPLAY the
      # game crashes at startup ("The DISPLAY environment variable is
      # missing"). Same fallback-x11 negation dance as Steam.
      sockets = [ "x11" "!fallback-x11" ];
    };
  };

  programs.kitty.enable = true;

  programs.ghostty = {
    enable = true;
    # Ghostty follows the desktop colour scheme by default, which would drag the
    # terminal into light mode along with everything else. Pinning the theme it
    # already used in dark mode opts it out; it stays dark in both.
    settings.theme = "Ghostty Default Style Dark";
  };
}
