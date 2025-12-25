# Run only on startup
if [[ -o login ]]; then
	fastfetch
fi

# Rust
cargo_env="$HOME/.cargo/env"
if [[ -e $cargo_env ]]; then
  . $cargo_env
fi

# Homebrew
export PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/jamf/bin

export PATH="/opt/homebrew/opt/unzip/bin:$PATH"

eval "$(brew shellenv)"
