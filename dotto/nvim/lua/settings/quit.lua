-- :q closes EVERYTHING (all windows, tree, terminal, popups) and quits Neovim.
-- Only files with unsaved changes get a question first.

local function stop_terminals()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      pcall(vim.api.nvim_buf_delete, buf, { force = true }) -- also stops the shell
    end
  end
end

-- asks "Save changes to ...?" for each unsaved file; returns false if you press Cancel
local function ask_unsaved()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].modified then
      local name = vim.fn.bufname(buf)
      if name == "" then name = "[No Name]" end
      local choice = vim.fn.confirm(("Save changes to %s?"):format(name), "&Yes\n&No\n&Cancel", 1)
      if choice == 1 then
        local ok = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd("write") end)
        if not ok then return false end
      elseif choice ~= 2 then
        return false
      end
    end
  end
  return true
end

-- :Quit  -> ask about unsaved files, then close everything
-- :Quit! -> close everything and throw away unsaved changes
vim.api.nvim_create_user_command("Q", function(opts)
  if not opts.bang and not ask_unsaved() then return end
  stop_terminals()
  vim.cmd("qall!")
end, { bang = true, desc = "Quit Neovim and close every window" })

-- :Wq -> save every changed file, then close everything
vim.api.nvim_create_user_command("Wq", function()
  local ok, err = pcall(vim.cmd, "wall")
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return
  end
  stop_terminals()
  vim.cmd("qall!")
end, { desc = "Save everything and quit" })

-- typing :q or :wq runs the commands above
vim.cmd([[cnoreabbrev <expr> q  (getcmdtype() == ':' && getcmdline() == 'q')  ? 'Q' : 'q']])
vim.cmd([[cnoreabbrev <expr> wq (getcmdtype() == ':' && getcmdline() == 'wq') ? 'Wq' : 'wq']])
