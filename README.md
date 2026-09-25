# my-dotfiles

Configuration for Alacritty, btop, Kitty, Neovim, tmux, Yazi, Zathura, and
Zsh.

Niri, systemd, and Noctalia configuration are intentionally not installed.
`snippets/niri-user.kdl` preserves only the changes made to Niri's packaged
default as a reference.

## Install

Preview a non-interactive installation first:

    ./install.sh --dry-run --backup

Run interactively:

    ./install.sh

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

- Bash
- Git for optional TPM setup
- JetBrainsMono Nerd Font for terminal text and icon glyphs

Install the font on Arch Linux or Ubuntu:

    ./scripts/setup-fonts.sh

The script first checks Fontconfig and asks for consent if the font is missing.
On Arch it uses `ttf-jetbrains-mono-nerd`. On Ubuntu it installs the required
download tools through apt, then installs the official Nerd Fonts archive for
the current user. Force package-manager selection with `--pacman` or `--apt`.

## Tmux plugins

Install TPM after linking the tmux configuration:

    ./scripts/setup-tmux.sh

TPM and downloaded plugins live under tmux/plugins, which is intentionally
ignored by Git. After starting tmux, press prefix + I to install configured
plugins, or run:

    ./scripts/setup-tmux.sh --install-plugins

Update TPM explicitly with:

    ./scripts/setup-tmux.sh --update

## Neovim dependencies

Install the system dependencies detected from the Neovim configuration:

    ./scripts/setup-nvim.sh

Force a package manager when automatic detection is not appropriate:

    ./scripts/setup-nvim.sh --apt
    ./scripts/setup-nvim.sh --pacman

The script lists every package and asks for confirmation before invoking apt,
pacman, or npm. It validates the required Neovim and Tree-sitter CLI versions.
It does not start Neovim or synchronize plugins; run :Lazy sync manually.

## Zsh

The installer links both the configuration directory and the Zsh entry point:

    ~/.config/zsh -> my-dotfiles/zsh
    ~/.zshrc      -> my-dotfiles/zsh/zshrc

Machine-specific shell configuration belongs in zsh/local.zsh. That file is
ignored by Git; zsh/local.zsh.example is the tracked template.

Install Zsh and its configured plugins on Arch Linux or Ubuntu:

    ./scripts/setup-zsh.sh

The script detects apt or pacman, lists its packages, and asks for confirmation.
It does not change the login shell; use chsh explicitly if desired.

## Local-only files

These files are deliberately not distributed:

- alacritty/themes/noctalia.toml
- zsh/local.zsh
- logs, backup files, agent metadata, and downloaded tmux plugins

Keep secrets and machine-specific settings in ignored local files. Before the
first commit, review filenames and configuration contents for credentials and
absolute machine-specific paths.
