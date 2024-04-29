{ pkgs, ... }:
pkgs.mkShell {
	name = "rust-dev";

	packages = [
		pkgs.rust-bin.stable.latest.default
	];
}
