# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # /boot is 1G and every generation carries a kernel + initrd.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kept for reference: the mt7925e workaround, removed 2026-07-29 on the
  # assumption that kernel 7.1.5 carries the deadlock fixes that were expected
  # in 6.19+. That assumption is UNVERIFIED — the failure mode is a hang or a
  # dead wifi interface while roaming on 6GHz, and no 6GHz roam has happened
  # since. Restore this and rebuild if that turns up.
  # See https://github.com/zbowling/mt7925
  #
  # boot.extraModprobeConfig = ''
  #   options mt7925e disable_aspm=Y
  #   options mt7925-common disable_clc=1
  # '';

  boot.initrd.luks.devices."luks-214a2870-8273-4821-8dea-5afacc278ae9".device = "/dev/disk/by-uuid/214a2870-8273-4821-8dea-5afacc278ae9";
  networking.hostName = "otto"; # Define your hostname.
  networking.domain = "chobert.net";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking. This was previously switched on implicitly by the GNOME
  # desktop module; it has to be explicit now that GNOME is gone, or the host
  # falls back to dhcpcd with no wpa_supplicant and loses wifi entirely.
  networking.networkmanager.enable = true;

  networking.networkmanager.wifi.powersave = false;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;

  # Configure keymap in X11. The variant matches the Hyprland session's
  # us(mac), so GDM's password prompt types the same layout as the desktop.
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
    options = "caps:escape";
  };

  # Virtual consoles use the xkb layout above instead of plain us.
  console.useXkbConfig = true;

  # Declared explicitly rather than inherited from the GNOME desktop module,
  # which this host does not use (only Hyprland sessions are ever launched).
  # The hyprland portal comes from the home-manager hyprland profile; gtk is
  # what GTK apps and flatpaks use for file chooser and settings.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  services.fwupd.enable = true;

  # CPU power profile switching (balanced/power-saver/performance). GNOME used
  # to pull this in; without it the machine always runs the firmware default.
  services.power-profiles-daemon.enable = true;

  # Hold the battery at 80% while on the charger: living at 100% is what ages
  # the cell. Reapplied every boot because the EC forgets the limit on some
  # resets (firmware updates, battery disconnect). For a travel day, override
  # with `sudo framework-tool --charge-limit 100`; this restores 80% on the
  # next boot.
  systemd.services.battery-charge-limit = {
    description = "Set battery charge limit to 80%";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # The package is framework-tool but the binary it ships is framework_tool.
      ExecStart = "${pkgs.framework-tool}/bin/framework_tool --charge-limit 80";
    };
  };

  # Lets waybar's battery-module picker switch the limit without a password
  # prompt. Exact commands only: framework_tool can also flash the EC, so no
  # wildcard.
  security.sudo.extraRules = [{
    users = [ "paul" ];
    commands = map
      (limit: {
        command = "${pkgs.framework-tool}/bin/framework_tool --charge-limit ${limit}";
        options = [ "NOPASSWD" ];
      }) [ "80" "100" ];
  }];

  # Trash, MTP and drive mounting for nautilus, which runs outside GNOME here.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Also previously implicit via GNOME. Network printer discovery needs mDNS.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.flatpak.enable = true;

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--accept-routes" ];
  };

  # Required for --accept-routes: strict reverse path filtering drops packets
  # arriving over subnet routes.
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.paul = {
    isNormalUser = true;
    description = "Paul Chobert";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
    shell = pkgs.zsh;
  };

  # Install Hyperland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # 1Password through the NixOS modules rather than raw packages: they install
  # the setuid 1Password-BrowserSupport helper and the polkit policy that
  # browser unlock and CLI biometric auth depend on.
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "paul" ];
  };

  virtualisation = {
    # Rootless only. The rootful daemon plus `docker` group membership is
    # equivalent to passwordless root (`docker run -v /:/host ...`).
    docker = {
      enable = false;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    libvirtd.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.nix-ld.enable = true;


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Disable USB autosuspend for YubiKey to prevent it appearing as unplugged.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{power/autosuspend}="-1"
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # The system is built from this flake, not from a channel. Leaving channels
  # enabled would only keep a stale nixpkgs in root's profile that nothing reads.
  nix.channel.enable = false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
