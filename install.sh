#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(unset CDPATH; cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
config_dir="$HOME/.config"
default_action="prompt"
action_flag_seen=false
dry_run=false

usage() {
    echo "Usage: $0 [--dry-run] [--overwrite|--backup|--skip]"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)  dry_run=true ;;
        --overwrite|--backup|--skip)
            if [[ "$action_flag_seen" == true ]]; then
                echo "ERROR: choose only one of --overwrite, --backup, or --skip" >&2
                usage >&2
                exit 2
            fi
            action_flag_seen=true
            default_action="${1#--}"
            ;;
        -h|--help)   usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
    shift
done

packages=(
    alacritty
    btop
    kitty
    nvim
    tmux
    yazi
    zathura
    zsh
)

show_depth_one() {
    local path="$1"
    local entries=()
    local index name marker

    printf '%s\n' "$path"
    if [[ ! -d "$path" || -L "$path" ]]; then
        return
    fi

    shopt -s nullglob dotglob
    entries=("$path"/*)
    shopt -u nullglob dotglob

    for ((index = 0; index < ${#entries[@]}; index++)); do
        name="${entries[$index]##*/}"
        marker='├──'
        if ((index == ${#entries[@]} - 1)); then
            marker='└──'
        fi
        if [[ -d "${entries[$index]}" && ! -L "${entries[$index]}" ]]; then
            name="$name/"
        fi
        printf '  %s %s\n' "$marker" "$name"
    done
}

choose_action() {
    local target_path="$1"
    local choice

    echo
    echo "WARN: the path already contains a config"
    show_depth_one "$target_path"
    echo
    echo "Choose an option:"
    echo "  1. overwrite (remove original)"
    echo "  2. backup and overwrite"
    echo "  3. skip"

    while true; do
        printf '> '
        if ! read -r choice; then
            echo
            echo "No input; skipping $target_path" >&2
            selected_action="skip"
            return
        fi
        case "$choice" in
            1) selected_action="overwrite"; return ;;
            2) selected_action="backup"; return ;;
            3) selected_action="skip"; return ;;
            *) echo "Enter 1, 2, or 3." >&2 ;;
        esac
    done
}

choose_file_action() {
    local target_path="$1"
    local choice

    echo
    echo "WARN: the path already exists"
    show_depth_one "$target_path"
    echo
    echo "Choose an option:"
    echo "  1. overwrite (remove original)"
    echo "  2. backup and overwrite"
    echo "  3. skip"

    while true; do
        printf '> '
        if ! read -r choice; then
            echo
            echo "No input; skipping $target_path" >&2
            selected_action="skip"
            return
        fi
        case "$choice" in
            1) selected_action="overwrite"; return ;;
            2) selected_action="backup"; return ;;
            3) selected_action="skip"; return ;;
            *) echo "Enter 1, 2, or 3." >&2 ;;
        esac
    done
}

make_staged_link() {
    local source_path="$1"
    local staged_link="$2"

    rm -f -- "$staged_link"
    ln -s -- "$source_path" "$staged_link"
    [[ -L "$staged_link" && -e "$staged_link" ]]
}

install_new_link() {
    local source_path="$1"
    local target_path="$2"
    local staged_link="$3"

    make_staged_link "$source_path" "$staged_link"
    mv -- "$staged_link" "$target_path"
}

echo "Repository: $repo_dir"
echo "Target:     $config_dir"
echo "Mode:       $default_action"
if [[ "$dry_run" == true ]]; then
    echo "DRY RUN: no files will be changed"
fi

if [[ "$dry_run" != true ]]; then
    mkdir -p -- "$config_dir"
fi

zsh_local_example="$repo_dir/zsh/local.zsh.example"
zsh_local="$repo_dir/zsh/local.zsh"
if [[ -f "$zsh_local_example" && ! -e "$zsh_local" ]]; then
    if [[ "$dry_run" == true ]]; then
        echo "WOULD CREATE: $zsh_local from its tracked example"
    else
        cp -- "$zsh_local_example" "$zsh_local"
        echo "Created machine-local Zsh config: $zsh_local"
    fi
fi

backup_dir=""

