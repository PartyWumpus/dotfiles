{
  description = "A highly awesome system configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    rust-overlay.url = "github:oxalica/rust-overlay";

    ags.url = "github:/Aylur/ags";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    #spicetify-nix = {
    #  url = "github:Gerg-L/spicetify-nix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    #lix-module.url = "git+https://git.lix.systems/lix-project/nixos-module";
    #lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.90.0.tar.gz";
    #lix-module.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      utils,
      rust-overlay,
      home-manager,
      nix-index-database,
      hyprland,
      flatpaks,
      ags,
      ...
    }:
    let
      pkgs = self.pkgs.x86_64-linux.nixpkgs;
      eachSystem = utils.lib.eachDefaultSystem;
      hmModules = [
        ags.homeManagerModules.default
        #hyprlock.homeManagerModules.hyprlock
      ];
    in
    utils.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" ];

      location = "/home/wumpus/nixos";
      # https://discourse.nixos.org/t/how-to-create-a-timestamp-in-a-nix-expression/30329
      # seems to be behind an hour because of timezone fuckery and defaulting to utc but still does its job
      my_timestamp = nixpkgs.lib.readFile "${pkgs.runCommand "timestamp" {
        env.when = builtins.currentTime;
      } "echo -n `date -d @$when +%Y-%m-%d_%H-%M-%S` > $out"}";

      # Channel definitions.
      channelsConfig.allowUnfree = true;
      #sharedOverlays = [ neovim.overlay ];

      # Modules shared between all hosts
      hostDefaults.modules = [
        #lix-module.nixosModules.default # i am stupid so this is not working
        flatpaks.nixosModules.default
        ./configuration.nix
        home-manager.nixosModules.default
        { home-manager.sharedModules = [ { imports = hmModules; } ]; }
        nix-index-database.nixosModules.nix-index
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

      #formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
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
          overlays = [ (import rust-overlay) ];
        };

      in
      {
        devShells = import ./devshells { inherit system pkgs; };
      }
    );
}
