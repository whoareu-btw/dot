-- go to an editor window first, so files never open inside the tree or terminal
local function focus_editor()
  if vim.bo.buftype == "" then return end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
      vim.api.nvim_set_current_win(w)
      return
    end
  end
end

local function open_file(path)
  focus_editor()
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

local function open_project(path)
  vim.cmd("cd " .. vim.fn.fnameescape(path))
  pcall(function()
    local api = require("nvim-tree.api")
    api.tree.change_root(path)
    if not api.tree.is_visible() then api.tree.open() end
  end)
  vim.notify("Project: " .. path)
end

-- folders first, then files, A-Z
local function list(dir, hidden, dirs_only)
  local items = {}
  for _, name in ipairs(vim.fn.readdir(dir)) do
    if hidden or name:sub(1, 1) ~= "." then
      local is_dir = vim.fn.isdirectory(vim.fs.joinpath(dir, name)) == 1
      if is_dir or not dirs_only then
        items[#items + 1] = { name = name, is_dir = is_dir }
      end
    end
  end
  table.sort(items, function(a, b)
    if a.is_dir ~= b.is_dir then return a.is_dir end
    return a.name:lower() < b.name:lower()
  end)
  return items
end

-- popup browser. mode = "file" or "dir"; on_pick(path) is called with the choice
local function browser(opts)
  local dir_mode = opts.mode == "dir"
  local state = { dir = opts.start, hidden = false, items = {} }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(70, vim.o.columns - 4)
  local height = math.min(20, vim.o.lines - 6)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = dir_mode and " Select folder " or " Select file ",
    title_pos = "center",
    footer = dir_mode
        and " Enter open  h up  Space choose  H hidden Esc back q close "
        or " Enter open  h up  H hidden  Esc back q close ",
    footer_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function show(dir, select_name)
    local ok, items = pcall(list, dir, state.hidden, dir_mode)
    if not ok then
      vim.notify("Cannot read " .. dir, vim.log.levels.WARN)
      return
    end
    state.dir = dir
    table.insert(items, 1, { name = "..", is_dir = true })
    state.items = items

    local lines, row = {}, (#items > 1) and 2 or 1
    for i, item in ipairs(items) do
      lines[i] = " " .. item.name .. (item.is_dir and "/" or "")
      if select_name and item.name == select_name then row = i end
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.api.nvim_win_set_config(win, {
      title = " " .. vim.fn.fnamemodify(dir, ":~") .. " ",
      title_pos = "center",
    })
    vim.api.nvim_win_set_cursor(win, { row, 0 })
  end

  local function up()
    show(vim.fs.dirname(state.dir), vim.fs.basename(state.dir))
  end

  local function enter()
    local item = state.items[vim.api.nvim_win_get_cursor(win)[1]]
    if not item then return end
    if item.name == ".." then
      up()
    elseif item.is_dir then
      show(vim.fs.joinpath(state.dir, item.name))
    else
      local path = vim.fs.joinpath(state.dir, item.name)
      close()
      vim.schedule(function() opts.on_pick(path) end)
    end
  end

  local function map(keys, fn)
    for _, key in ipairs(type(keys) == "table" and keys or { keys }) do
      vim.keymap.set("n", key, fn, { buffer = buf, nowait = true })
    end
  end

  map({ "<CR>", "l" }, enter)
  map({ "h", "<BS>", "-" }, up)
  map("H", function()
    state.hidden = not state.hidden
    show(state.dir)
  end)
  map("q", close)
  map("<Esc>", function()
    close()
    if opts.on_back then
      vim.schedule(opts.on_back)
    end
  end)
  if dir_mode then
    -- choose the folder you are currently looking at
    map("<Space>", function()
      local dir = state.dir
      close()
      vim.schedule(function() opts.on_pick(dir) end)
    end)
  end

  show(state.dir)
end

-- Alt+o: small menu
local function popup()
  local lines = {
    "",
    "   o   Select file",
    "   p   Open project folder",
    "",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local width, height = 34, #lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Open ",
    title_pos = "center",
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function bind(key, fn)
    vim.keymap.set("n", key, function()
      close()
      vim.schedule(fn)
    end, { buffer = buf, nowait = true })
  end

  bind("o", function()
    browser({ mode = "file", start = vim.fn.getcwd(), on_pick = open_file, on_back = popup })
  end)
  bind("p", function()
    browser({ mode = "dir", start = vim.fn.getcwd(), on_pick = open_project, on_back = popup })
  end)

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, close, { buffer = buf, nowait = true })
  end
end

vim.keymap.set("n", "<A-o>", popup, { desc = "Open file / project" })
