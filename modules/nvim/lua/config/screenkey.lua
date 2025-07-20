return {
  "vimplugin-screenkey",
  after = function()
    require("screenkey").setup({
      win_opts = {
        row = 0,
        col = vim.o.columns - 1,
        relative = "editor",
        anchor = "NE",
        width = 25,
        height = 1,
        border = "single",
        title = "Input History",
        title_pos = "center",
        style = "minimal",
        focusable = false,
        noautocmd = true,
      },
      compress_after = 3,
      clear_after = 3,
      show_leader = true,
      group_mappings = true,
    })
  end
}
