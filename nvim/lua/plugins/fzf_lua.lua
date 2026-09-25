return {
  {
    "ibhagwan/fzf-lua",
    branch = "main",
    main = "fzf-lua",
    keys = {
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function()
          require("fzf-lua").helptags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fs",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>fS",
        function()
          require("fzf-lua").lsp_workspace_symbols()
        end,
        desc = "Workspace symbols",
      },
    },
    opts = {},
  },
}
