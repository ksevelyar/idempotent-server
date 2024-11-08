{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.inputs.darwin.follows = "";
    };

    habits-phoenix = {
      url = "github:ksevelyar/habits-phoenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    disko,
    agenix,
    habits-phoenix,
    ...
  }: {
    # firstvds
    # nixos-rebuild switch --flake .#cluster-0 --target-host root@cluster-0 --fast
    nixosConfigurations.cluster-0 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./disko-vda.nix
        disko.nixosModules.disko
        agenix.nixosModules.default
        habits-phoenix.nixosModules.default
        ./hosts/cluster-0.nix
      ];
    };
    # nix run github:nix-community/nixos-anywhere -- --flake .#installer root@cluster-0
    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./hosts/installer.nix
      ];
    };
  };
}
