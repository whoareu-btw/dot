local win = nil

-- "<M-t>" -> "Alt+t", "<M-Q>" -> "Alt+Shift+q"
local function pretty(lhs)
  local key = lhs:match("^<M%-(.+)>$")
  if not key then return lhs end
  if key:match("^%u$") then
    return "Alt+Shift+" .. key:lower()
  end
  return "Alt+" .. key:gsub("^S%-", "Shift+")
end

-- every Alt mapping that has a description
local function collect()
  local seen, items, has_numbers = {}, {}, false
  for _, mode in ipairs({ "n", "i", "t", "v" }) do
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      local lhs = km.lhs
      if km.desc and km.desc ~= "" and lhs:lower():match("^<m%-") and not seen[lhs] then
        seen[lhs] = true
        if lhs:match("^<M%-%d>$") then
          has_numbers = true -- Alt+1..9 are shown as a single line
        else
          items[#items + 1] = { key = pretty(lhs), desc = km.desc }
        end
      end
    end
  end
  table.sort(items, function(a, b)
    return a.key:lower() < b.key:lower()
  end)
  if has_numbers then
    items[#items + 1] = { key = "Alt+1 .. Alt+9", desc = "Go to tab number 1-9" }
  end
  return items
end

local function build_lines()
  local items = collect()
  local key_width = 0
  for _, it in ipairs(items) do
    key_width = math.max(key_width, #it.key)
  end

  local lines = { "" }
  for _, it in ipairs(items) do
    lines[#lines + 1] = ("  %-" .. key_width .. "s   %s"):format(it.key, it.desc)
  end

  vim.list_extend(lines, {
    "",
    "  Typing (completion menu)",
    "  Tab / Shift+Tab   next / previous suggestion",
    "  Enter             accept the suggestion",
    "  Esc               close the suggestion menu",
    "",
    "  Alt+o menu:  o file   p folder   h up   H hidden   Esc back   q close",
    "",
  })
  return lines
end

local function toggle()
  -- pressing the key again closes it
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
    return
  end

  vim.cmd.stopinsert()

  local lines = build_lines()
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(width + 2, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 6)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Keybinds ",
    title_pos = "center",
    footer = " q / Esc close ",
    footer_pos = "center",
  })

  for _, key in ipairs({ "q", "<Esc>", "<A-/>" }) do
    vim.keymap.set("n", key, toggle, { buffer = buf, nowait = true })
  end
end

vim.keymap.set({ "n", "i", "t" }, "<A-/>", toggle, { desc = "Show keybinds" })
