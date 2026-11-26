-- ask to save if the buffer has unsaved changes; returns false if cancelled
local function ask_save(buf)
  if not vim.bo[buf].modified then
    return true
  end
  local name = vim.fn.bufname(buf)
  if name == "" then name = "[No Name]" end
  local choice = vim.fn.confirm(("Save changes to %s?"):format(name), "&Yes\n&No\n&Cancel", 1)
  if choice == 1 then
    return pcall(vim.api.nvim_buf_call, buf, function() vim.cmd("write") end)
  end
  return choice == 2
end

-- close one file, keeping the window layout (tree, terminal) intact
local function close_current(buf)
  if not ask_save(buf) then return end
  local others = vim.tbl_filter(function(b)
    return b.bufnr ~= buf
  end, vim.fn.getbufinfo({ buflisted = 1 }))
  vim.cmd(#others > 0 and "bnext" or "enew")
  pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

-- make sure we act in an editor window, not inside the tree or terminal
local function focus_editor()
  if vim.bo.buftype == "" then return end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
      vim.api.nvim_set_current_win(w)
      return
    end
  end
end

-- Alt+n: open a new empty file in a new tab
local function new_file()
  vim.cmd.stopinsert()
  focus_editor()
  vim.cmd("enew")
end

-- Alt+q: close the current file (asks first)
local function close_one()
  local buf = vim.api.nvim_get_current_buf()

  -- tree / terminal / other special windows: just close the window
  if vim.bo[buf].buftype ~= "" then
    vim.cmd("close")
    return
  end

  local name = vim.fn.fnamemodify(vim.fn.bufname(buf), ":t")
  if name == "" then name = "[No Name]" end

  if vim.fn.confirm(("Close %s?"):format(name), "&Yes\n&No", 1) == 1 then
    close_current(buf)
  end
end

-- Alt+Shift+q: close every file (asks first)
local function close_all()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs == 0 then return end

  local msg = #bufs == 1 and "Close 1 file?" or ("Close all %d files?"):format(#bufs)
  if vim.fn.confirm(msg, "&Yes\n&No", 1) ~= 1 then return end

  -- ask about unsaved files first; cancelling keeps everything open
  for _, b in ipairs(bufs) do
    if not ask_save(b.bufnr) then return end
  end

  focus_editor()
  vim.cmd("enew")
  local empty = vim.api.nvim_get_current_buf()
  for _, b in ipairs(bufs) do
    if b.bufnr ~= empty then
      pcall(vim.api.nvim_buf_delete, b.bufnr, { force = true })
    end
  end
end

-- Alt+1..9: jump to the Nth tab
local function goto_file(n)
  return function()
    focus_editor()
    pcall(vim.cmd, "BufferLineGoToBuffer " .. n) -- ignore if that tab doesn't exist
  end
end

local keys = {
  { "<A-n>", new_file, mode = { "n", "i" }, desc = "New file (new tab)" },
  { "<A-q>", close_one, desc = "Close file (asks first)" },
  { "<A-Q>", close_all, desc = "Close all files (asks first)" },
}
for i = 1, 9 do
  keys[#keys + 1] = { "<A-" .. i .. ">", goto_file(i), desc = "Go to file " .. i }
end

return {
  "akinsho/bufferline.nvim",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = keys,
  opts = {
    options = {
      mode = "buffers",
      numbers = "none",       -- shows 1, 2, 3 on the tabs for Alt+number
      show_buffer_icons = true,  -- needs a Nerd Font
      show_buffer_close_icons = true,
      show_close_icon = false,
      diagnostics = false,
      separator_style = "thin",
      -- start the bar after the file tree, with the folder name above it
      offsets = {
        {
          filetype = "NvimTree",
          text = function()
            return "≡ " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end,
          text_align = "left",
          separator = true,
        },
      },
    },
    highlights = {
      offset_separator = { fg = "#606060" },
      separator = { fg = "#606060" },
      separator_selected = { fg = "#606060" },
      separator_visible  = { fg = "#606060" },
    },
  },
}
