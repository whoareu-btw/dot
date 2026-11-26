return {
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = function ()
      require("nvim-autopairs").setup({
        disable_filetype = { "TelescopePrompt", "vim" },
        map_cr = false,
        map_bs = false,
      })
    end
  },
}
