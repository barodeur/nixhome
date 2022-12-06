{ pkgs, services, ... }: {

  programs.gpg = {
    enable = true;

    scdaemonSettings = { disable-ccid = true; };
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    max-cache-ttl 18000
    default-cache-ttl 18000
    pinentry-program /run/current-system/sw/bin/pinentry-curses
    enable-ssh-support
  '';

}
