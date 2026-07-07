#!/usr/bin/env bash
set -euo pipefail

if ! command -v tmux >/dev/null; then
  case "$(uname -s)" in
    Darwin) brew install tmux ;;
    Linux)  sudo apt install -y tmux ;;
  esac
fi

TMUX_CONFIG_DIR="$HOME/.config/tmux"
if [ ! -d "$TMUX_CONFIG_DIR" ]; then
  echo "==> Cloning tmux config into $TMUX_CONFIG_DIR"
  git clone git@github.com:huterguier/tmux.git "$TMUX_CONFIG_DIR"
fi
