require('which-key').setup {
  preset = "helix",
  expand = 2,
}

-- General

local nmap = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { desc = desc })
end

nmap("<Leader>fe", function() require('oil').open() end, "[F]ile [E]dit")
--nmap("F", require('precognition').peek, "[F]eel the motions inside your mind")

vim.keymap.set('!', "<Esc>", "<C-c>", {desc= "In cmdline, esc should quit not run command"})

-- LSP

local function LSP_binds(bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
  nmap('gI', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
  nmap('<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end, '[D]ocument [S]ymbols')
  nmap('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, '[W]orkspace [S]ymbols')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my-lsp-attach', { clear = true }),
  callback = function(event)
    LSP_binds(event.buf)
  end
})

-- Telescope

local nmap = function(keys, func, desc)
  if desc then
    desc = 'Telescope: ' .. desc
  end

  vim.keymap.set('n', keys, func, { desc = desc })
end

local tele = require('config.telescope')
nmap('<leader>fp', tele.live_grep_git_root, '[F]ile find [P]roject')
nmap('<leader>ff', tele.builtin.find_files, '[F]ile [F]ind')

-- Typst concealer

local nmap = function(keys, func, desc)
  if desc then
    desc = 'Typst: ' .. desc
  end

  vim.keymap.set('n', keys, func, { desc = desc })
end

local typst = require('typst-concealer')
nmap('<leader>t', typst.toggle_buf, "Toggle concealing for buffer")
