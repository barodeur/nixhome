{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # otto's system runs the stable release. flake.lock pins the revision;
    # bump deliberately with `nix flake update nixpkgs-stable`.
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

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

    # Omarchy, for its themes only. Read as data at eval time — each
    # themes/<name>/colors.toml is 24 semantic colour keys and nothing else —
    # so none of Omarchy is built, installed or run; see
    # profiles/home-manager/theme. "quattro" is their default branch, and the
    # theme layout changed with it, so the ref is explicit.
    omarchy = {
      url = "github:basecamp/omarchy/quattro";
      flake = false;
    };

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
    , omarchy
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
            # The theme profile reads its palettes out of the omarchy input.
            home-manager.extraSpecialArgs = { inherit inputs; };
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

