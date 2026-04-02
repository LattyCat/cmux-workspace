#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== AI Dev Workspace Setup ==="
echo "Repository: $REPO_DIR"
echo ""

# --------------------------------------------------
# Helper
# --------------------------------------------------
check_brew_formula() {
  if ! brew list "$1" &>/dev/null; then
    echo "  Installing $1..."
    brew install "$1"
  else
    echo "  OK: $1"
  fi
}

check_brew_cask() {
  if ! brew list --cask "$1" &>/dev/null; then
    echo "  Installing $1 (cask)..."
    brew install --cask "$1"
  else
    echo "  OK: $1 (cask)"
  fi
}

symlink() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -f "$dest" ]; then
    echo "  BACKUP: $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi
  ln -sf "$src" "$dest"
  echo "  LINK: $dest -> $src"
}

# --------------------------------------------------
# 1. Dependencies
# --------------------------------------------------
echo "[1/4] Dependencies"

if ! command -v brew &>/dev/null; then
  echo "  Homebrew is not installed."
  echo "  Please install it manually: https://brew.sh"
  echo "  Then re-run this script."
  exit 1
fi

brew tap manaflow-ai/cmux 2>/dev/null || true

check_brew_cask "manaflow-ai/cmux/cmux"
check_brew_cask "claude-code"
check_brew_formula "yazi"
check_brew_formula "lazygit"
check_brew_formula "glow"
check_brew_formula "watchexec"

# cmux CLI symlink
if [ ! -e /usr/local/bin/cmux ] && [ ! -L /usr/local/bin/cmux ]; then
  if [ -x "/Applications/cmux.app/Contents/Resources/bin/cmux" ]; then
    echo "  Creating cmux CLI symlink..."
    sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux
  else
    echo "  SKIP: cmux binary not found at /Applications/cmux.app" >&2
  fi
fi

# --------------------------------------------------
# 2. Symlink configs
# --------------------------------------------------
echo ""
echo "[2/4] Symlink configs"

# cmux scripts
symlink "$REPO_DIR/scripts/md-preview.sh" "$HOME/.config/cmux/scripts/md-preview.sh"
chmod +x "$REPO_DIR/scripts/md-preview.sh"

# yazi (only if no existing non-symlink config)
symlink "$REPO_DIR/config/yazi.toml" "$HOME/.config/yazi/yazi.toml"

# --------------------------------------------------
# 3. Ghostty config
# --------------------------------------------------
echo ""
echo "[3/4] Ghostty config"

GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
if [ -L "$GHOSTTY_CONFIG" ]; then
  echo "  SKIP: $GHOSTTY_CONFIG is a symlink, skipping append for safety" >&2
elif [ -f "$GHOSTTY_CONFIG" ]; then
  if ! grep -q "scrollback-limit" "$GHOSTTY_CONFIG"; then
    echo "" >> "$GHOSTTY_CONFIG"
    cat "$REPO_DIR/config/ghostty-append.conf" >> "$GHOSTTY_CONFIG"
    echo "  APPENDED: scrollback-limit to ghostty config"
  else
    echo "  SKIP: scrollback-limit already configured"
  fi
else
  echo "  SKIP: ghostty config not found"
fi

# --------------------------------------------------
# 4. Optional: git fsmonitor
# --------------------------------------------------
echo ""
echo "[4/4] Optional settings"

if ! git config --global --get core.fsmonitor &>/dev/null; then
  read -p "  Enable git fsmonitor for faster git status? [y/N]: " ENABLE_FSMON
  if [[ "$ENABLE_FSMON" =~ ^[Yy]$ ]]; then
    git config --global core.fsmonitor true
    echo "  OK: git core.fsmonitor enabled"
  fi
else
  echo "  OK: git fsmonitor already enabled"
fi

# --------------------------------------------------
# Done
# --------------------------------------------------
echo ""
echo "========================================="
echo " Setup complete!"
echo "========================================="
echo ""
echo " Usage:"
echo "   1. Copy or symlink cmux.json to your project root:"
echo "      ln -sf $REPO_DIR/cmux.json /path/to/project/cmux.json"
echo ""
echo "   2. Open cmux -> Cmd+J -> 'AI Dev Workspace'"
echo ""
echo " Layout:"
echo " ┌─────────────────┬──────────────────────────┐"
echo " │ [yazi | MD Prev] │                          │"
echo " │  surfaces切替    │     AI Terminal (メイン)   │"
echo " ├─────────────────┤                          │"
echo " │    lazygit       ├──────────────────────────┤"
echo " │                 │        Shell              │"
echo " └─────────────────┴──────────────────────────┘"
echo ""
echo " AI Terminal で claude / gemini / codex を起動してください"
