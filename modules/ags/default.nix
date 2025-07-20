
    {
      inputs,
      ...
    }:
    let
      inherit (inputs) ags nixpkgs;

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      astallibs = with ags.packages.${system}; [
        hyprland
        battery
        apps
        wireplumber
        bluetooth
        notifd
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
    }
