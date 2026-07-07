#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    if [ ! -d /Applications/Alacritty.app ]; then
      brew install --cask alacritty
      # the cask fails Apple's Gatekeeper check (unsigned build), so clear
      # the quarantine flag ourselves instead of doing it by hand each time
      xattr -cr /Applications/Alacritty.app
    fi
    ;;
  Linux)
    if ! command -v alacritty >/dev/null; then
      # apt's version is ancient and the community PPA is shaky/unmaintained,
      # so build from source via cargo instead
      SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
      bash "$SCRIPT_DIR/rust.sh"
      sudo apt install -y cmake pkg-config libfreetype-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
      "$HOME/.cargo/bin/cargo" install alacritty
    fi
    ;;
esac

ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
if [ ! -d "$ALACRITTY_CONFIG_DIR" ]; then
  echo "==> Cloning alacritty config into $ALACRITTY_CONFIG_DIR"
  git clone git@github.com:huterguier/alacritty.git "$ALACRITTY_CONFIG_DIR"
fi
