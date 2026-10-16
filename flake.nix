{
  description = "whatever Flake";

  inputs = {
    nixpkgs-tiny-slab-one.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager-tiny-slab-one.url = "github:nix-community/home-manager/release-26.05";
    home-manager-tiny-slab-one.inputs.nixpkgs.follows = "nixpkgs-tiny-slab-one";

    nixpkgs-tiny-slab-too.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager-tiny-slab-too.url = "github:nix-community/home-manager/release-26.05";
    home-manager-tiny-slab-too.inputs.nixpkgs.follows = "nixpkgs-tiny-slab-too";
  };

  outputs =
    { self,
      nixpkgs-tiny-slab-one,
      home-manager-tiny-slab-one,
      nixpkgs-tiny-slab-too,
      home-manager-tiny-slab-too,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        tiny-slab-one = nixpkgs-tiny-slab-one.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/tiny-slab-one/configuration.nix
            home-manager-tiny-slab-one.nixosModules.home-manager {
              home-manager = {
                users.whatever = import ./home.nix;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }
            {
              _module.args.inputs = self.inputs;
            }
          ];
        };

        tiny-slab-too = nixpkgs-tiny-slab-too.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/tiny-slab-too/configuration.nix
            home-manager-tiny-slab-too.nixosModules.home-manager {
              home-manager = {
                users.whatever = import ./home.nix;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }
            {
              _module.args.inputs = self.inputs;
            }
          ];
        };
      };
    };
}
