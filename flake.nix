{
  description = "Kieran's opinionated (and probably slightly dumb) nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Lix
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS hardware configuration
    hardware.url = "github:NixOS/nixos-hardware/master";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    
    # agenix
    agenix.url = "github:ryantm/agenix";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # catppuccin
    catppuccin.url = "github:catppuccin/nix";
    catppuccin-vsc.url = "https://flakehub.com/f/catppuccin/vscode/\*.tar.gz";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    lix-module,
    nix-flatpak,
    cursor,
    agenix,
    home-manager,
    nixos-hardware,
    hyprland-contrib,
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
      moonlark = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {inherit inputs outputs;};

        # > Our main nixos configuration file <
        modules = [
          lix-module.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          inputs.disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          agenix.nixosModules.default
          ./moonlark/configuration.nix
          unstable-overlays
        ];
      };
    };
  };
}
