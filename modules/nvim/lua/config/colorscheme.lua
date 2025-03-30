if nixCats('colorscheme') == "catppuccin" then
  require("catppuccin").setup({
    flavour = "macchiato",
    itegrations = {
      treesitter = true,
      rainbow_delimiters = true,
      gitsigns = true,
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

  local U = require("catppuccin.utils.colors")
  local C = require("catppuccin.palettes").get_palette(require("catppuccin").flavour)

  -- sensible gitsigns stuff
  vim.api.nvim_set_hl(0, "GitSignsAddInline", {bg=U.darken(C.green, 0.36, C.base)})
  vim.api.nvim_set_hl(0, "GitSignsChangeInline", {bg=U.darken(C.red, 0.36, C.base)})
  vim.api.nvim_set_hl(0, "GitSignsDeleteInline", {bg=U.darken(C.yellow, 0.36, C.base)})

  -- Undercurls instead of underlines (vim api overrides instead of modifying)
  vim.cmd [[
    hi DiagnosticUnderlineError gui=undercurl
    hi DiagnosticUnderlineWarn gui=undercurl
  ]]

else
  vim.cmd("colorscheme" .. nixCats('colorscheme'))
end

