{
  description = "AGS shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    astal = {
      #url = "github:aylur/astal";
      url = "github:PartyWumpus/astal/wireplumber-improvements";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
  };

  outputs =
    {
      nixpkgs,
      ags,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      astallibs = with ags.packages.${system}; [
        hyprland
        battery
        apps
        wireplumber
        bluetooth
        mpris
        pkgs.libgtop
      ];
      ags_package = (
        ags.packages.${system}.ags.override {
          extraPackages = astallibs;
        }
      );
    in
    {
      packages.${system} = {
        default = ags.lib.bundle {
          inherit pkgs;
          src = ./.;
          name = "ags-desktop";
          entry = "app.ts";

          # additional libraries and executables to add to gjs' runtime
          extraPackages = astallibs;
        };
        ags_bin = ags_package;
      };

      devShells.${system} = {
        default = pkgs.mkShellNoCC {
          nativeBuildInputs = [
            pkgs.watchexec
            ags_package
          ];

        };
      };
    };
}
