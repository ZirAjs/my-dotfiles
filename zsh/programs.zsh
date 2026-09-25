# >>> mamba initialize >>>
# !! Contents within this block are managed by "micromamba shell init" !!
export MAMBA_EXE="$HOME/.local/bin/micromamba";
export MAMBA_ROOT_PREFIX="$HOME/micromamba";
export MAMBA_CHANGEPS1=false
if [[ -x "$MAMBA_EXE" ]]; then
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [[ $? -eq 0 ]]; then
        eval "$__mamba_setup"
    else
        alias micromamba="$MAMBA_EXE"
    fi
    unset __mamba_setup
    alias conda="micromamba"

    # The general environment is optional and machine-specific.
    [[ -f "$MAMBA_ROOT_PREFIX/envs/general/etc/profile.d/mamba.sh" ]] \
        && micromamba activate general
fi
# <<< mamba initialize <<<

# >>> zoxide initialize >>>
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
# <<< zoxide initialize <<<

# >>> Nvim initialize >>>
export EDITOR="nvim"
export VISUAL="nvim"
alias vi="nvim"
# <<< Nvim initialize <<<

# >>> Yazi configuration >>>
if command -v yazi >/dev/null 2>&1; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        command rm -f -- "$tmp"
    }
fi
# <<< Yazi configuration <<<


# >>> NeoMutt configuration >>>
if command -v neomutt >/dev/null 2>&1; then
    alias mutt="neomutt"
fi
# <<< NeoMutt configuration <<<
