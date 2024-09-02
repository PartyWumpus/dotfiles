require("catppuccin").setup({
  flavour = "macchiato",
  itegrations = {
    treesitter = true,
    rainbow_delimiters = true,
  },
  custom_highlights = function(colors)
    return {
      netrwTreeBar = { fg = colors.surface0 },
      LineNr = { fg = colors.subtext0 },
      LineNrAbove = { fg = colors.surface1 },
      LineNrBelow = { fg = colors.surface1 }
    }
  end,
})

vim.cmd [[colorscheme catppuccin]]
