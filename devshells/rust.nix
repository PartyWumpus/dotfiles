{ pkgs, ... }:
pkgs.mkShell {
	name = "rust-dev";

	packages = [
		pkgs.cargo
	];
}
