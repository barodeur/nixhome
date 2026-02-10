# { pkgs, services, ... }: {

#   # programs.gpg = {
#   #   enable = false;

#   #   scdaemonSettings = { disable-ccid = true; };
#   # };

#   home.file.".gnupg/gpg-agent.conf".text = ''
#     max-cache-ttl 18000
#     default-cache-ttl 18000
#     pinentry-program "/Applications/Nix Apps/pinentry-mac.app/Contents/MacOS/pinentry-mac"
#     enable-ssh-support
#   '';

# }
