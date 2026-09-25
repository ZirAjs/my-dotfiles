#!/usr/bin/env bash

set -euo pipefail

manager="auto"

usage() {
    cat <<'EOF'
Usage: setup-fonts.sh [--apt|--pacman]

Install JetBrainsMono Nerd Font for the terminal configurations.

Options:
  --apt      Use apt-get for prerequisites, then install the official Nerd Font archive for this user.
  --pacman   Install Arch Linux's official ttf-jetbrains-mono-nerd package.
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

if command -v fc-list >/dev/null 2>&1 &&
   fc-list : family | grep -Fqi 'JetBrainsMono Nerd Font'; then
    echo "JetBrainsMono Nerd Font is already installed."
    exit 0
fi

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

echo "JetBrainsMono Nerd Font is not installed."
if [[ "$manager" == "pacman" ]]; then
    echo "Arch package: ttf-jetbrains-mono-nerd"
else
    echo "Ubuntu prerequisites: curl, xz-utils, fontconfig"
    echo "Font source: official Nerd Fonts JetBrainsMono release archive"
    echo "Install location: $HOME/.local/share/fonts/JetBrainsMonoNerdFont"
fi
echo
printf 'Install the font? [y/N] '
read -r answer
case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Cancelled."; exit 0 ;;
esac

privilege=()
if ((EUID != 0)); then
    if ! command -v sudo >/dev/null 2>&1; then
        echo "ERROR: root privileges are required for package installation and sudo is unavailable." >&2
        exit 1
    fi
    privilege=(sudo)
fi

if [[ "$manager" == "pacman" ]]; then
    "${privilege[@]}" pacman -S --needed -- ttf-jetbrains-mono-nerd
else
    "${privilege[@]}" apt-get update
    "${privilege[@]}" apt-get install -y curl xz-utils fontconfig

    temporary_dir="$(mktemp -d)"
    trap 'rm -rf -- "$temporary_dir"' EXIT
    archive="$temporary_dir/JetBrainsMono.tar.xz"
    font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"

    curl --fail --location \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
        --output "$archive"
    mkdir -p -- "$font_dir"
    tar -xJf "$archive" -C "$font_dir" --wildcards '*.ttf'
    fc-cache -f "$font_dir"
fi

if ! command -v fc-list >/dev/null 2>&1 ||
   ! fc-list : family | grep -Fqi 'JetBrainsMono Nerd Font'; then
    echo "ERROR: the font installation completed, but Fontconfig cannot find JetBrainsMono Nerd Font." >&2
    exit 1
fi

echo "JetBrainsMono Nerd Font installed successfully."
