{
  description = "Nathaniel's opinionated (and probably slightly dumb) nix config forked from kieran's";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # agenix
    agenix.url = "github:ryantm/agenix";

    # catppuccin
    catppuccin.url = "github:catppuccin/nix/1e4c3803b8da874ff75224ec8512cb173036bbd8";
    catppuccin-vsc.url = "https://flakehub.com/f/catppuccin/vscode/\*.tar.gz";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    lix-module,
    agenix,
    home-manager,
    hyprland-contrib,
    ghostty,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    unstable-overlays = {
      nixpkgs.overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
    };
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      zoomies = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {inherit inputs outputs;};

        # > Our main nixos configuration file <
        modules = [
          lix-module.nixosModules.default
          inputs.disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          agenix.nixosModules.default
          ./zoomies/configuration.nix
          unstable-overlays
        ];
      };
    };
  };
}
