#!/bin/bash
set -euo pipefail

tpm="$HOME/.tmux/plugins/tpm"

if [ ! -d "$tpm" ]; then
  echo "Installing TPM..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
fi

if [ -f "$HOME/.tmux.conf" ]; then
  tmux new-session -d -s __plugin_install 'sleep 1' 2>/dev/null || true
  "$tpm/bin/install_plugins"
  tmux kill-session -t __plugin_install 2>/dev/null || true
fi
