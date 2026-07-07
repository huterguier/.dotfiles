#!/usr/bin/env bash
set -euo pipefail

# command -v <tool> >/dev/null || <install command>

if [ "$(uname -s)" = "Darwin" ] && [ ! -d /Applications/Alacritty.app ]; then
  echo "NOTE: Alacritty not found in /Applications — install manually from https://alacritty.org (Homebrew cask is deprecated)"
fi
