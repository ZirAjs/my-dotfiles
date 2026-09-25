return {
  {
    "nvim-mini/mini.pairs",
    tag = "v0.18.0",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      local pairs = require("mini.pairs")
      pairs.setup(opts)

      vim.keymap.set("i", "`", function()
        local filetype = vim.bo.filetype
        local is_markdown = filetype == "markdown" or filetype == "markdown.mdx"
        local insertion_column = vim.fn.col(".") - 1
        local line = vim.api.nvim_get_current_line()

        if is_markdown
          and insertion_column >= 2
          and line:sub(insertion_column - 1, insertion_column) == "``"
        then
          return "`"
        end

        return pairs.closeopen("``", "^[^\\]")
      end, { expr = true, replace_keycodes = false, desc = "Insert paired backtick" })
    end,
  },
}
