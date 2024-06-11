{
	description = "A highly awesome system configuration.";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";

		neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

		rust-overlay.url = "github:oxalica/rust-overlay";

		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

		nix-index-database.url = "github:nix-community/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

		hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

		flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
	};


	outputs = inputs@{ self, nixpkgs, utils, rust-overlay, home-manager, nix-index-database, hyprland, flatpaks, ... }:
		let pkgs = self.pkgs.x86_64-linux.nixpkgs;
		in utils.lib.mkFlake {
			inherit self inputs;

			# https://discourse.nixos.org/t/how-to-create-a-timestamp-in-a-nix-expression/30329
			# seems to be behind an hour because of timezone fuckery and defaulting to utc but still does its job
			timestamp = nixpkgs.lib.readFile "${pkgs.runCommand "timestamp" { env.when = builtins.currentTime; } "echo -n `date -d @$when +%Y-%m-%d_%H-%M-%S` > $out"}";

			# Channel definitions.
			channelsConfig.allowUnfree = true;
			#sharedOverlays = [ neovim.overlay ];

			# Modules shared between all hosts
			hostDefaults.modules = [
				flatpaks.nixosModules.default
				./configuration.nix
				home-manager.nixosModules.default {
					home-manager.sharedModules = [
					{imports = [
						#hyprlock.homeManagerModules.hyprlock
					];}
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
