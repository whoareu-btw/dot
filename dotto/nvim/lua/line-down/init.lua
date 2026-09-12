vim.opt.list = true
vim.opt.listchars:append({
  space = ' ',
  tab = '┃ ',
  multispace = '┃ ',
})

vim.api.nvim_set_hl(0, 'NonText', { fg = '#3b4252' })
