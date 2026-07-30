{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # otto's system runs the stable release, pinned to the exact revision the
    # channel-based config was on at migration time so the switch is a no-op.
    # Bump deliberately with `nix flake update nixpkgs-stable`.
    nixpkgs-stable.url = "github:nixos/nixpkgs/2f5a153c270b70cb0f8c11f46d96d6d3bc39f4e3";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For otto, whose whole closure builds from nixpkgs-stable. The release
    # branch must match the nixpkgs-stable release.
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";

    # Hardware quirks for otto (Framework 13 AMD AI 300). Modules only, no
    # nixpkgs of its own to follow.
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    { self
    , home-manager
    , home-manager-stable
    , nixpkgs
    , nixpkgs-stable
    , darwin
    , flake-utils
    , fenix
    , nix-flatpak
    , nixos-hardware
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

      darwinConfigurations.cmpc = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        inherit inputs;
        modules = [ home-manager.darwinModules.home-manager ./hosts/cmpc ];
      };

      # System and home in one configuration: home-manager runs as a NixOS
      # module, so `nixos-rebuild switch` applies both atomically, all from
      # nixpkgs-stable.
      nixosConfigurations.otto = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/otto/system
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          home-manager-stable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.paul.imports = [
              nix-flatpak.homeManagerModules.nix-flatpak
              ./hosts/otto
            ];
          }
        ];
      };

      homeConfigurations."paul@x86_64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./hosts/devcontainer ];
      };

      homeConfigurations."paul@aarch64-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [ ./hosts/devcontainer ];
      };
    };
}

