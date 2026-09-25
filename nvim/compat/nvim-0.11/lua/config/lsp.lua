vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

local ok, blink = pcall(require, "blink.cmp")
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

local function format_markdown()
  local buffer = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buffer)
  local prettier = vim.fn.exepath("prettier")

  if prettier == "" then
    vim.notify("Prettier is not installed yet.", vim.log.levels.ERROR)
    return
  end

  if filepath == "" then
    filepath = "buffer.md"
  end

  local input = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
  local result = vim.system({ prettier, "--stdin-filepath", filepath }, {
    stdin = input,
    text = true,
  }):wait()

  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(result.stdout, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = {
      buffer = event.buf,
      silent = true,
    }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>lf", function()
      if vim.bo.filetype == "markdown" or vim.bo.filetype == "markdown.mdx" then
        format_markdown()
      else
        vim.lsp.buf.format({ async = false })
      end
    end, opts)

    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, opts)
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
  },
})

local servers = {
  "lua_ls",
  "pyright",
  "ruff",
  "clangd",
  "rust_analyzer",
  "ts_ls",
  "texlab",
  "marksman",
}

vim.lsp.enable(servers)
