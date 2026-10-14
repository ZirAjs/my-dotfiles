# Neovim Config

Personal Neovim configuration focused on a small, explicit Lua setup with lazy-loaded plugins, LSP support, Treesitter, fuzzy finding, Git hunk actions, and practical editing keymaps.

## Requirements

- Neovim 0.12.x, or Neovim 0.11.3+ through the bundled compatibility profile
- Git, for bootstrapping `lazy.nvim`
- A C compiler/toolchain for native plugins and Treesitter parsers
- `tree-sitter-cli` 0.26.1 or newer, `tar`, and `curl` for the Neovim 0.12 Treesitter setup
- Optional: `wl-copy` and `wl-paste` for Wayland clipboard integration
- Optional: `rg` for fast live grep through `fzf-lua`

## Install

Link the `nvim` directory from this repository to:

```sh
~/.config/nvim
```

Start Neovim:

```sh
nvim
```

To install missing plugins at the commits recorded in the active lockfile:

```vim
:lua require("lazy").install({ lockfile = true })
```

Restart Neovim after installation completes. Use `:Lazy restore` to return
installed plugins to the recorded commits. `:Lazy sync` includes updates;
plain `:Lazy install` can also change the lockfile.

## Layout

```text
init.lua                  Entry point and version guard
lua/config/options.lua    Editor options and clipboard setup
lua/config/keymaps.lua    Global keymaps
lua/config/lazy.lua       lazy.nvim bootstrap and plugin loading
lua/config/lsp.lua        Diagnostics, LSP capabilities, and servers
lua/plugins/*.lua                     Neovim 0.12 plugin specs
lazy-lock.json                        Neovim 0.12 locked plugin revisions
compat/nvim-0.11/                     Neovim 0.11 compatibility profile
compat/nvim-0.11/lazy-lock.json       Neovim 0.11 locked plugin revisions
```

## Plugins

The plugin set is intentionally compact:

- `blink.cmp` for completion
- `fzf-lua` for file, grep, buffer, help, and symbol search
- `which-key.nvim` for keymap hints
- `marks.nvim` for visible marks and mark navigation
- `mason.nvim` and `mason-lspconfig.nvim` for language server management
- `nvim-lspconfig` for LSP server definitions
- `oil.nvim` as the file explorer
- `nvim-treesitter` for syntax and indentation
- `gitsigns.nvim` for Git hunk navigation and actions
- `lualine.nvim` for the statusline
- `tokyonight.nvim` for the colorscheme
- `trouble.nvim` for diagnostics, symbols, LSP results, quickfix, and location lists
- `mini.pairs` for automatic pairs
- `mini.surround` for surround editing

The human-readable plugin inventory is also tracked in `lua/plugins/plugins.txt`.

## LSP

Configured servers:

- `lua_ls`
- `pyright`
- `ruff`
- `clangd`
- `rust_analyzer`
- `ts_ls`
- `texlab`
- `marksman`

Mason installs these editor-specific language servers, including Ruff. The
apt/pacman setup script installs Neovim's foundational system dependencies but
does not install Ruff. Ruff provides Python linting and formatting, while
Pyright remains responsible for type checking, completion, and navigation.

`clangd` is configured with background indexing, clang-tidy, detailed completion, and include-what-you-use header insertion.

Common LSP mappings are attached per buffer when a language server starts:

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>lf` | Format |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>e` | Diagnostic float |
| `<leader>lq` | Diagnostics to location list |

## Keymaps

Leader is space.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>w` | Normal | Save |
| `<leader>q` | Normal | Quit window |
| `<leader>g` | Normal | Start `:grep` |
| `<leader>tt` | Normal | Open terminal |
| `<leader>tv` | Normal | Open vertical terminal |
| `<Esc>` | Terminal | Return to normal mode |
| `n` / `N` | Normal | Next or previous search result, centered |
| `<C-d>` / `<C-u>` | Normal | Half-page scroll, centered |
| `<` / `>` | Visual | Indent and keep selection |
| `<C-/>` or `<C-_>` | Normal | Toggle comment on current line |
| `<C-/>` or `<C-_>` | Visual | Toggle comment on selection |
| `<M-Up>` / `<M-Down>` | Normal, Insert, Visual | Move line or selection |
| `<M-S-Up>` / `<M-S-Down>` | Normal, Insert, Visual | Copy line or selection |
| `<M-Left>` / `<M-Right>` | Normal | Jump backward or forward |

Macro recording with `q` is disabled in normal mode.

### Find

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |

### Git Hunks

| Key | Action |
| --- | --- |
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hr` | Reset hunk |

### Files

| Key | Action |
| --- | --- |
| `-` | Open parent directory with Oil |

### Trouble

Trouble presents diagnostics and common Neovim lists in a navigable panel.

| Key | Action |
| --- | --- |
| `<leader>xx` | All diagnostics |
| `<leader>xX` | Current buffer diagnostics |
| `<leader>cs` | Current document symbols on the right |
| `<leader>cl` | LSP definitions, references, and related results |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |

Inside Trouble, use `<CR>` to jump to an item, `o` to jump and close, `<C-s>` or `<C-v>` to open in a split, `q` to close, and `?` for help. Use Neovim's default `<C-w>h/j/k/l` keys to move between the code and Trouble windows.

### Marks

Marks adds sign-column feedback and convenient navigation while keeping Vim's normal mark workflow.

| Key | Action |
| --- | --- |
| `mx` | Set mark `x` (replace `x` with a letter) |
| `m,` | Set the next available lowercase mark |
| `m;` | Toggle the next available mark on the current line |
| `dmx` | Delete mark `x` |
| `dm-` | Delete all marks on the current line |
| `dm<Space>` | Delete all marks in the current buffer |
| `m]` / `m[` | Move to the next or previous mark |
| `m:` | Preview a mark |

## Updating

The 0.12 and 0.11 profiles use separate plugin roots (`lazy-nvim-0.12` and `lazy-nvim-0.11`) and separate lockfiles. After intentionally updating plugins with `:Lazy sync` or `:Lazy update`, review and commit the lockfile for the active profile with the related plugin spec changes.

Run `:checkhealth` after larger updates or when language tooling behaves unexpectedly.
