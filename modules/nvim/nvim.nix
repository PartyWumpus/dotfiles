
{ options, config, lib, pkgs, ...}:

{
	xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/nvim/lua-config";
	#xdg.configFile."nvim".source = ./lua-config; # use if mkOutOfStoreSymlink doesn't work

	home.packages = with pkgs; [
		neovim
		tree-sitter
		ripgrep
		fd

		# lsp packages
		lua-language-server
		nodePackages.typescript-language-server
		rust-analyzer
		nodePackages.pyright
		nil
	];

	home.sessionVariables.EDITOR = "nvim";

}
