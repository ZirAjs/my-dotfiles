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
Neovim manages its plugins separately; run `:Lazy sync` when needed.
For tmux plugins, set up TPM separately under `tmux/plugins/tpm`, then press
prefix + I in tmux. Downloaded tmux plugins are ignored by Git.

## Zsh

The installer links both the configuration directory and the Zsh entry point:

    ~/.config/zsh -> my-dotfiles/zsh
    ~/.zshrc      -> my-dotfiles/zsh/zshrc

Machine-specific shell configuration belongs in zsh/local.zsh. That file is
ignored by Git; zsh/local.zsh.example is the tracked template.

Zsh searches `~/.local/bin` before system directories and other configured
tool directories. Duplicate PATH entries are removed. This priority is applied
again after startup environment activation and machine-local configuration.

## Local-only files

These files are deliberately not distributed:

- alacritty/themes/noctalia.toml
- zsh/local.zsh
- logs, backup files, agent metadata, and downloaded tmux plugins

Keep secrets and machine-specific settings in ignored local files. Before the
first commit, review filenames and configuration contents for credentials and
absolute machine-specific paths.
