vim.api.nvim_create_autocmd("FileType", {
  pattern = "asm",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

vim.g.rust_recommended_style = 0
vim.g.python_recommended_style = 0
