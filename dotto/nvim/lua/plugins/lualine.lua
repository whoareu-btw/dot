-- names of the language servers attached to this file, e.g. "rust-analyzer"
local function lsp_name()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  return table.concat(vim.tbl_map(function(c)
    return c.name
  end, clients), ", ")
end

-- simple dark theme: grey backgrounds, light text
local function simple_dark()
  local bg_a = "#2b2b2b" -- mode block and "1:1"
  local bg_b = "#202020" -- git/diagnostics area and "Top"
  local bg_c = "#181818" -- file name area and the middle of the bar
  local fg = "#c0c0c0"

  -- only the mode text changes colour; make them all the same colour if you prefer
  local mode_fg = {
    normal = "#c0c0c0",
    insert = "#98c379",
    visual = "#c678dd",
    replace = "#e06c75",
    command = "#e5c07b",
    terminal = "#98c379",
    inactive = "#c0c0c0", -- same as normal, so the editor's bar looks complete while you are in the terminal
  }

  local theme = {}
  for mode, color in pairs(mode_fg) do
    theme[mode] = {
      a = { fg = color, bg = bg_a, gui = "bold" },
      b = { fg = fg, bg = bg_b },
      c = { fg = fg, bg = bg_c },
    }
  end
  return theme
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local sections = {
      lualine_a = { { "mode", fmt = string.lower } },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { "filename" },
      lualine_x = {
        { lsp_name, icon = vim.fn.nr2char(0xf013) }, -- gear icon + server name
        "filetype",                                  -- language icon + name
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    }

    return {
      options = { 
        theme = simple_dark(),
        refresh = { statusline = 500, tabline = 1000, winbar = 1000 },
      },
      sections = sections,
      inactive_sections = vim.deepcopy(sections), -- windows you are not in look the same
      extensions = { "nvim-tree" },
    }
  end,
}
