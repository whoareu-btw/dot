-- Alt+c: highlight the word under the cursor. Whatever you type replaces it.
-- (Esc cancels and leaves the word alone.)
vim.keymap.set("n", "<A-c>", "viw<C-g>", { desc = "Change word" })

-- Alt+Shift+c: highlight every copy of the word in this file, then ask for the new word
local function change_word_everywhere()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    vim.notify("No word under the cursor", vim.log.levels.WARN)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local pattern = "\\V\\<" .. vim.fn.escape(word, [[/\]]) .. "\\>" -- whole word only

  -- highlight every match while the question is on screen
  local match_id = vim.fn.matchadd("Search", pattern)
  vim.cmd("redraw")

  vim.ui.input({ prompt = ('Change "%s" everywhere to: '):format(word), default = word }, function(new)
    pcall(vim.fn.matchdelete, match_id, win) -- remove the highlight again

    if not new or new == "" or new == word then return end -- cancelled or nothing to do

    local view = vim.fn.winsaveview() -- remember where the cursor was
    local replacement = vim.fn.escape(new, [[/\&~]])
    vim.cmd(("%%s/%s/%s/ge"):format(pattern, replacement))
    vim.fn.winrestview(view)
  end)
end

vim.keymap.set("n", "<A-C>", change_word_everywhere, { desc = "Change word everywhere in file" })
