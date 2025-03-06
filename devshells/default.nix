{ pkgs, ... }:
{
  rust = pkgs.callPackage ./rust.nix { };
  ags = pkgs.callPackage ./ags.nix { };
}
