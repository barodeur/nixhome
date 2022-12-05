{ pkgs, ... }: {

  home.file.".gnupg/scdaemon.conf".text = ''
    disable-ccid
  '';

}
