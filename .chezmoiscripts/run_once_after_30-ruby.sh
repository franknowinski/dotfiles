#!/bin/bash
set -euo pipefail

eval "$(/opt/homebrew/bin/brew shellenv)"

RUBY_VERSION=4.0.6

if ! rbenv versions --bare | grep -qx "$RUBY_VERSION"; then
  echo "Installing Ruby $RUBY_VERSION..."
  # Heads off the usual OpenSSL build failure.
  RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)" \
    rbenv install "$RUBY_VERSION"
fi

rbenv global "$RUBY_VERSION"

# fzf key bindings (the ,m binding in .zshrc needs ~/.fzf.zsh).
if [ ! -f "$HOME/.fzf.zsh" ]; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi
