return {
  "nvim-treesitter",
  after = function()
    require('nvim-treesitter.configs').setup({
      highlight = {
        enable = true,
      },
    })
  end
}
