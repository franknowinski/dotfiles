#!/bin/bash
set -euo pipefail

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# zsh-autosuggestions comes from Homebrew, but oh-my-zsh loads it as a plugin.
custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$custom" ]; then
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$custom"
fi
