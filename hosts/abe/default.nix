{ pkgs, ... }:

{
  imports =
    [
      ../../profiles/base
      ../../profiles/common
      ../../profiles/home-manager
      ../../users/paul/darwin.nix
    ];

  networking = {
    hostName = "abe";
    computerName = "abe";
    localHostName = "abe";
  };

  environment.systemPackages = [
    # paul is not an administrator on this machine; `admin` is. So paul
    # builds the system (the nix daemon does that unprivileged) and only
    # the activation runs as admin, from the store path, so admin never
    # has to read paul's home, which it can't.
    (pkgs.writeShellScriptBin "abe-rebuild" ''
      set -euo pipefail
      flake="''${FLAKE_DIR:-$HOME/projects/nixhome}"
      system=$(nix build "$flake#darwinConfigurations.abe.system" --no-link --print-out-paths "$@")

      if [ "$(readlink /run/current-system)" = "$system" ]; then
        echo "abe-rebuild: $system is already active"
        exit 0
      fi

      activate="sudo -H /nix/var/nix/profiles/default/bin/nix-env -p /nix/var/nix/profiles/system --set $system && sudo -H $system/activate"
      if id -Gn | tr ' ' '\n' | grep -qx admin; then
        sh -c "$activate"
      else
        echo "abe-rebuild: activating $system as admin (asks admin's password for su, then sudo)"
        su - admin -c "$activate"
      fi
    '')
  ];
}
