# my-dotfiles

Configuration for Alacritty, btop, Kitty, Neovim, tmux, Yazi, Zathura, and
Zsh.

Niri, systemd, and Noctalia configuration are intentionally not installed.
`snippets/niri-user.kdl` preserves only the changes made to Niri's packaged
default as a reference.

## Link configs

`install.sh` only links configuration files. Install applications, fonts, and
plugins separately. It does not install packages or change your login shell.

Preview the changes first:

    ./install.sh --dry-run --backup

Run interactively:

    ./install.sh

Interactive setup asks whether to link GUI tool configurations
(Alacritty, Kitty, and Zathura). A `DISPLAY` or `WAYLAND_DISPLAY` environment
variable defaults the answer to yes; otherwise it defaults to no for server
sessions. This detects the current session, so a desktop accessed through SSH
may default to no. You can always choose either answer.

For unattended installs and dry runs, the detected default is used without
prompting. Override detection explicitly:

    ./install.sh --no-gui --backup
    ./install.sh --gui --dry-run --backup

This installer links configurations; it does not install application binaries.
Skipping GUI configurations leaves any existing GUI configs in place.

When a target already exists, the installer offers:

1. Replace it with a symlink to this repository.
2. Move it to a timestamped backup and replace it with a symlink.
3. Skip it.

The global flags --overwrite, --backup, and --skip apply one choice to every
conflict. Choose only one action flag; any one of them can be combined with
--dry-run.

Backup mode stores originals below:

    ${XDG_STATE_HOME:-$HOME/.local/state}/my-dotfiles/backups/

To restore a backup, remove the corresponding symlink and move the saved item
back into its original location. Configuration directories belong under
`$HOME/.config`; the Zsh entry point belongs at `~/.zshrc`.

## Requirements

- Bash and standard Linux file utilities to run the linker
- The applications whose configurations you use
- JetBrainsMono Nerd Font for the Alacritty configuration and icon glyphs

See [nvim/README.md](nvim/README.md) for Neovim versions and dependencies.

## Manual user installation

The commands below are optional and run separately from `install.sh`. Skip
anything already installed. Run them on the machine where you will use the
tools, including SSH servers. Zsh, tmux, Git, curl, tar, gzip, and a C compiler
must be available separately; these commands do not install system packages.

For a Bash session, make user-installed commands available immediately:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### Neovim

Install the [official Neovim 0.12.6 archive](https://github.com/neovim/neovim/releases/tag/v0.12.6)
under `~/.local/opt` and expose its command under `~/.local/bin`:

```sh
curl -fLO https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.tar.gz
mkdir -p ~/.local/opt ~/.local/bin
tar -C ~/.local/opt -xzf nvim-linux-x86_64.tar.gz
ln -sfn ~/.local/opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
nvim --version
rm nvim-linux-x86_64.tar.gz
```

These commands target Linux x86_64. On Linux ARM64, replace
`nvim-linux-x86_64` with `nvim-linux-arm64` throughout.

After linking this repository's configs, start `nvim`. To install missing
plugins at the commits recorded in `lazy-lock.json`, run:

```vim
:lua require("lazy").install({ lockfile = true })
```

Restart Neovim afterwards. Use `:Lazy restore` to return installed plugins to
the commits in the lockfile. `:Lazy sync` includes updates, and a plain
`:Lazy install` can rewrite the lockfile; use the command above to reproduce
the recorded versions. Only run updates when you intend to review and commit
the resulting lockfile changes.

### Tree-sitter CLI

Install the [official Tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/releases/latest)
under `~/.local/bin`:

```sh
curl -fLO https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
gzip -d tree-sitter-linux-x64.gz
mkdir -p ~/.local/bin
install -m 755 tree-sitter-linux-x64 ~/.local/bin/tree-sitter
tree-sitter --version
rm tree-sitter-linux-x64
```

On Linux ARM64, replace `linux-x64` with `linux-arm64`. The Neovim config
requires Tree-sitter CLI 0.26.1 or newer and a C compiler for parser builds.

### TPM and tmux plugins

After linking the tmux configuration, clone
[TPM](https://github.com/tmux-plugins/tpm) into the path used by this config:

```sh
mkdir -p ~/.config/tmux/plugins
git clone https://github.com/tmux-plugins/tpm.git ~/.config/tmux/plugins/tpm
```

Skip cloning if TPM is already installed there. Because `~/.config/tmux` is a
symlink, TPM and downloaded plugins live in this repository's ignored
`tmux/plugins` directory.

Start tmux:

```sh
tmux
```

Inside tmux, load the configuration explicitly if the session was already
running, or if it still uses the default `Ctrl+b` prefix:

```sh
tmux source-file ~/.config/tmux/tmux.conf
tmux show-options -g prefix
```

The result should be `prefix C-Space`. Press **Ctrl+Space**, release it, then
press **Shift+i** to install the declared plugins. For intentional plugin
updates, use **Ctrl+Space**, then **Shift+u**.

## Zsh

The installer links both the configuration directory and the Zsh entry point:

    ~/.config/zsh -> my-dotfiles/zsh
    ~/.zshrc      -> my-dotfiles/zsh/zshrc

Machine-specific shell configuration belongs in zsh/local.zsh. That file is
ignored by Git; zsh/local.zsh.example is the tracked template.

Zsh searches `~/.local/bin` before system directories and other configured
tool directories. Duplicate PATH entries are removed. This priority is applied
again after startup environment activation and machine-local configuration.

Zsh loads autosuggestions and syntax highlighting from
`${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins` first, then falls back to
system plugin directories. To install these plugins manually for your user:

```sh
zsh_plugins_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$zsh_plugins_dir"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_plugins_dir/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_plugins_dir/zsh-syntax-highlighting"
exec zsh
```

Run these commands on each machine where you use the configuration, including
SSH servers. The linker does not download plugins.

## Local-only files

These files are deliberately not distributed:

- alacritty/themes/noctalia.toml
- zsh/local.zsh
- logs, backup files, agent metadata, and downloaded tmux plugins

Keep secrets and machine-specific settings in ignored local files. Before the
first commit, review filenames and configuration contents for credentials and
absolute machine-specific paths.
