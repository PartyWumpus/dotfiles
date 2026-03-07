# TODO:
# - some binds?

{
  inputs,
  pkgs,
}:
let
  inherit (inputs) nvf neovim-nightly-overlay;
in
nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    (
      { pkgs, ... }:
      {
        config.vim = {
          # experimental, if something breaks try disabling this
          enableLuaLoader = true;
          options = {
            gdefault = true;
            wrap = false;
            scrolloff = 4;
            tabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            inccommand = "split";
            undofile = true;
          };
          theme = {
            enable = true;
            name = "catppuccin";
            style = "macchiato";
            extraConfig = # lua
              ''
                require("catppuccin").setup({
                  custom_highlights = function(colors)
                    return {
                      netrwTreeBar = { fg = colors.surface0 },
                      LineNr = { fg = colors.subtext0 },
                      LineNrAbove = { fg = colors.surface1 },
                      LineNrBelow = { fg = colors.surface1 }
                    }
                  end
                })
              '';
          };
          diagnostics = {
            enable = true;
            config = {
              virtual_lines = true;
              signs = false;
            };
          };
          mini.icons.enable = true;
          visuals = {
            cellular-automaton.enable = true;
            nvim-web-devicons.enable = true;
            rainbow-delimiters.enable = true;
            # TODO: investigate
            #fidget-nvim.enable = true;
            nvim-scrollbar = {
              enable = true;
              setupOpts = {
                show_in_active_only = true;
                handlers = {
                  cursor = true;
                  diagnostic = true;
                  gitsigns = true;
                  handle = true;
                };
              };
            };
          };
          treesitter.grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
          treesitter.enable = true;
          autocomplete.blink-cmp.enable = true;
          languages = {
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;


            nix = {
              enable = true;
              lsp = {
                enable = true;
                server = "nixd";
              };
            };

            rust = {
              enable = true;
              lsp.enable = true;
            };

            python = {
              enable = true;
              lsp.enable = true;
            };

            kotlin = {
              enable = true;
              lsp.enable = true;
            };

            qml = {
              enable = true;
              format.enable = true;
              lsp.enable = true;
            };

          };
          binds = {
            whichKey = {
              enable = true;
              setupOpts = {
                preset = "helix";
                expand = 2;
              };
            };
            cheatsheet.enable = true;
          };
          git = {
            gitsigns = {
              enable = true;
              setupOpts = {
                signcolumn = false;
                current_line_blame = true;
                current_line_blame_opts = {
                  virt_text = true;
                  virt_text_pos = "eol";
                  delay = 100;
                  ignore_whitespace = true;
                  virt_text_priority = 100;
                  use_focus = true;
                };
              };
            };
          };
          utility = {
            undotree.enable = true;
            oil-nvim = {
              enable = true;
              setupOpts = {
                columns = [
                  "icon"
                ];
              };
            };
          };
          package = neovim-nightly-overlay.packages.x86_64-linux.neovim;
        };
      }
    )
    (
      { pkgs, ... }:

      {
        config.vim = {
          telescope = {
            enable = true;
          };
        };
      }

    )
    (
      { pkgs, ... }:

      {
        config.vim = {
          extraPlugins = {
            "vimplugin-screenkey" = {
              package = (
                pkgs.vimUtils.buildVimPlugin {
                  name = "screenkey";
                  src = inputs.plugin-screenkey;
                }
              );
              setup = ''
                require('screenkey').setup({
                                win_opts = {
                                  row = 0;
                                  relative = "editor";
                                  anchor = "NE";
                                  width = 25;
                                  height = 1;
                                  border = "single";
                                  title = "Input History";
                                  title_pos = "center";
                                  style = "minimal";
                                  focusable = false;
                                  noautocmd = true;
                                };
                                compress_after = 3;
                                clear_after = 3;
                                show_leader = true;
                                group_mappings = true;

                              })'';
            };
          };
        };
      }

    )
    (
      { pkgs, ... }:
      {
        config.vim = {
          keymaps = [
            {
              key = "<leader>fe";
              mode = [ "n" ];
              lua = true;
              action = "function() require('oil').open() end";
              desc = "[F]ile [E]dit";
            }
            {
              key = "K";
              mode = [ "n" ];
              lua = true;
              action = "vim.lsp.buf.hover";
              desc = "Hover Documentation";
            }
            {
              key = "gr";
              mode = [ "n" ];
              lua = true;
              action = "function() require('telescope.builtin').lsp_references() end";
              desc = "[G]oto [R]eferences";
            }
            {
              key = "gI";
              mode = [ "n" ];
              lua = true;
              action = "function() require('telescope.builtin').lsp_implementations() end";
              desc = "[G]oto [I]mplementation";
            }
            {
              key = "<leader>ds";
              mode = [ "n" ];
              lua = true;
              action = "function() require('telescope.builtin').lsp_document_symbols() end";
              desc = "[D]ocument [S]ymbols";
            }
            {
              key = "<leader>ws";
              mode = [ "n" ];
              lua = true;
              action = "function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end";
              desc = "[W]orkspace [S]ymbols";
            }
            {
              key = "<leader>D";
              mode = [ "n" ];
              lua = true;
              action = "vim.lsp.buf.type_definition";
              desc = "Type [D]efinition";
            }
            {
              key = "<C-k>";
              mode = [ "n" ];
              lua = true;
              action = "vim.lsp.buf.signature_help";
              desc = "Signature Documentation";
            }
            {
              key = "gD";
              mode = [ "n" ];
              lua = true;
              action = "vim.lsp.buf.declaration";
              desc = "[G]oto [D]eclaration";
            }
            {
              key = "rs";
              mode = [ "n" ];
              lua = true;
              action = "vim.lsp.buf.rename";
              desc = "[R]ename [S]ymbol";
            }

          ];
        };
      }
    )
    (
      { pkgs, ... }:
      {
        config.vim = {
          extraPlugins = {
            dropbar = {
              package = pkgs.vimPlugins.dropbar-nvim;
              setup = # lua
                ''
                  require('dropbar').setup({
                  })
                '';
            };
          };
          /*
            lazy.plugins.dropbar-nvim = {
              package = pkgs.vimPlugins.dropbar-nvim;
              setupModule = "dropbar";
              setupOpts = {};
              after = "print('hii')";
            };
          */
        };
      }
    )
    (
      { pkgs, ... }:
      {
        config.vim = {
          statusline.lualine = {
            enable = true;
            setupOpts = {
              winbar = {
                lualine_c = pkgs.lib.generators.mkLuaInline ''{{ "%{%v:lua.dropbar()%}", color = "nil" }}'';
              };
              inactive_winbar = {
                lualine_a =
                  pkgs.lib.generators.mkLuaInline # lua
                    ''
                      {{ 
                        "filename", 
                        color = { bg = "nil" },
                        symbols = {modified = ' ', readonly = ' '},
                        shorting_target = 3,
                        path = 1
                      }}
                    '';
              };
            };
            activeSection = {
              a = [
                # lua
                ''
                  {
                    "mode",
                    icons_enabled = true,
                    fmt = function(str) return str:sub(1, 3) end,
                    separator = {
                      right = ''
                    },
                  }
                ''
                # lua
                ''
                  {
                    "",
                    draw_empty = true,
                    separator = { left = '', right = '' }
                  }
                ''
              ];
              b = [
                # lua
                ''
                  {
                    "branch",
                    icon = ' •',
                    separator = {right = ''}
                  }
                ''
                # lua
                ''
                  {
                    "diff",
                    separator = {right = ''}
                  }
                ''
                # lua
                ''
                  {
                    "",
                    draw_empty = true,
                    separator = { left = '', right = '' }
                  }
                ''
              ];
              c = [
                # lua
                ''
                  {
                    "filename",
                    symbols = {modified = ' ', readonly = ' '},
                    path = 0,
                    separator = {right = ''}
                  }
                ''
              ];
              x = [
                # lua
                ''
                  {
                    "diagnostics",
                    separator = { left = '', right = '' },
                    sources = {'nvim_lsp', 'nvim_diagnostic', 'nvim_diagnostic', 'vim_lsp', 'coc'},
                    symbols = {error = '󰅙 ', warn = ' ', info = ' ', hint = '󰌵'},
                    colored = true,
                    update_in_insert = false,
                    always_visible = false,
                    diagnostics_color = {
                      color_error = { fg = 'red' },
                      color_warn = { fg = 'yellow' },
                      color_info = { fg = 'cyan' },
                    },
                  }
                ''
              ];

              y = [
                # lua
                ''
                  {
                    "",
                    draw_empty = true,
                    separator = { left = '', right = '' }
                  }
                ''
                # lua
                ''
                  {
                    'searchcount',
                    maxcount = 999,
                    timeout = 120,
                    separator = {left = ''}
                  }
                ''
                # lua
                ''
                  {
                    "progress",
                    separator = {left = ''}
                  }
                ''
              ];

              z = [
                # lua
                ''
                  {
                  "location",
                  separator = { left = '', right = '' }
                  }
                ''
              ];
            };
          };
        };
      }
    )
  ];
}
