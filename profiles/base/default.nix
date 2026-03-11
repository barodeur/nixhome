{ inputs, pkgs, ... }:
let
  inherit (inputs) self nixpkgs fenix;
in
{
  # Managed by Determinate Nix installer. If darwin-rebuild disappears
  # from PATH after reboot, check that org.nixos.activate-system is
  # allowed in System Settings > General > Login Items (it shows as
  # a /bin/sh item). Verify with: sfltool dumpbtm | grep -B2 activate-system
  nix.enable = false;

  nixpkgs.overlays = [
    fenix.overlays.default
  ];
}
