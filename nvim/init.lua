-- Minimal Neovim config entrypoint.

local required_version = { major = 0, minor = 12 }
local current_version = vim.version()
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")

if current_version.major == 0 and current_version.minor == 11 then
  local compat_dir = config_dir .. "/compat/nvim-0.11"

  dofile(compat_dir .. "/init.lua")
  return
end

-- This config is intentionally pinned to one Neovim minor version.
if current_version.major ~= required_version.major
  or current_version.minor ~= required_version.minor
then
  error(
    string.format(
      "This config requires Neovim v%d.%d.x, but current version is v%d.%d.%d",
      required_version.major,
      required_version.minor,
      current_version.major,
      current_version.minor,
      current_version.patch
    )
  )
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.runtimepath:prepend(config_dir)
vim.opt.packpath:prepend(config_dir)

require("config.options")
require("config.keymaps")

local plugins_ready = require("config.lazy")
if plugins_ready then
  require("config.lsp")
end
