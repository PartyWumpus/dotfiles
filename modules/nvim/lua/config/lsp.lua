local servers = {}
servers.lua_ls = {
  Lua = {
    formatters = {
      ignoreComments = true,
    },
    signatureHelp = { enabled = true },
    diagnostics = {
      globals = { 'nixCats' },
      disable = {},
    },
  },
  telemetry = { enabled = false },
  filetypes = { 'lua' },
}

servers.nixd = {}
servers.ts_ls = {}
servers.clangd = {}
servers.astro = {}
servers.pyright = {}
servers.rust_analyzer = {}

servers.tinymist = {
  single_file_support = true,
  offset_encoding = "utf-8",
  settings = {
    formatterMode = "typstyle",
    exportPdf = "never",
    semanticTokens = "disable"
  }
}

local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(),
  require('blink.cmp').get_lsp_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true


for server_name, cfg in pairs(servers) do
  require('lspconfig')[server_name].setup({
    capabilities = capabilities,
    settings = cfg,
    filetypes = (cfg or {}).filetypes,
    cmd = (cfg or {}).cmd,
    root_pattern = (cfg or {}).root_pattern,
  })
end

require('blink.cmp').setup({
  keymap = {
    preset = "default",
    ["<Up>"] = { "select_prev", "snippet_backward", "fallback" },
    ["<Down>"] = { "select_next", "snippet_forward", "fallback" },
    ["<Tab>"] = { "select_and_accept", "fallback" },
    ["<Esc>"] = { "cancel", "fallback" },
    --["<PageUp>"] = { "scroll_documentation_up", "fallback" },
    --["<PageDown>"] = { "scroll_documentation_down", "fallback" },
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
  },
  completion = {
    menu = {
      auto_show = function(ctx) return ctx.mode == 'cmdline' end,
      draw = { columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } } }
    },
    list = { selection = { preselect = true, auto_insert = false } },
    documentation = { auto_show = true, auto_show_delay_ms = 100 },
    ghost_text = { enabled = true },
  },
})


require('lazydev').setup()
