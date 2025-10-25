local dropbar_api = require('dropbar.api')
vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })

local config = require('dropbar.configs').opts
config.bar.enable = function(buf, win, _)
  vim.print(vim.fn.win_gettype(win))
  if
    not vim.api.nvim_buf_is_valid(buf)
    or not vim.api.nvim_win_is_valid(win)
    or vim.fn.win_gettype(win) ~= ''
    or vim.wo[win].winbar ~= ''
    or vim.bo[buf].ft == 'help'
  then
    return false
  end

  local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
  if stat and stat.size > 1024 * 1024 then
    return false
  end

  return vim.bo[buf].ft == 'markdown'
    or pcall(vim.treesitter.get_parser, buf)
    or not vim.tbl_isempty(vim.lsp.get_clients({
      bufnr = buf,
      method = vim.lsp.protocol.Methods.textDocument_documentSymbol,
    }))
  
end

local menu_utils = require "dropbar.utils.menu"

    -- Closes all the windows in the current dropbar.
    local function close()
      local menu = menu_utils.get_current()
      while menu and menu.prev_menu do
        menu = menu.prev_menu
      end
      if menu then
        menu:close()
      end
    end

    return {
      general = {
        -- Remove the 'OptionSet' event since it causes weird issues with modelines.
        attach_events = { "BufWinEnter", "BufWritePost" },
        update_events = {
          -- Remove the 'WinEnter' event since I handle it manually for just
          -- showing the full dropbar in the current window.
          win = { "CursorMoved", "CursorMovedI", "WinResized" },
        },
      },
      icons = {
        ui = {
          -- Tweak the spacing around the separator.
          -- bar = { separator = "  " }, -- use this when in x,y,z position in lualine
          bar = { separator = "  " },
          menu = { separator = "" },
        },
        -- Keep the LSP icons used in other parts of the UI.
        kinds = {
          symbols = vim.tbl_map(function(symbol)
            return symbol .. " "
          end, require("user.icons").kind),
        },
      },
      bar = {
        pick = {
          -- Use the same labels as flash.
          pivots = "asdfghjklqwertyuiopzxcvbnm",
        },
        sources = function()
          local sources = require "dropbar.sources"
          local utils = require "dropbar.utils.source"
          --[[ local filename = {
            get_symbols = function(buff, win, cursor)
              local symbols = sources.path.get_symbols(buff, win, cursor)
              return { symbols[#symbols] }
            end,
          } ]]

          return {
            -- filename,
            {
              get_symbols = function(buf, win, cursor)
                if vim.api.nvim_get_current_win() ~= win then
                  return {}
                end

                if vim.bo[buf].ft == "markdown" then
                  return sources.markdown.get_symbols(buf, win, cursor)
                end
                return utils.fallback({ sources.lsp, sources.treesitter }).get_symbols(buf, win, cursor)
              end,
            },
          }
        end,
      },
      menu = {
        win_configs = { border = "rounded" },
        keymaps = {
          -- Navigate back to the parent menu.
          ["h"] = "<C-w>c",
          -- Expands the entry if possible.
          ["l"] = function()
            local menu = menu_utils.get_current()
            if not menu then
              return
            end
            local row = vim.api.nvim_win_get_cursor(menu.win)[1]
            local component = menu.entries[row]:first_clickable()
            if component then
              menu:click_on(component, nil, 1, "l")
            end
          end,
          -- "Jump and close".
          ["o"] = function()
            local menu = menu_utils.get_current()
            if not menu then
              return
            end
            local cursor = vim.api.nvim_win_get_cursor(menu.win)
            local entry = menu.entries[cursor[1]]
            local component = entry:first_clickable(entry.padding.left + entry.components[1]:bytewidth())
            if component then
              menu:click_on(component, nil, 1, "l")
            end
          end,
          -- Close the dropbar entirely with <esc> and q.
          ["q"] = close,
          ["<esc>"] = close,
        },
      },
    }
