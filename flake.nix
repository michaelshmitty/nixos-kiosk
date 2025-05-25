{
  description = "Manage infrastructure using Nix";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
  };

  outputs = {
    self,
    nixpkgs,
    devshell,
    nixos-hardware,
  } @ inputs: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system:
        function (import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlays.default
          ];
        }));
  in {
    nixosConfigurations = {
      pinix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./modules/common/nix
          ./modules/server
          ./machines/pinix
        ];
      };
    };

    formatter = forAllSystems (pkgs: pkgs.alejandra);

    devShells = forAllSystems (pkgs: {
      default = pkgs.devshell.mkShell {
        name = "NixOS Configuration";
        packages = with pkgs; [
          nixos-rebuild
        ];
        commands = [
          {
            name = "config:deploy";
            help = ''
              Use as `config:deploy HOST {switch|build} EXTRA_ARGS`.
              Assumes you have a valid ssh configuration for HOST in ~/.ssh/config
            '';
            command = ''
              host=$1 # Assign first ARGV to host
              shift # Remove host from ARGV
              nixos-rebuild --flake ".#$host" \
              --build-host $host \
              --target-host $host \
              --use-remote-sudo \
              --fast \
              "$@"
            '';
          }
        ];
      };
    });
  };
}
