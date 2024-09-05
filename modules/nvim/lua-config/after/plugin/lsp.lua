local lsp_zero = require('lsp-zero')

-- https://lsp-zero.netlify.app/v3.x/language-server-configuration.html

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({ buffer = bufnr })
end)

-- set up language servers

local lua_opts = lsp_zero.nvim_lua_ls()
require('lspconfig').lua_ls.setup(lua_opts)

require('lspconfig').ts_ls.setup({})
require('lspconfig').rust_analyzer.setup({})
require('lspconfig').pyright.setup({})
require('lspconfig').nixd.setup({})
require('lspconfig').astro.setup({})


local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  })
})

-- format on save (source https://www.mitchellhanberg.com/modern-format-on-save-in-neovim/)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format { async = false, id = args.data.client_id }
      end,
    });
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.norg",
      callback = function()
        local buf = vim.fn.bufadd("/home/wumpus/notes/index.norg")
      end,
    })
  end
})
