{pkgs,  ... }:
{
  #decky = nixpkgs.callPackage ./decky.nix {};
	rust = pkgs.callPackage ./rust.nix {};
}
