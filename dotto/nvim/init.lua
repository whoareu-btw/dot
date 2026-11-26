vim.loader.enable()
vim.opt.updatetime = 250
vim.opt.synmaxcol = 300

require("config.lazy")
require("settings.set")
require("settings.err")
require("settings.open")
require("settings.save")
require("settings.quit")
require("settings.cword")
require("settings.keybind")
require("settings.terminal")
require("settings.filetype")
require("plugins.coq_nvim")
require("plugins.nvim-tree")
require("plugins.bufferline")
