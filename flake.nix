{
  description = "My NixOS system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    network_manager_ui = {
      url = "github:Blazzzeee/network_manager_ui?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, network_manager_ui }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit network_manager_ui; };
      modules = [ ./nixos/configuration.nix ];
    };
  };
}
