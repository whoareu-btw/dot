local function warn(msg)
  vim.notify(msg, vim.log.levels.WARN)
end

-- Alt+Shift+w: ask for a new path (Tab completes), then save the file there
local function save_as()
  if vim.bo.buftype ~= "" then
    warn("This window is not a file")
    return
  end

  local current = vim.api.nvim_buf_get_name(0)
  local default = current ~= "" and vim.fn.fnamemodify(current, ":p") or (vim.fn.getcwd() .. "/")

  vim.ui.input({ prompt = "Save as: ", default = default, completion = "file" }, function(input)
    if not input or input == "" then return end -- cancelled

    local path = vim.fn.fnamemodify(vim.fn.expand(input), ":p")
    if vim.fn.isdirectory(path) == 1 then
      warn("That is a folder, add a file name")
      return
    end

    -- don't overwrite another file by accident
    if path ~= current and vim.fn.filereadable(path) == 1 then
      if vim.fn.confirm(("Overwrite %s?"):format(path), "&Yes\n&No", 2) ~= 1 then
        return
      end
    end

    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p") -- create missing folders
    local ok, err = pcall(vim.cmd, "saveas! " .. vim.fn.fnameescape(path))
    if not ok then
      vim.notify(tostring(err), vim.log.levels.ERROR)
    end
  end)
end

-- Alt+w: save the current file (asks for a name if it doesn't have one yet)
local function save()
  if vim.bo.buftype ~= "" then
    warn("This window is not a file")
    return
  end

  if vim.api.nvim_buf_get_name(0) == "" then
    save_as()
    return
  end

  local ok, err = pcall(vim.cmd, "write")
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
  end
end

vim.keymap.set({ "n", "i" }, "<A-w>", save, { desc = "Save file" })
vim.keymap.set({ "n", "i" }, "<A-W>", save_as, { desc = "Save file as" })
