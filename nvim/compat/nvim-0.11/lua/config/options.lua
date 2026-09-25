-- Treat .tex files as LaTeX rather than plain TeX.
vim.g.tex_flavor = "latex"

-- Show absolute and relative line numbers for command-friendly navigation.
vim.opt.number = true
vim.opt.relativenumber = true

-- Use four-space indentation by default.
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Keep the editor UI stable and give the cursor some context.
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Ignore case unless the search pattern contains uppercase letters.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Shorter update and mapping timeout values make feedback feel snappier.
vim.opt.updatetime = 250
vim.opt.timeoutlen = 600

-- Prefer persistent undo, but avoid swap and backup files for this config.
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false

local markdown_group = vim.api.nvim_create_augroup("MarkdownOptions", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = markdown_group,
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.breakindent = true
  end,
})

local tex_group = vim.api.nvim_create_augroup("TexOptions", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = tex_group,
  pattern = { "tex", "plaintex" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.breakindent = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 0
  end,
})

-- On Wayland, use wl-clipboard directly and make normal yanks use it.
if vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy",
    },
    paste = {
      ["+"] = "wl-paste --no-newline",
      ["*"] = "wl-paste --no-newline",
    },
    cache_enabled = 0,
  }

  vim.opt.clipboard = "unnamedplus"
end
