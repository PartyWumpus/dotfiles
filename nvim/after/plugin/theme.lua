require("catppuccin").setup({
	flavour = "macchiato",
	itegrations = {

	},
	custom_highlights = function(colors)
		return {
			netrwTreeBar = { fg = colors.surface0 },
				}
		end,
})

vim.cmd[[colorscheme catppuccin]]

