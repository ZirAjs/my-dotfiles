return {
  {
    "folke/tokyonight.nvim",
    tag = "v4.14.1",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
}
