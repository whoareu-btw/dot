{ pkgs, ... }: 

{
    programs.neovim = {
        enable = true; 
        configure = {
            customLuaRC = ''
                vim.opt.number = true
                vim.o.background = "dark"
                vim.cmd("highlight Normal guibg=#000000")
                vim.cmd("highlight NormalNC guibg=#000000")
                vim.g.mapleader = " "
                vim.keymap.set('n', '<M-e>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

                require("nvim-tree").setup({
                    sort_by = "case_sensitive",
                    view = { width = 26, side = "left" },
                })

                require('treesitter-context').setup({ enable = true, max_lines = 1 })
                require('nvim-treesitter.configs').setup({
                    highlight = { enable = true, additional_vim_regex_highlighting = false },
                })

                require('nvim-autopairs').setup({
                    disable_filetype = { "TelescopePrompt" , "vim" },
                })

                local cmp = require('cmp')
                local cmp_autopairs = require('nvim-autopairs.completion.cmp')
                
                cmp.setup({
                    snippet = {
                        expand = function(args)
                            require('luasnip').lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    }),
                    sources = cmp.config.sources({
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                        { name = 'path' },
                    })
                })
                cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

                vim.lsp.config.bashls = vim.tbl_deep_extend('force', vim.lsp.config.bashls or {}, {
                    filetypes = { 'sh', 'bash' }
                })
                vim.lsp.config.lua_ls = vim.tbl_deep_extend('force', vim.lsp.config.lua_ls or {}, {
                    settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
                })

                vim.lsp.enable('rust_analyzer')
                vim.lsp.enable('clangd')
                vim.lsp.enable('pyright')
                vim.lsp.enable('bashls')
                vim.lsp.enable('lua_ls')

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

                require("ibl").setup()
            '';

            packages.haruBlackNeovim = with pkgs.vimPlugins; {
                start = [
                    nvim-treesitter.withAllGrammars
                    nvim-tree-lua
                    nvim-web-devicons
                    nvim-treesitter-context
		            nvim-cmp
                    cmp-nvim-lsp
                    cmp-path
                    cmp_luasnip 
                    nvim-autopairs
                    luasnip
                    indent-blankline-nvim
                ];
            };
        };
    };
}
