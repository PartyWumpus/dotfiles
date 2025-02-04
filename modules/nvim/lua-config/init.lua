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
vim.g.maplocalleader = ","

require("lazy").setup({
  { 'ThePrimeagen/vim-be-good' },
  { 'nvim-telescope/telescope.nvim',   tag = '0.1.5',       dependencies = { 'nvim-lua/plenary.nvim' } },
  { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },
  { 'nvim-treesitter/nvim-treesitter', cmd = 'TSUpdate' },
  { 'Saghen/blink.cmp' },

  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = { -- set to setup table
    },
  },

  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        '<c-up>',
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
    },
  },

  { 'nvim-tree/nvim-web-devicons' },
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    event = "VeryLazy",
    config = function()
      require('tiny-devicons-auto-colors').setup({
        colors = require("catppuccin.palettes").get_palette("macchiato")
      })
    end
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      expand = 2,
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  { 'tris203/precognition.nvim',  event = "VeryLazy" },

  --[[{
    '3rd/image.nvim',
    event = "VeryLazy",
    config = function()
      require("image").setup({
        backend = "kitty",
      })
    end
  },]] --
  --[[{
    "nvim-neorg/neorg",
    event = "VeryLazy",
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      require("neorg").setup {

        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.summary"] = {},
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
          ["core.latex.renderer"] = {},
        },
      }

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  },]] --


  {
    dir = '~/Code/typst-plugin',
    name = 'typst-concealer',
    config = function()
      local typst = require('typst-concealer')
      typst.setup {}

      vim.keymap.set("n", "<leader>ts", function()
        typst.enable_buf(vim.fn.bufnr())
      end, { desc = "[typst-concealer] re-render" })
      vim.keymap.set("n", "<leader>th", function()
        typst.disable_buf(vim.fn.bufnr())
      end, { desc = "[typst-concealer] clear" })
    end,
    event = "VeryLazy"
  },
  --{ 'PartyWumpus/typst-concealer', config = function() require('typst-concealer').setup() end },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

  { "Bilal2453/luvit-meta",                lazy = true }, -- optional `vim.uv` typings

  { 'VonHeikemen/lsp-zero.nvim',           branch = 'v3.x' },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/nvim-cmp' },
  { 'L3MON4D3/LuaSnip',                    event = "VeryLazy" },

  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl',      opts = {} },
  { 'HiPhish/rainbow-delimiters.nvim',     event = "VeryLazy" },
  { 'nvim-lualine/lualine.nvim' },

})


-- my config
vim.keymap.set("n", "<leader>pv", "<cmd>Yazi<cr>", { desc = "File explorer" })
vim.keymap.set("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Replace" })

vim.opt.wildoptions = { "tagfile" }
vim.opt.gdefault = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.wrap = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

vim.opt.fileformats = "unix,dos,mac"

print("hiii :3")
