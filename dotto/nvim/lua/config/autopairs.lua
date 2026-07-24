-- Nama tabel diganti jadi pair_map agar tidak menimpa fungsi bawaan pairs()
local pair_map = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
  ['"'] = '"',
  ["'"] = "'",
  ['`'] = '`',
}

for open, close in pairs(pair_map) do
  vim.keymap.set('i', open, function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local next_char = line:sub(col + 1, col + 1)

    if open == close and next_char == close then
      return '<Right>'
    end

    return open .. close .. '<Left>'
  end, { expr = true, silent = true })

  if open ~= close then
    vim.keymap.set('i', close, function()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local line = vim.api.nvim_get_current_line()
      local next_char = line:sub(col + 1, col + 1)

      if next_char == close then
        return '<Right>'
      end
      return close
    end, { expr = true, silent = true })
  end
end

vim.keymap.set('i', '<CR>', function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local prev_char = line:sub(col, col)
  local next_char = line:sub(col + 1, col + 1)

  if pair_map[prev_char] == next_char then
    return '<CR><Esc>O'
  end
  return '<CR>'
end, { expr = true, silent = true })

vim.keymap.set('i', '<BS>', function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local prev_char = line:sub(col, col)
  local next_char = line:sub(col + 1, col + 1)

  if pair_map[prev_char] == next_char then
    return '<BS><Del>'
  end
  return '<BS>'
end, { expr = true, silent = true })
