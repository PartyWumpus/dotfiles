local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)



vim.g.mapleader = " "
require("lazy").setup({
	{'ThePrimeagen/vim-be-good'},
	{'nvim-telescope/telescope.nvim', tag = '0.1.5', dependencies = { 'nvim-lua/plenary.nvim' }},
	{"catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{'nvim-treesitter/nvim-treesitter', cmd = 'TSUpdate'},

	{'nvim-tree/nvim-web-devicons'},
	{"nvim-telescope/telescope-frecency.nvim",
		config = function()
			require("telescope").load_extension "frecency"
		end,
	},

	{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
	{'neovim/nvim-lspconfig'},
	{'hrsh7th/cmp-nvim-lsp'},
	{'hrsh7th/nvim-cmp'},
	{'L3MON4D3/LuaSnip'},

	{'lewis6991/hover.nvim'},
	{'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {}},
	{'HiPhish/rainbow-delimiters.nvim'},
	{'nvim-lualine/lualine.nvim'},
})

-- my config
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.wrap = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50
