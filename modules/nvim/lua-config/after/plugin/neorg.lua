vim.keymap.set("n", "<localleader>ns",
  -- go to top of file, delete all lines below, and generate workspace summary
  "<cmd>:1<cr><cmd>+,$d<cr><cmd>Neorg generate-workspace-summary<cr>", {
    desc = "[Neorg] Generate summary"
  })
vim.keymap.set("n", "<localleader>ne", "<cmd>Neorg index<cr>", {
  desc = "[Neorg] Enter notes"
})
