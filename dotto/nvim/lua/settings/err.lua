local float_win = nil

-- close the error popup if it is open; returns true if it was
local function close_float()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
    return true
  end
  float_win = nil
  return false
end

-- Alt+e: show the error(s) on the current line, or close the popup if it is already open
local function toggle_errors()
  if close_float() then return end

  local _, win = vim.diagnostic.open_float({
    scope = "line",   -- everything on this line, so the cursor doesn't need to be on the exact spot
    border = "rounded",
    source = true,    -- shows which tool reported it, e.g. rust-analyzer
    focus = false,
  })
  if win then
    float_win = win
  else
    vim.notify("No errors on this line", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<A-e>", toggle_errors, { desc = "Show / close errors on this line" })

-- Esc closes the popup when it is open, and behaves normally otherwise
vim.keymap.set("n", "<Esc>", function()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.schedule(close_float) -- close it right after this key is handled
    return ""
  end
  return "<Esc>"
end, { expr = true })
