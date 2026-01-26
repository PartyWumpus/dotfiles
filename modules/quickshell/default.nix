{ inputs }: 
let
  inherit (inputs) quickshell nixpkgs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      quickshellLibs = with pkgs; [
        quickshell.packages.${system}.default
        kdePackages.qtdeclarative
      ];
in
{
  devShell = pkgs.mkShellNoCC {
    nativeBuildInputs = quickshellLibs;
  };
  packages.${system} = pkgs.writeShellApplication {
    name = "bar";
    runtimeInputs = quickshellLibs;
    text = ''
      quickshell -p ${./src}/Bar.qml
    '';
  };


}
