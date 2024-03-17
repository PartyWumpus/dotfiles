require('telescope').setup {
	extensions = {
		frecency = {
			show_scores = true,
			show_unindexed = true,
		},
	}
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- ff = file find
vim.keymap.set('n', '<leader>fs', function() -- fs = file search
	builtin.grep_string({search = vim.fn.input("Search: ")})
end)
vim.keymap.set("n", "<leader>fr", "<Cmd>Telescope frecency<CR>") -- fr = file recent
