# macOS gpg for the YubiKey. The agent itself is started by nix-darwin's
# programs.gnupg.agent (profiles/common), which also sets SSH_AUTH_SOCK, so
# this only configures it rather than running a second one.
{ pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    publicKeys = [{
      source = ./pgp.pub;
      trust = 5;
    }];
    # Reach the YubiKey through macOS's PC/SC service rather than gpg's
    # own CCID driver, which fights the OS for the device.
    scdaemonSettings = { disable-ccid = true; };
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    enable-ssh-support
    default-cache-ttl 3600
    max-cache-ttl 7200
  '';
}
