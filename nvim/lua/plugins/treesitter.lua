return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    commit = "4916d6592ede8c07973490d9322f187e07dfefac",
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      treesitter.install({
        "c",
        "bibtex",
        "latex",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
      })

      local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)

          if not lang then
            return
          end

          pcall(vim.treesitter.start, args.buf, lang)
        end,
      })
    end,
  },
}
