return {
  {
    "lewis6991/gitsigns.nvim",
    tag = "v2.1.0",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local map_opts = {
          buffer = bufnr,
          silent = true,
        }

        vim.keymap.set("n", "]h", function()
          gitsigns.nav_hunk("next")
        end, vim.tbl_extend("force", map_opts, { desc = "Next git hunk" }))

        vim.keymap.set("n", "[h", function()
          gitsigns.nav_hunk("prev")
        end, vim.tbl_extend("force", map_opts, { desc = "Previous git hunk" }))

        vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, vim.tbl_extend("force", map_opts, { desc = "Preview git hunk" }))
        vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, vim.tbl_extend("force", map_opts, { desc = "Reset git hunk" }))
      end,
    },
  },
}
