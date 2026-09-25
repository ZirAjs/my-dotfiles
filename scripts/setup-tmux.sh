#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(unset CDPATH; cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
plugins_dir="$repo_dir/tmux/plugins"
tpm_dir="$plugins_dir/tpm"
tpm_repository="https://github.com/tmux-plugins/tpm.git"
update=false
install_plugins=false

usage() {
    cat <<'EOF'
Usage: setup-tmux.sh [--update] [--install-plugins]

Install TPM into this dotfiles repository's ignored tmux/plugins directory.

Options:
  --update           Fast-forward an existing TPM checkout.
  --install-plugins  Install plugins declared in the active tmux configuration.
  -h, --help         Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --update) update=true ;;
        --install-plugins) install_plugins=true ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
    shift
done

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is required to install TPM." >&2
    exit 1
fi

mkdir -p -- "$plugins_dir"

if [[ -d "$tpm_dir/.git" ]]; then
    echo "TPM is already installed: $tpm_dir"
elif [[ -e "$tpm_dir" || -L "$tpm_dir" ]]; then
    echo "ERROR: refusing to replace an existing non-TPM path: $tpm_dir" >&2
    exit 1
else
    echo "Cloning TPM into: $tpm_dir"
    git clone --depth 1 -- "$tpm_repository" "$tpm_dir"
fi

if [[ "$update" == true ]]; then
    echo "Updating TPM..."
    git -C "$tpm_dir" pull --ff-only
fi

if [[ "$install_plugins" == true ]]; then
    if ! command -v tmux >/dev/null 2>&1; then
        echo "ERROR: tmux is required to install tmux plugins." >&2
        exit 1
    fi
    if ! tmux list-sessions >/dev/null 2>&1; then
        echo "ERROR: start tmux and load your configuration before using --install-plugins." >&2
        exit 1
    fi

    echo "Installing plugins declared in the active tmux configuration..."
    "$tpm_dir/bin/install_plugins"
else
    echo "TPM setup complete."
    echo "Start tmux and press prefix + I, or re-run with --install-plugins."
fi
