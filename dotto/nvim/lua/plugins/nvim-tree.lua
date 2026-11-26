return {
  "nvim-tree/nvim-tree.lua",
  lazy = false, -- so `nvim .` opens the tree instead of netrw
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function()
    -- disable netrw, as recommended by nvim-tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local function separator_color()
      vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#606060", bg = "NONE" })
    end
    separator_color()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = separator_color })

      -- open the file tree when Neovim starts, but keep the cursor in the editor
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local win = vim.api.nvim_get_current_win()
        require("nvim-tree.api").tree.open()
        if vim.api.nvim_win_is_valid(win)
          and vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "NvimTree" then
        vim.api.nvim_set_current_win(win)
      end
    end,
  })
  end,
  keys = {
    { "<A-b>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
  },
  opts = {
    view = { width = 20 },
    filters = { 
      dotfiles = false,
      custom = {
        "^\\.cache$",
        "^\\.config$",
        "^\\.local$",
        "^\\.cargo$",
        "^\\.eclipse",
        "\\.efi$",
        "\\.EFI$",
        "\\.obj",
        "\\.fd",
      },
    },
  },
}
