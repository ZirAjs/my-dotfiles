#!/usr/bin/env bash

set -euo pipefail

manager="auto"

usage() {
    cat <<'EOF'
Usage: setup-zsh.sh [--apt|--pacman]

Install Zsh, autosuggestions, syntax highlighting, and zoxide.

Options:
  --apt      Use apt-get (Ubuntu).
  --pacman   Use pacman (Arch Linux).
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

packages=(
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zoxide
)

echo "Package manager: $manager"
echo "Packages:"
printf '  %s\n' "${packages[@]}"
echo
printf 'Install Zsh dependencies? [y/N] '
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
else
    "${privilege[@]}" pacman -S --needed -- "${packages[@]}"
fi

autosuggestions_paths=(
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
)

highlighting_paths=(
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
)

find_readable() {
    local candidate
    for candidate in "$@"; do
        if [[ -r "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

autosuggestions_path="$(find_readable "${autosuggestions_paths[@]}")" || {
    echo "ERROR: zsh-autosuggestions was installed but its script was not found." >&2
    exit 1
}

highlighting_path="$(find_readable "${highlighting_paths[@]}")" || {
    echo "ERROR: zsh-syntax-highlighting was installed but its script was not found." >&2
    exit 1
}

echo
echo "Zsh dependencies installed successfully."
echo "Autosuggestions:    $autosuggestions_path"
echo "Syntax highlighting: $highlighting_path"
echo "This script does not change your login shell."
echo "To do that explicitly, run: chsh -s \"$(command -v zsh)\""
