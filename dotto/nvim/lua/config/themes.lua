-- Dark mode
vim.opt.number = true
vim.o.background = "dark"
vim.cmd("highlight Normal guibg=#000000")
vim.cmd("highlight NormalNC guibg=#000000")

-- Number line color
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
