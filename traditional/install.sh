#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$CFG_DIR"
# Make sure we don't override an existing, non-symlink config
if [ -e "$CFG_DIR/nvim" ] && [ ! -L  "$CFG_DIR/nvim" ]; then
    echo "Refusing to overwrite existing ~/.config/nvim (not a symlink)" >&2
    exit 1
fi

ln -snf "$REPO_DIR/nvim" "$CFG_DIR/nvim"
echo "Linked $REPO_DIR/nvim -> $CFG_DIR/nvim"
echo "Open nvim once to let lazy.nvim bootstrap plugins."
