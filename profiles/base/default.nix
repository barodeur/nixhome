{ inputs, pkgs, ... }:
let
  inherit (inputs) self nixpkgs fenix;
in
{
  nix.enable = false;

  nixpkgs.overlays = [
    fenix.overlays.default
  ];
}
