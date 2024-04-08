{
	description = "A highly awesome system configuration.";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";

		neovim.url = "github:neovim/neovim?dir=contrib";

		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

		nix-index-database.url = "github:nix-community/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

		#flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
	};


	outputs = inputs@{ self, nixpkgs, utils, neovim, home-manager, nix-index-database }:
		utils.lib.mkFlake {
			inherit self inputs;

			# Channel definitions.
			channelsConfig.allowUnfree = true;
			sharedOverlays = [ neovim.overlay ];

			# Modules shared between all hosts
			hostDefaults.modules = [
				./configuration.nix
				home-manager.nixosModules.default
				nix-index-database.nixosModules.nix-index
				#inputs.flatpaks.homeManagerModules.default
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

		};
}
