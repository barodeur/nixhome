{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  users.users = { paul = { home = "/Users/paul"; }; };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults.trackpad.TrackpadThreeFingerDrag = true;
  };
}
