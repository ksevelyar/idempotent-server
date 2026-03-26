{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    habits-phoenix.url = "github:ksevelyar/habits-phoenix";
    habits-phoenix.inputs.nixpkgs.follows = "nixpkgs";
    habits-vue.url = "github:ksevelyar/habits-vue";
    habits-vue.inputs.nixpkgs.follows = "nixpkgs";

    buzz-phoenix.url = "github:ksevelyar/buzz-phoenix";
    buzz-phoenix.inputs.nixpkgs.follows = "nixpkgs";
    buzz-vue.url = "github:ksevelyar/buzz-vue";
    buzz-vue.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    disko,
    agenix,
    habits-phoenix,
    ...
  }@inputs: {
    # firstvds
    # nixos-rebuild switch --flake .#cluster-0 --target-host root@cluster-0 --fast
    nixosConfigurations.cluster-0 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        agenix.nixosModules.default
        habits-phoenix.nixosModules.default
        ./hosts/cluster-0.nix
      ];
      specialArgs.inputs = inputs;
    };

    # nixos-anywhere -- --flake .#cluster-1 --target-host root@194.154.28.217
    nixosConfigurations.cluster-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        agenix.nixosModules.default
        habits-phoenix.nixosModules.default
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

    devShells.x86_64-linux.default = (import nixpkgs {system = "x86_64-linux";}).mkShell {
      buildInputs = with (import nixpkgs {system = "x86_64-linux";}); [
        inputs.agenix.packages.${pkgs.system}.default
        inputs.nixos-anywhere.packages.${pkgs.system}.default
        cpio
      ];
    };
  };
}
