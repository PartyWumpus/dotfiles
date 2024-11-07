require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'catppuccin',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {
      { 'mode', fmt = function(str) return str:sub(1, 1) end }
    },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {
      { 'filename',
        path = 0,
        shorting_target = 20,
        symbols = {
          modified = '*',
          readonly = '',
          unnamed = '[No Name]',
          newfile = '[New]',
        }
      } },
    lualine_x = { 'encoding', { 'filetype', icon_only = true } },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      { 'filename',
        path = 1, -- relative path instead of just filename
        symbols = {
          modified = '*',
          readonly = '',
          unnamed = '[No Name]',
          newfile = '[New]',
        },
        shorting_target = 5
      }
    },
    lualine_x = { 'filetype', 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
