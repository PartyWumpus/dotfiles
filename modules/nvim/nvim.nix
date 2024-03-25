
{ options, config, lib, pkgs, ...}:

{
	home.file.".config/nvim".source = ./lua-config;

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
