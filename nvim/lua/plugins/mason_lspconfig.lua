return {
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = true,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "clangd",
        "rust_analyzer",
        "ts_ls",
        "texlab",
        "marksman",
      },
      automatic_enable = false,
    },
  },
}
