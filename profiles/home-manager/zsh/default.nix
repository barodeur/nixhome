{ ... }:

{
  imports = [ ./common.nix ];

  programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
