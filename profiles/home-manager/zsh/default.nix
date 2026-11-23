{ ... }:

{
  imports = [ ./common.nix ];

  programs.zsh.initContent = ''
    # Only hosts that still have Homebrew (piama); abe is Nix-only.
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
