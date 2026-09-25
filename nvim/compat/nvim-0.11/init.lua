-- Neovim 0.11 compatibility entrypoint.

local required_version = { major = 0, minor = 11, patch = 3 }
local current_version = vim.version()

if current_version.major ~= required_version.major
  or current_version.minor ~= required_version.minor
  or current_version.patch < required_version.patch
then
  error(
    string.format(
      "This compat config requires Neovim v%d.%d.%d or newer, but current version is v%d.%d.%d",
      required_version.major,
      required_version.minor,
      required_version.patch,
      current_version.major,
      current_version.minor,
      current_version.patch
    )
  )
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")

vim.opt.runtimepath:prepend(config_dir)
vim.opt.packpath:prepend(config_dir)

require("config.options")
require("config.keymaps")

local plugins_ready = require("config.lazy")
if plugins_ready then
  require("config.lsp")
end
