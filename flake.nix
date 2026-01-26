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
    nvf.url = "github:notashelf/nvf/v0.8";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
    plugin-typst-concealer = {
      #url = "github:PartyWumpus/typst-concealer";
      url = "git+file:///home/wumpus/Code/typst-plugin";
      flake = false;
    };
    plugin-screenkey = {
      url = "github:NStefan002/screenkey.nvim";
      flake = false;
    };

    # QS
    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
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

      packages.x86_64-linux.bar =
        (import ./modules/quickshell { inherit inputs; }).packages.x86_64-linux;
      packages.x86_64-linux.qs =
        (import ./modules/quickshell { inherit inputs; }).packages.x86_64-linux;
      packages.x86_64-linux.nvf = (import ./modules/nvf {inherit inputs pkgs;}).neovim;

      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

      devShells.x86_64-linux = import ./devshells { inherit pkgs; } // {
        qs = (import ./modules/quickshell { inherit inputs; }).devShell;
      };

    };
}
