{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, disko, ... }:
    {
      # nixos-anywhere install : 
      # nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --flake .#generic --target-host user@ip 

      # nixos-rebuild switch --flake .#knix-0 --target-host root@192.168.1.100
      # nixos-rebuild switch --flake .#knix-1 --target-host root@192.168.1.101
      # nixos-rebuild switch --flake .#knix-2 --target-host root@192.168.1.102
      nixosConfigurations = {
        # Bootstrap only: nixos-anywhere ... --flake .#knix-0-init
        knix-0-init = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./nodes/knix-0/configuration.nix
            ./nodes/knix-0/hardware-configuration.nix
            ({ lib, ... }: { services.k3s.clusterInit = true; services.k3s.serverAddr = lib.mkForce ""; })
          ];
        };
        knix-0 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./nodes/knix-0/configuration.nix
            ./nodes/knix-0/hardware-configuration.nix
          ];
        };
        knix-1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./nodes/knix-1/configuration.nix
            ./nodes/knix-1/hardware-configuration.nix
          ];
        };
        knix-2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./nodes/knix-2/configuration.nix
            ./nodes/knix-2/hardware-configuration.nix
          ];
        };
    };
  };
}
