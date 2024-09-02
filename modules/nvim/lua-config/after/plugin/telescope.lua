require('telescope').setup {
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Search filenames" })
vim.keymap.set('n', '<leader>fs', function() -- fs = file search
  builtin.grep_string({ search = vim.fn.input("Search: ") })
end, { desc = "Search text in files" })
