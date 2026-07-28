-- 1. Buat Autocommand Group
local lsp_group = vim.api.nvim_create_augroup("ManualMultiLspConfig", { clear = true })

-- 2. Definisi konfigurasi masing-masing server
-- Format: [nama_server] = { filetypes, cmd, root_markers, settings (opsional) }
local servers = {
  
  -- PYTHON
  pyright = {
    filetypes = { "python" },
    cmd = { "pyright-langserver", "--stdio" },
    root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  },
  
  -- C dan C++
  clangd = {
    filetypes = { "c", "cpp", "objc", "objcpp" },
    -- --background-index membuat clangd membaca seluruh project untuk fitur Go to Definition yang lebih akurat
    cmd = { "clangd", "--background-index" },
    root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
  },
  
  -- RUST
  rust_analyzer = {
    filetypes = { "rust" },
    cmd = { "rust-analyzer" },
    root_markers = { "Cargo.toml", ".git" },
  },
  
  -- LUA
  lua_ls = {
    filetypes = { "lua" },
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".git" },
    -- Khusus Lua, kita tambahkan 'vim' sebagai global variable agar 
    -- LSP tidak terus-menerus memberikan warning saat kita menulis config Neovim
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          -- Membuat LSP sadar akan file runtime bawaan Neovim
          library = vim.api.nvim_get_runtime_file("", true),
        },
      },
    },
  },
}

-- 3. Loop untuk mendaftarkan LSP berdasarkan tabel di atas
for server_name, config in pairs(servers) do
  vim.api.nvim_create_autocmd("FileType", {
    group = lsp_group,
    pattern = config.filetypes,
    callback = function(args)
      
      -- Dinamis mencari root directory sesuai dengan 'root_markers' tiap bahasa
      local root_marker = vim.fs.find(config.root_markers, {
        upward = true,
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf)),
      })[1]
      
      local project_root = root_marker and vim.fs.dirname(root_marker) or vim.fn.getcwd()

      -- Eksekusi LSP
      vim.lsp.start({
        name = server_name,
        cmd = config.cmd,
        root_dir = project_root,
        settings = config.settings,
      })
    end,
  })
end

-- 1. Menjinakkan Diagnostik (Pesan Error)
vim.diagnostic.config({
  update_in_insert = false,
  underline = true,
  virtual_text = {
    prefix = '●', 
    spacing = 4,
    source = false, 
  },
  severity_sort = true,
  float = {
    border = "rounded", -- Ini aman, tidak deprecated
  }
})

-- (Blok vim.lsp.handlers.hover dan signature_help dihapus sepenuhnya)
-- (Langsung lanjut ke tabel 'servers'...)
