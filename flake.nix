{
  description = "Multi-system nix configuration with Everforest theme";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { self, nixpkgs, darwin, home-manager, ... }:
  let
    # macOS M2
    darwinSystem = "aarch64-darwin";
    darwinPkgs = import nixpkgs { 
      system = darwinSystem;
      config.allowUnfree = true;
    };
    
    # NixOS Intel
    linuxSystem = "x86_64-linux";
    linuxPkgs = import nixpkgs { 
      system = linuxSystem;
      config.allowUnfree = true;
    };
  in {
    # macOS configuration
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = darwinSystem;
      pkgs = darwinPkgs;
      modules = [
        ./darwin/configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.{user} = import ./darwin/home.nix;
        }
      ];
    };
    
    # NixOS configuration
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      pkgs = linuxPkgs;
      modules = [
        ./nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.{user} = import ./nixos/home.nix;
        }
      ];
    };
  };
}