{
  description = "My NixOS system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    network_manager_ui = {
      url = "github:Blazzzeee/network_manager_ui?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    assets = {
      url = "git+ssh://git@github.com/Apmds/nixos-config-assets.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, spicetify, network_manager_ui, assets, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit network_manager_ui; };
      modules = [ ./nixos/configuration.nix ];
    };

    homeConfigurations."apmds" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit spicetify assets; };
      modules = [ ./home-manager/home.nix ];
    };
  };
}
