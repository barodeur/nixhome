{ pkgs, lib, ... }:

let
  pcKeyboard = { vendorId = 1241; productId = 41165; };

  capsLock = 30064771129;
  escape = 30064771113;
  leftAlt = 30064771298;
  leftCommand = 30064771299;
  rightAlt = 30064771302;
  rightCommand = 30064771303;

  remap = src: dst: {
    HIDKeyboardModifierMappingSrc = src;
    HIDKeyboardModifierMappingDst = dst;
  };

  pcKeyboardMapping = [
    (remap capsLock escape)
    (remap leftAlt leftCommand)
    (remap leftCommand leftAlt)
    (remap rightAlt rightCommand)
    (remap rightCommand rightAlt)
  ];

  mappingDict = m: ''
    <dict><key>HIDKeyboardModifierMappingSrc</key><integer>${toString m.HIDKeyboardModifierMappingSrc}</integer><key>HIDKeyboardModifierMappingDst</key><integer>${toString m.HIDKeyboardModifierMappingDst}</integer></dict>'';
in
{
  home-manager.users.paul = { lib, ... }: {
    home.activation.pcKeyboardModifiers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run /usr/bin/defaults -currentHost write -g \
        com.apple.keyboard.modifiermapping.${toString pcKeyboard.vendorId}-${toString pcKeyboard.productId}-0 \
        -array ${lib.concatMapStringsSep " " (m: "'${mappingDict m}'") pcKeyboardMapping}
      run /usr/bin/hidutil property \
        --matching '{"VendorID":${toString pcKeyboard.vendorId},"ProductID":${toString pcKeyboard.productId}}' \
        --set '{"UserKeyMapping":${builtins.toJSON pcKeyboardMapping}}' > /dev/null
    '';
  };

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
