{ ... }:

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
}
