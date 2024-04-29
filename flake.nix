{
	description = "A highly awesome system configuration.";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";

		neovim.url = "github:neovim/neovim?dir=contrib";

		rust-overlay.url = "github:oxalica/rust-overlay";

		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

		nix-index-database.url = "github:nix-community/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

		hyprlock.url = "github:hyprwm/Hyprlock";
		hyprland.url = "github:hyprwm/Hyprland";

		flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
	};


	outputs = inputs@{ self, nixpkgs, utils, neovim, rust-overlay, home-manager, nix-index-database, hyprland, hyprlock, flatpaks }:	
		let pkgs = import nixpkgs {system="x86_64-linux";}; 
		in utils.lib.mkFlake {
			inherit self inputs;


			# Channel definitions.
			channelsConfig.allowUnfree = true;
			sharedOverlays = [ neovim.overlay ];

			# Modules shared between all hosts
			hostDefaults.modules = [
				flatpaks.nixosModules.default
				./configuration.nix
				home-manager.nixosModules.default {
					home-manager.sharedModules = [
					{imports = [hyprlock.homeManagerModules.hyprlock];}
					];
				}
				nix-index-database.nixosModules.nix-index
			];


			### Hosts ###

			hosts.laptop = {
				modules = [
				./hosts/laptop/configuration.nix
				./hosts/laptop/hardware-configuration.nix
				];
			};


			hosts.desktop = {
				modules = [
				./hosts/desktop/configuration.nix
				./hosts/desktop/hardware-configuration.nix
				];
			};

			devShells.x86_64-linux = import ./devshells {inherit pkgs rust-overlay; };

		} // utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
					overlays = [ (import rust-overlay) ];
        };

      in {
        devShells = import ./devshells { inherit system pkgs; };
      });
}
