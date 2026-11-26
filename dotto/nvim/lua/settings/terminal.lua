local M = { buf = nil, win = nil, saved_laststatus = nil }

local HEIGHT = 5

local function is_open()
  return M.win ~= nil and vim.api.nvim_win_is_valid(M.win)
end

-- put the normal status bars back when the terminal goes away
local function restore_statusline()
  if M.saved_laststatus ~= nil then
    vim.o.laststatus = M.saved_laststatus
    M.saved_laststatus = nil
  end
end

-- plain terminal window: no header bar, no numbers
local function style(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.cursorline = false
  wo.winbar = ""
  wo.winfixheight = true
end

function M.toggle()
  -- already open: hide it (the shell keeps running in the background)
  if is_open() then
    vim.api.nvim_win_hide(M.win) -- this also restores the status bar
    M.win = nil
    return
  end

  -- don't split the file tree, go to the editor window first
  if vim.bo.filetype == "NvimTree" then
    vim.cmd("wincmd l")
  end

  vim.cmd("belowright " .. HEIGHT .. "split")
  M.win = vim.api.nvim_get_current_win()

  -- no bar under the terminal: with laststatus=0 the bottom window has no status bar,
  -- so only the window above it (the editor) keeps one
  M.saved_laststatus = M.saved_laststatus or vim.o.laststatus
  vim.o.laststatus = 0
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(M.win),
    once = true,
    callback = restore_statusline,
  })

  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_win_set_buf(M.win, M.buf) -- reuse the same shell
  else
    vim.cmd.terminal()
    local buf = vim.api.nvim_get_current_buf()
    M.buf = buf
    vim.bo[buf].buflisted = false

    -- when you `exit` the shell, close the panel and forget the buffer
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = buf,
      once = true,
      callback = function()
        vim.schedule(function()
          if is_open() then
            pcall(vim.api.nvim_win_close, M.win, true)
          end
          if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
          M.win, M.buf = nil, nil
        end)
      end,
    })
  end

  style(M.win)
  vim.cmd.startinsert()
end

vim.keymap.set({ "n", "t" }, "<A-t>", M.toggle, { desc = "Toggle terminal" })

-- the code window to use: the current one, else the one you were in before, else any
local function editor_win()
  local function is_code(w)
    return w ~= 0
      and vim.api.nvim_win_is_valid(w)
      and vim.api.nvim_win_get_config(w).relative == ""
      and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == ""
  end

  local cur = vim.api.nvim_get_current_win()
  if is_code(cur) then return cur end

  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if is_code(prev) then return prev end

  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_code(w) then return w end
  end
end

local function tree_win()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "NvimTree" then
      return w
    end
  end
end

-- move focus: editor -> terminal -> tree -> editor (dir = 1), or the other way (dir = -1)
local function cycle_focus(dir)
  local list = {}
  local code = editor_win()
  if code then list[#list + 1] = code end
  if is_open() then list[#list + 1] = M.win end
  local tree = tree_win()
  if tree then list[#list + 1] = tree end
  if #list < 2 then return end -- nothing to switch to

  local cur = vim.api.nvim_get_current_win()
  local idx = 0
  for i, w in ipairs(list) do
    if w == cur then idx = i end
  end

  local target = list[(idx - 1 + dir) % #list + 1]
  vim.api.nvim_set_current_win(target)
  if target == M.win then
    vim.cmd.startinsert() -- typing mode when you land in the terminal
  end
end

vim.keymap.set({ "n", "t" }, "<A-r>", function() cycle_focus(1) end,
  { desc = "Next window (editor / terminal / tree)" })
vim.keymap.set({ "n", "t" }, "<A-R>", function() cycle_focus(-1) end,
  { desc = "Previous window (editor / terminal / tree)" })

return M
