{pkgs,  rust-overlay, ... }:
{
  #decky = nixpkgs.callPackage ./decky.nix {};
	rust = pkgs.callPackage ./rust.nix { inherit rust-overlay; };
}
