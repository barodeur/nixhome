{ pkgs, config, lib, ... }:

let username = "paul";
in
{
  imports = [ ./common.nix ];

  users.users = { ${username} = { home = "/Users/${username}"; }; };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults.finder.FXPreferredViewStyle = "clmv";
    defaults.trackpad.TrackpadThreeFingerDrag = true;
  };
}
