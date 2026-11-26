return {
  {
    "ms-jpq/coq_nvim",
    branch = "coq",
    lazy = false,
    dependencies = {
      { "ms-jpq/coq.artifacts", branch = "artifacts" },
    },
    init = function()
      vim.g.coq_settings = {
        keymap = { recommended = false },
      }
    end,
    config = function()
      vim.opt.pumheight = 5

      local function map(lhs, rhs)
        vim.keymap.set("i", lhs, rhs, { expr = true, silent = true })
      end

      -- for mappings that return already-escaped keys (from nvim-autopairs)
      local function map_raw(lhs, rhs)
        vim.keymap.set("i", lhs, rhs, { expr = true, silent = true, replace_keycodes = false })
      end

      local function pum(when_open, when_closed)
        return function()
          return vim.fn.pumvisible() == 1 and when_open or when_closed
        end
      end

      map("<Tab>", pum("<C-n>", "<Tab>"))     -- next suggestion
      map("<S-Tab>", pum("<C-p>", "<S-Tab>")) -- previous suggestion
      map("<Esc>", pum("<C-e>", "<Esc>"))     -- close menu, stay in insert mode

      -- Enter: accept the highlighted suggestion, otherwise newline (autopairs-aware)
      map_raw("<CR>", function()
        local npairs = require("nvim-autopairs")
        if vim.fn.pumvisible() == 1 then
          if vim.fn.complete_info({ "selected" }).selected ~= -1 then
            return npairs.esc("<C-y>")
          end
          return npairs.esc("<C-e>") .. npairs.autopairs_cr()
        end
        return npairs.autopairs_cr()
      end)

      -- Backspace: autopairs-aware
      map_raw("<BS>", function()
        local npairs = require("nvim-autopairs")
        if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "mode" }).mode == "eval" then
          return npairs.esc("<C-e>") .. npairs.autopairs_bs()
        end
        return npairs.autopairs_bs()
      end)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.enable({
        "clangd",
        "rust_analyzer",
        "jdtls",
        "gopls",
        "bashls",
        "pyright",
      })

    vim.api.nvim_create_autocmd("TextChangedI", {
      pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc" },
      callback = function()
        local line = vim.api.nvim_get_current_line()
        local _, e = line:find("^%s*#%s*include%s*<[^>]*>")
        if e and line:sub(e + 1, e + 1) == ">" then
          local row = vim.api.nvim_win_get_cursor(0)[1] - 1
          vim.api.nvim_buf_set_text(0, row, e, row, e + 1, { "" })
        end
      end,
    })
    end,
  },
}
