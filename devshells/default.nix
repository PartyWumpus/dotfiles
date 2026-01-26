{ pkgs, ... }:
{
  rust = pkgs.callPackage ./rust.nix { };
}
