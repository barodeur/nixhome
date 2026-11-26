{ pkgs, ... }:

let
  platforms = {
    aarch64-darwin = {
      dir = "macos_silicon";
      hash = "sha256-Cpxu6ng6LJEaV2dywCJIhIpfRGv8dztouaUoIklfjEE=";
    };
    x86_64-darwin = {
      dir = "macos_intel";
      hash = "sha256-on2hou2GQ/Pz5pX6cc9lyMi76dVVLKntCwx+qx1vi74=";
    };
    x86_64-linux = {
      dir = "linux";
      hash = "sha256-RDpJBcUh3xhISAX+bnicAqv3lDW0rI/qMhnrOjEVsdU=";
    };
    aarch64-linux = {
      dir = "linux_arm64";
      hash = "sha256-vNcEIQEwomllSaZsjfh5mzfOLqi5aNXWOc6BM5xUKYU=";
    };
  };

  platform = platforms.${pkgs.stdenv.hostPlatform.system};

  gwscli = pkgs.stdenvNoCC.mkDerivation {
    pname = "gwscli";
    version = "1.0.6";

    src = pkgs.fetchurl {
      url = "https://dl.google.com/workspace-cli/${platform.dir}/gwscli";
      inherit (platform) hash;
    };

    dontUnpack = true;

    installPhase = ''
      install -Dm755 $src $out/bin/gwscli
    '';
  };
in
{
  home.packages = [ gwscli ];
}
