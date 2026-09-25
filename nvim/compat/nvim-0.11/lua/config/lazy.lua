local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local plugin_root = vim.fn.stdpath("data") .. "/lazy-nvim-0.11"
local lazypath = plugin_root .. "/lazy.nvim"

vim.fn.mkdir(plugin_root, "p")

-- Bootstrap lazy.nvim only when it is missing.
if not vim.uv.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=v11.17.5",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim:\n" .. result)
  end
end

vim.opt.runtimepath:prepend(lazypath)

local missing_plugins = {}

for _, plugin in ipairs({
  "blink.cmp",
  "fzf-lua",
  "gitsigns.nvim",
  "lualine.nvim",
  "marks.nvim",
  "mini.pairs",
  "mini.surround",
  "mason.nvim",
  "mason-lspconfig.nvim",
  "nvim-treesitter",
  "nvim-lspconfig",
  "oil.nvim",
  "tokyonight.nvim",
  "trouble.nvim",
  "which-key.nvim",
}) do
  if not vim.uv.fs_stat(plugin_root .. "/" .. plugin) then
    table.insert(missing_plugins, plugin)
  end
end

local plugins_ready = #missing_plugins == 0

if not plugins_ready then
  vim.api.nvim_echo({
    { "Missing plugins:\n", "WarningMsg" },
    { "  " .. table.concat(missing_plugins, "\n  ") .. "\n\n" },
    { "Install them with:\n", "WarningMsg" },
    { "  :Lazy sync\n\n" },
    { "Then restart Neovim.\n" },
  }, true, {})
end

require("lazy").setup({
  { import = "plugins" },
}, {
  root = plugin_root,
  lockfile = vim.fn.fnamemodify(config_dir .. "/lazy-lock.json", ":p"),
  install = {
    missing = false,
  },
  change_detection = {
    notify = false,
  },
})

if plugins_ready then
  require("lazy").load({
    plugins = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "nvim-lspconfig",
    },
  })
end

return plugins_ready
