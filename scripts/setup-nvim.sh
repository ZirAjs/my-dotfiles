#!/usr/bin/env bash

set -euo pipefail

manager="auto"

usage() {
    cat <<'EOF'
Usage: setup-nvim.sh [--apt|--pacman]

Install operating-system dependencies required by this Neovim configuration.
Plugin synchronization is intentionally not performed.

Options:
  --apt      Use apt-get.
  --pacman   Use pacman.
  -h, --help Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --apt)
            [[ "$manager" == "auto" ]] || { echo "Choose only one package manager." >&2; exit 2; }
            manager="apt"
            ;;
        --pacman)
            [[ "$manager" == "auto" ]] || { echo "Choose only one package manager." >&2; exit 2; }
            manager="pacman"
            ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
    shift
done

if [[ "$manager" == "auto" ]]; then
    if command -v apt-get >/dev/null 2>&1; then
        manager="apt"
    elif command -v pacman >/dev/null 2>&1; then
        manager="pacman"
    else
        echo "ERROR: neither apt-get nor pacman is available." >&2
        exit 1
    fi
fi

apt_packages=(
    neovim
    git
    curl
    wget
    tar
    gzip
    unzip
    xz-utils
    build-essential
    ripgrep
    fzf
    fd-find
    wl-clipboard
    nodejs
    npm
    python3
    python3-venv
    python3-pip
)

pacman_packages=(
    neovim
    git
    curl
    wget
    tar
    gzip
    unzip
    xz
    base-devel
    ripgrep
    fzf
    fd
    wl-clipboard
    nodejs
    npm
    python
    python-pip
    tree-sitter-cli
    prettier
)

if [[ "$manager" == "apt" ]]; then
    packages=("${apt_packages[@]}")
else
    packages=("${pacman_packages[@]}")
fi

echo "Package manager: $manager"
echo "Packages:"
printf '  %s\n' "${packages[@]}"
if [[ "$manager" == "apt" ]]; then
    echo "Additional npm tools: tree-sitter-cli, prettier"
fi
echo
printf 'Install dependencies? [y/N] '
read -r answer
case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Cancelled."; exit 0 ;;
esac

privilege=()
if ((EUID != 0)); then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: root privileges are required and sudo is unavailable." >&2
        exit 1
    fi
    privilege=(sudo)
fi

if [[ "$manager" == "apt" ]]; then
    "${privilege[@]}" apt-get update
    "${privilege[@]}" apt-get install -y "${packages[@]}"
    "${privilege[@]}" npm install --global tree-sitter-cli@latest prettier@latest

    if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        mkdir -p -- "$HOME/.local/bin"
        if [[ ! -e "$HOME/.local/bin/fd" && ! -L "$HOME/.local/bin/fd" ]]; then
            ln -s -- "$(command -v fdfind)" "$HOME/.local/bin/fd"
            echo "Linked fd compatibility command: $HOME/.local/bin/fd"
        fi
    fi
else
    "${privilege[@]}" pacman -S --needed -- "${packages[@]}"
fi

if ! command -v nvim >/dev/null 2>&1; then
    echo "ERROR: Neovim was not installed successfully." >&2
    exit 1
fi

version_output="$(nvim --version)"
version_line="${version_output%%$'\n'*}"
if [[ "$version_line" =~ v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
else
    echo "ERROR: could not parse Neovim version from: $version_line" >&2
    exit 1
fi

if ! {
    ((major == 0 && minor == 12)) ||
    ((major == 0 && minor == 11 && patch >= 3))
}; then
    echo "ERROR: this config requires Neovim 0.12.x or 0.11.3+." >&2
    echo "Installed version: $version_line" >&2
    echo "Your distribution repository may provide an incompatible Neovim version." >&2
    exit 1
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
    echo "ERROR: tree-sitter CLI was not installed successfully." >&2
    exit 1
fi

tree_sitter_line="$(tree-sitter --version)"
if [[ "$tree_sitter_line" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    ts_major="${BASH_REMATCH[1]}"
    ts_minor="${BASH_REMATCH[2]}"
    ts_patch="${BASH_REMATCH[3]}"
else
    echo "ERROR: could not parse Tree-sitter version from: $tree_sitter_line" >&2
    exit 1
fi

if ! {
    ((ts_major > 0)) ||
    ((ts_major == 0 && ts_minor > 26)) ||
    ((ts_major == 0 && ts_minor == 26 && ts_patch >= 1))
}; then
    echo "ERROR: this config requires tree-sitter CLI 0.26.1 or newer." >&2
    echo "Installed version: $tree_sitter_line" >&2
    exit 1
fi

echo
echo "Neovim dependencies installed successfully."
echo "Neovim:     $version_line"
echo "Tree-sitter: $tree_sitter_line"
echo "Run :Lazy sync manually when you are ready."
