return {
  {
    "folke/which-key.nvim",
    tag = "v3.17.0",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>l", group = "LSP" },
        { "<leader>t", group = "Terminal" },
        { "<leader>h", group = "Git hunk" },
      },
    },
  },
}
