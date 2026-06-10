{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    configure = {
      customLuaRC = ''
        -- THEMES
        vim.opt.number = true
        vim.o.background = "dark"
        vim.cmd("highlight Normal guibg=#000000")
        vim.cmd("highlight NormalNC guibg=#000000")
        vim.opt.statuscolumn = ""
        vim.opt.cursorline = true
        local suisei_hl = vim.api.nvim_create_augroup("SuiseiHighlight", { clear = true })

        vim.api.nvim_create_autocmd("ColorScheme", {
          group = suisei_hl,
          pattern = "*",
          callback = function()
            vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#5EBCF6', bold = true })
              vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#161616'})
            end,
        })
        vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#5EBCF6', bold = true })
        vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#161616'})
        -- END OF THEMES

        -- TABBING
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        vim.opt.softtabstop = 2
        vim.opt.smarttab = true
        vim.opt.autoindent = true
        vim.opt.smartindent = true
        vim.opt.backspace = { "indent", "eol", "start" }
        -- END OF TABBING
        
        -- ACTIVATE PLUGINS

        -- Autopairs
        require('nvim-autopairs').setup({
          disable_filetype = { "TelescopePrompt" , "vim" },
        })

        -- Nvim-tree-lua
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        vim.opt.termguicolors = true
        ---@type nvim_tree.config
        local config = {
          sort = {
            sorter = "case_sensitive",
          },
          view = {
            width = 26,
          },
        }
        require("nvim-tree").setup(config)
        vim.keymap.set('n', '<M-e>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

        -- Nvim-treesitter-context
        require'treesitter-context'.setup{
          enable = true,
          max_lines = 1,
          line_numbers = true,
          mode = 'topline',
        }

        -- Indent-blankline-nvim
        require("ibl").setup()

        -- Cmp
        local cmp = require('cmp') 
        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body) 
            end,
          },
          mapping = cmp.mapping.preset.insert({            
            ['<M-q>'] = cmp.mapping.abort(),                    
            ['<M-w>'] = cmp.mapping.confirm({ select = true }),
            
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { 'i', 's' }),

            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { 'i', 's' }),
          }),

          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'treesitter' },
          })
        })

        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        local default_servers = { 
          'clangd', 
          'rust_analyzer', 
          'pyright', 
          'bashls', 
          'nil_ls' 
        }

        for _, lsp in ipairs(default_servers) do
          vim.lsp.config(lsp, {
            capabilities = capabilities,
          })
          vim.lsp.enable(lsp)
        end

        vim.lsp.config('lua_ls', {
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' }
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
              },
              telemetry = {
                enable = false,
              },
            }
          }
        })
        vim.lsp.enable('lua_ls')

        -- END OF ACTIVATE PLUGINS

        --ADDITIONAL OPTIONS
        vim.opt.mouse = 'a'

      '';

      packages.haruSuiseiNeovim = with pkgs.vimPlugins; {
        start = [
          nvim-autopairs
          nvim-tree-lua
          nvim-treesitter-context
          nvim-treesitter.withAllGrammars
          indent-blankline-nvim
          cmp-treesitter
          cmp-nvim-lsp
          nvim-cmp
          nvim-lspconfig
          luasnip
        ];
      };
    };
  };
}
