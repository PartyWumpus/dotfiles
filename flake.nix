{
  description = "A highly awesome system configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    #spicetify-nix = {
    #  url = "github:Gerg-L/spicetify-nix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    hyprland.url = "git+https://github.com/hyprwm/Hyprland";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";

    catppuccin.url = "github:catppuccin/nix";

    my-ags.url = "path:./modules/hyprland/ags/";
    my-nvim.url = "path:./modules/nvim";

    #lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
    #lix-module.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ (import inputs.rust-overlay) ];
      };
      hmModules = [
        inputs.catppuccin.homeManagerModules.catppuccin
      ];
      nixosModules = [
        inputs.flatpaks.nixosModules.declarative-flatpak
        inputs.catppuccin.nixosModules.catppuccin
        ./configuration.nix
        home-manager.nixosModules.default
        {
          home-manager.sharedModules = [ { imports = hmModules; } ];
        }
        inputs.nix-index-database.nixosModules.nix-index
      ];
    in
    {
      inherit self inputs;

      location = "/home/wumpus/nixos";
      # https://discourse.nixos.org/t/how-to-create-a-timestamp-in-a-nix-expression/30329
      # seems to be behind an hour because of timezone fuckery and defaulting to utc but still does a job
      my_timestamp = nixpkgs.lib.readFile "${pkgs.runCommandLocal "timestamp" { }
        "echo -n `date -d @${toString builtins.currentTime} +%Y-%m-%d_%H-%M-%S` > $out"
      }";

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self inputs; };
        modules = [
          ./hosts/laptop/configuration.nix
          ./hosts/laptop/hardware-configuration.nix
        ] ++ nixosModules;
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self inputs; };
        modules = [
          ./hosts/desktop/configuration.nix
          ./hosts/desktop/hardware-configuration.nix
        ] ++ nixosModules;
      };

nixosConfigurations.thespare = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self inputs; };
        modules = [
          ./hosts/thespare/configuration.nix
          ./hosts/thespare/hardware-configuration.nix
        ] ++ nixosModules;
      };

      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

      devShells.x86_64-linux = import ./devshells { inherit pkgs; };
    };
}
