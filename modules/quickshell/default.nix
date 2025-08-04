{ inputs }: 
let
  inherit (inputs) quickshell nixpkgs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
in
{
  devShell = pkgs.mkShellNoCC {
    nativeBuildInputs = with pkgs; [
      quickshell.packages.${system}.default
      kdePackages.qtdeclarative
    ];
  };
}
