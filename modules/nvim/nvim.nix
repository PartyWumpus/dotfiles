
{ inputs, options, config, lib, pkgs, ...}:

{
	xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/nvim/lua-config";
	#xdg.configFile."nvim".source = ./lua-config; # use if mkOutOfStoreSymlink doesn't work

	home.packages = with pkgs; [
		inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
		tree-sitter
		ripgrep
		fd

		# lsp packages
		lua-language-server
		nodePackages.typescript-language-server
		rust-analyzer
		pyright
		nil
	];

	home.sessionVariables.EDITOR = "nvim";

}
