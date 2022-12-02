{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  users.users = { paul= { home = "/Users/paul"; }; };
}
