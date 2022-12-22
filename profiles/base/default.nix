{ inputs, pkgs, ... }:
let
  inherit (inputs) self nixpkgs fenix;
in
{
  services.nix-daemon.enable = true;

  nixpkgs.overlays = [
    fenix.overlays.default
  ];
}
