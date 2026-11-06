{
  description = "whatever Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      mkNixosConfiguration = hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          hostPath
          home-manager.nixosModules.home-manager
          {
            _module.args.inputs = self.inputs;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        argus = mkNixosConfiguration ./hosts/argus/configuration.nix;
        tiny-slab-delta = mkNixosConfiguration ./hosts/tiny-slab-delta/configuration.nix;
        futro = mkNixosConfiguration ./hosts/futro/configuration.nix;
        slab = mkNixosConfiguration ./hosts/slab/configuration.nix;
        tiny-slab-alpha = mkNixosConfiguration ./hosts/tiny-slab-alpha/configuration.nix;
        tiny-slab-beta = mkNixosConfiguration ./hosts/tiny-slab-beta/configuration.nix;
      };
    };
}
