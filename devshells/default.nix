{pkgs, ... }:
{
  #decky = nixpkgs.callPackage ./decky.nix {};
	rust = pkgs.callPackage ./rust.nix {};
	ags = pkgs.callPackage ./ags.nix {};
}
