{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , home-manager
    , nixpkgs
    , darwin
    , flake-utils
    , fenix
    }@inputs: {
      overlay = final: prev: { my = self.packages.${final.system}; };

      darwinConfigurations.jamie = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        inherit inputs;
        modules = [ home-manager.darwinModules.home-manager ./hosts/jamie ];
      };

      darwinConfigurations.lois = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        inherit inputs;
        modules = [ home-manager.darwinModules.home-manager ./hosts/lois ];
      };

      darwinConfigurations.piama = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        inherit inputs;
        modules = [ home-manager.darwinModules.home-manager ./hosts/piama ];
      };

      homeConfigurations."paul@otto" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ fenix.overlays.default ];
        };
        modules = [ ./hosts/otto ];
      };
    };
}

