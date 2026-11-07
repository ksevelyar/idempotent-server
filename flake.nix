{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    habits-axum.url = "github:ksevelyar/habits-axum";
    habits-axum.inputs.nixpkgs.follows = "nixpkgs";
    habits-vue.url = "github:ksevelyar/habits-vue";
    habits-vue.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    disko,
    agenix,
    habits-axum,
    ...
  } @ inputs: let
    nix_system = "x86_64-linux";
    pkgs = import nixpkgs {
      system = nix_system;
    };
  in {
    # nixos-rebuild switch --flake .#cluster-0 --target-host root@cluster-0 --no-reexec
    nixosConfigurations.cluster-0 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        agenix.nixosModules.default
        ./hosts/cluster-0.nix
      ];
      specialArgs.inputs = inputs;
    };

    # nixos-anywhere -- --flake .#cluster-1 --target-host root@77.238.239.218 --ssh-port 9922
    nixosConfigurations.cluster-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        agenix.nixosModules.default
        ./hosts/cluster-1.nix
      ];
      specialArgs.inputs = inputs;
    };

    # nixos-anywhere -- --flake .#installer root@cluster-0
    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./hosts/installer.nix
      ];
    };

    formatter.${nix_system} = pkgs.alejandra;

    devShells.${nix_system}.default = pkgs.mkShell {
      packages = [
        inputs.agenix.packages.${nix_system}.default
        inputs.nixos-anywhere.packages.${nix_system}.default
        (pkgs.writeShellApplication {
          name = "size";
          runtimeInputs = with pkgs; [coreutils gawk];
          text = ''
            system_path="$(readlink -f /run/current-system)"
            nix path-info -rSh "$system_path" | tail -n 1 | awk '{print $2, $3}'
          '';
        })
        (pkgs.writeShellApplication {
          name = "format";
          text = "nix fmt -- --exclude ./.git .";
        })
      ];
    };
  };
}
