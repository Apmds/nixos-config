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
    sway-screenshot = {
      url = "github:Gustash/sway-screenshot";
      flake = false;
    };
    network_manager_ui = {
      url = "github:Blazzzeee/network_manager_ui?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, spicetify, sway-screenshot, network_manager_ui }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit network_manager_ui; };
      modules = [ ./nixos/configuration.nix ];
    };

    homeConfigurations."apmds" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit spicetify sway-screenshot; };
      modules = [ ./home-manager/home.nix ];
    };
  };
}
