{ pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    publicKeys = [{
      source = ./pgp.pub;
      trust = 5;
    }];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
