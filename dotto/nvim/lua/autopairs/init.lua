local pairs_map = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ['"'] = '"',
    ["'"] = "'",
    ["`"] = "`",
}

local function get_cursor_context()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(col, col)
    local after = line:sub(col + 1, col + 1)
    return before, after, line, col
end

for open, close in pairs(pairs_map) do
    local is_symmetric = (open == close)

    vim.keymap.set("i", open, function()
        local _, after = get_cursor_context()

        if is_symmetric and after == close then
            return "<Right>"
        end

        if is_symmetric and after:match("%w") then
            return open
        end

        return open .. close .. "<Left>"
    end, { expr = true, buffer = true })

    if not is_symmetric then
        vim.keymap.set("i", close, function()
            local _, after = get_cursor_context()
            if after == close then
                return "<Right>"
            end
            return close
        end, { expr = true, buffer = true })
    end
end

vim.keymap.set("i", "<BS>", function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local current_chars = line:sub(col, col + 1)

    for open, close in pairs(pairs_map) do
        if current_chars == open .. close then
            return "<BS><Right><BS>"
        end
    end
    return "<BS>"
end, { expr = true, buffer = true })

vim.keymap.set("i", "<CR>", function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(col, col)
    local after = line:sub(col + 1, col + 1)

    for open, close in pairs(pairs_map) do
        if before == open and after == close then
            return "<CR><Esc>O"
        end
    end

    return "<CR>"
end, { expr = true, buffer = true })
