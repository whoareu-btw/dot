vim.opt.winborder = 'rounded'
vim.opt.signcolumn = "yes"
--vim.opt.updatetime = 250
--vim.opt.timeoutlen = 300

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ManualLspConfig", { clear = false }),
  callback = function(args)

    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set('i', '<M-d>', '<C-x><C-o>', opts)

    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, opts)
    
    vim.keymap.set('i', '<C-k>', function()
      vim.lsp.buf.signature_help({ border = "rounded" })
    end, opts)

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  end,
})
