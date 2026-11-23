{ pkgs, config, lib, ... }:

let username = "paul";
in
{
  imports = [ ./common.nix ];

  users.users = { ${username} = { home = "/Users/${username}"; }; };

  system.primaryUser = username;
  system.stateVersion = 6;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      NSGlobalDomain = {
        # In 15 ms units, faster than the System Settings sliders go
        # (their fastest is 2 / 15).
        KeyRepeat = 1;
        InitialKeyRepeat = 10;
        # Held keys repeat instead of opening the accent picker.
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
      };

      finder = {
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
        # Search the current folder rather than the whole Mac.
        FXDefaultSearchScope = "SCcf";
        _FXSortFoldersFirst = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      screencapture.location = "/Users/${username}/Screenshots";
    };
  };

  # screencapture falls back to the Desktop if its folder is missing.
  home-manager.users.${username} = { lib, ... }: {
    home.activation.screenshotsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/Screenshots"
    '';
  };
}
