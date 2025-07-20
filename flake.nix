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

    # NEOVIM
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    plugin-typst-concealer = {
      url = "github:PartyWumpus/typst-concealer";
      #url = "git+file:///home/wumpus/Code/typst-plugin";
      flake = false;
    };
    plugin-screenkey = {
      url = "github:NStefan002/screenkey.nvim";
      flake = false;
    };

    # AGS
    astal = {
      #url = "github:aylur/astal";
      url = "github:PartyWumpus/astal/wireplumber-improvements";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags?rev=a6a7a0adb17740f4c34a59902701870d46fbb6a4";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
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
        inputs.catppuccin.homeModules.catppuccin
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

      packages.x86_64-linux.nvim = (import ./modules/nvim { inherit inputs; }).packages.x86_64-linux.nvim;
      packages.x86_64-linux.nvim_impure =
        (import ./modules/nvim { inherit inputs; }).packages.x86_64-linux.impure;

      packages.x86_64-linux.bar =
        (import ./modules/hyprland/ags { inherit inputs; }).packages.x86_64-linux.default;
      packages.x86_64-linux.ags =
        (import ./modules/hyprland/ags { inherit inputs; }).packages.x86_64-linux.default;

      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

      devShells.x86_64-linux = import ./devshells { inherit pkgs; } // {
        ags = (import ./modules/hyprland/ags { inherit inputs; }).devShells.x86_64-linux.default;
      };
    };
}
