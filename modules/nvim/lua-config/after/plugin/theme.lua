require("catppuccin").setup({
  flavour = "macchiato",
  itegrations = {
    treesitter = true,
    rainbow_delimiters = true,
  },
  custom_highlights = function(colors)
    return {
      netrwTreeBar = { fg = colors.surface0 },
    }
  end,
})

vim.cmd [[colorscheme catppuccin]]
