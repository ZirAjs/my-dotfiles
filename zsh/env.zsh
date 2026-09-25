# Setup npm path
# default npm path is /usr/local/lib/node_modules
# However, it requires root privileges to install in /usr
# The user should change the default path using:
# npm config set prefix ~/.local/lib/npm
[[ -d "$HOME/.local/lib/npm" ]] \
    && export PATH="$HOME/.local/lib/npm/bin:$PATH"

# ruby gems
if command -v ruby >/dev/null 2>&1; then
    RUBY_GEM_BIN="$(ruby -e 'require "rubygems"; print File.join(Gem.user_dir, "bin")')"
    export PATH="$RUBY_GEM_BIN:$PATH"
fi

# Programs that are added to ~/.local/bin
[[ -d "$HOME/.local/bin" ]] \
    && export PATH="$HOME/.local/bin:$PATH"

# Programs installed via Coursier (Scala)
[[ -d "$HOME/.local/share/coursier/bin" ]] \
    && export PATH="$HOME/.local/share/coursier/bin:$PATH"

# Programs installed via cargo (Rust)
# Note that most of the cargo binaries should be installed via pacman
[[ -d "$HOME/.cargo/bin" ]] \
    && export PATH="$HOME/.cargo/bin:$PATH"

return 0
