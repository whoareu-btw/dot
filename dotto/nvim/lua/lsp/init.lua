-- Enable native automatic completion engine
vim.o.complete = ".,o"
vim.o.completeopt = "menuone,noselect,fuzzy"
vim.o.autocomplete = true

-- Use Tab and Shift-Tab to navigate suggestions
vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-n>"
    else
        return "<Tab>"
    end
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then
        return "<C-p>"
    else
        return "<S-Tab>"
    end
end, { expr = true })

local servers = {
    clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { ".git", "compile_commands.json", "Makefile" },
    },
    rust_analyzer = {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", ".git" },
    },
    pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
    },
    lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".git", "init.lua" },
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } }
            }
        }
    }
}

-- Register configurations
for name, config in pairs(servers) do
    vim.lsp.config(name, config)
end

-- Enable all servers globally
vim.lsp.enable(vim.tbl_keys(servers))

-- Automatically wire native LSP completion when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true })
    end,
})