for package in "${packages[@]}"; do
    source_path="$repo_dir/$package"
    target_path="$config_dir/$package"
    staged_link="$config_dir/.my-dotfiles-link-$package-$$"
    displaced_path="$config_dir/.my-dotfiles-old-$package-$$"

    if [[ ! -d "$source_path" ]]; then
        echo "WARN: missing source; skipping $source_path" >&2
        continue
    fi

    if [[ -L "$target_path" ]] &&
       [[ "$(readlink -f -- "$target_path")" == "$(readlink -f -- "$source_path")" ]]; then
        echo "OK: already linked $target_path"
        continue
    fi

    if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
        if [[ "$dry_run" == true ]]; then
            echo "WOULD LINK: $target_path -> $source_path"
        else
            install_new_link "$source_path" "$target_path" "$staged_link"
            echo "Linked: $target_path -> $source_path"
        fi
        continue
    fi

    action="$default_action"
    if [[ "$action" == "prompt" ]]; then
        selected_action=""
        choose_action "$target_path"
        action="$selected_action"
    fi

    case "$action" in
        overwrite)
            if [[ "$dry_run" == true ]]; then
                echo "WOULD REPLACE: $target_path"
                continue
            fi

            make_staged_link "$source_path" "$staged_link"
            rm -rf -- "$displaced_path"
            mv -- "$target_path" "$displaced_path"
            if mv -- "$staged_link" "$target_path"; then
                rm -rf -- "$displaced_path"
                echo "Replaced: $target_path"
            else
                mv -- "$displaced_path" "$target_path"
                rm -f -- "$staged_link"
                echo "ERROR: replacement failed; original restored: $target_path" >&2
                exit 1
            fi
            ;;
        backup)
            if [[ "$dry_run" == true ]]; then
                echo "WOULD BACK UP AND REPLACE: $target_path"
                continue
            fi

            if [[ -z "$backup_dir" ]]; then
                backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/my-dotfiles/backups/$(date +%Y%m%d-%H%M%S)-$$"
                mkdir -p -- "$backup_dir"
            fi

            make_staged_link "$source_path" "$staged_link"
            mv -- "$target_path" "$backup_dir/$package"
            if mv -- "$staged_link" "$target_path"; then
                echo "Backed up and linked: $target_path"
            else
                mv -- "$backup_dir/$package" "$target_path"
                rm -f -- "$staged_link"
                echo "ERROR: replacement failed; backup restored: $target_path" >&2
                exit 1
            fi
            ;;
        skip)
            echo "Skipped: $target_path"
            ;;
    esac
done

zshrc_source="$repo_dir/zsh/zshrc"
zshrc_target="$HOME/.zshrc"
staged_link="$HOME/.my-dotfiles-link-zshrc-$$"
displaced_path="$HOME/.my-dotfiles-old-zshrc-$$"

if [[ ! -f "$zshrc_source" ]]; then
    echo "WARN: missing source; skipping $zshrc_source" >&2
elif [[ -L "$zshrc_target" ]] &&
     [[ "$(readlink -f -- "$zshrc_target")" == "$(readlink -f -- "$zshrc_source")" ]]; then
    echo "OK: already linked $zshrc_target"
elif [[ ! -e "$zshrc_target" && ! -L "$zshrc_target" ]]; then
    if [[ "$dry_run" == true ]]; then
        echo "WOULD LINK: $zshrc_target -> $zshrc_source"
    else
        install_new_link "$zshrc_source" "$zshrc_target" "$staged_link"
        echo "Linked: $zshrc_target -> $zshrc_source"
    fi
else
    action="$default_action"
    if [[ "$action" == "prompt" ]]; then
        selected_action=""
        choose_file_action "$zshrc_target"
        action="$selected_action"
    fi

    case "$action" in
        overwrite)
            if [[ "$dry_run" == true ]]; then
                echo "WOULD REPLACE: $zshrc_target"
            else
                make_staged_link "$zshrc_source" "$staged_link"
                rm -rf -- "$displaced_path"
                mv -- "$zshrc_target" "$displaced_path"
                if mv -- "$staged_link" "$zshrc_target"; then
                    rm -rf -- "$displaced_path"
                    echo "Replaced: $zshrc_target"
                else
                    mv -- "$displaced_path" "$zshrc_target"
                    rm -f -- "$staged_link"
                    echo "ERROR: replacement failed; original restored: $zshrc_target" >&2
                    exit 1
                fi
            fi
            ;;
        backup)
            if [[ "$dry_run" == true ]]; then
                echo "WOULD BACK UP AND REPLACE: $zshrc_target"
            else
                if [[ -z "$backup_dir" ]]; then
                    backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/my-dotfiles/backups/$(date +%Y%m%d-%H%M%S)-$$"
                    mkdir -p -- "$backup_dir"
                fi
                make_staged_link "$zshrc_source" "$staged_link"
                mv -- "$zshrc_target" "$backup_dir/zshrc"
                if mv -- "$staged_link" "$zshrc_target"; then
                    echo "Backed up and linked: $zshrc_target"
                else
                    mv -- "$backup_dir/zshrc" "$zshrc_target"
                    rm -f -- "$staged_link"
                    echo "ERROR: replacement failed; backup restored: $zshrc_target" >&2
                    exit 1
                fi
            fi
            ;;
        skip)
            echo "Skipped: $zshrc_target"
            ;;
    esac
fi

if [[ -n "$backup_dir" ]]; then
    echo
    echo "Backups saved in: $backup_dir"
fi
