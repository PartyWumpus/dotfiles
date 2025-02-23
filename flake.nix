{
  description = "A highly awesome system configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";

    #neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    rust-overlay.url = "github:oxalica/rust-overlay";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    #spicetify-nix = {
    #  url = "github:Gerg-L/spicetify-nix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";

    catppuccin.url = "github:catppuccin/nix";

    ags.url = "path:./modules/hyprland/ags/";

    #lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
    #lix-module.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      utils,
      home-manager,
      ...
    }:
    let
      pkgs = self.pkgs.x86_64-linux.nixpkgs;
      eachSystem = utils.lib.eachDefaultSystem;
      hmModules = [
        inputs.catppuccin.homeManagerModules.catppuccin
        #hyprlock.homeManagerModules.hyprlock
      ];
    in
    utils.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" ];
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      location = "/home/wumpus/nixos";
      # https://discourse.nixos.org/t/how-to-create-a-timestamp-in-a-nix-expression/30329
      # seems to be behind an hour because of timezone fuckery and defaulting to utc but still does its job
      my_timestamp = nixpkgs.lib.readFile "${pkgs.runCommandLocal "timestamp" { }
        "echo -n `date -d @${toString builtins.currentTime} +%Y-%m-%d_%H-%M-%S` > $out"
      }";

      # Channel definitions.
      channelsConfig.allowUnfree = true;
      #sharedOverlays = [ neovim.overlay ];

      # Modules shared between all hosts
      hostDefaults.modules = [
        inputs.flatpaks.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
        ./configuration.nix
        home-manager.nixosModules.default
        { home-manager.sharedModules = [ { imports = hmModules; } ]; }
        inputs.nix-index-database.nixosModules.nix-index
        #inputs.spicetify-nix.nixosModules.default
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

      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

      homeConfigurations."wumpus" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ] ++ hmModules;
        extraSpecialArgs = {
          inherit inputs;
        };
      };

    }
    // eachSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ (import inputs.rust-overlay) ];
        };

      in
      {
        devShells = import ./devshells { inherit system pkgs; };
      }
    );
}
