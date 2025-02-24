-- CONFIG
vim.opt.wildoptions = { "tagfile" }
vim.opt.gdefault = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8

require('config.colorscheme')

-- TODO: more lze :3
require('mini.icons').setup()
require('mini.icons').mock_nvim_web_devicons()
require('todo-comments').setup()

require('config.binds')
require('config.lsp')
require('config.lualine')
--require('config.typst-concealer')

require("lze").load {
  {
    "oil.nvim",
    after = function()
      require('config.oil')
    end,
  },
  { import = "config.treesitter" },
  { import = "config.gitsigns" },
  { import = "config.screenkey" },
  { "vim-fugitive" },
}
