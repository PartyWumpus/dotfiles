require('telescope').setup {
	extensions = {
		frecency = {
			show_scores = true,
			show_unindexed = true,
		}
	},
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({search = vim.fn.input("Search: ")})
end)


