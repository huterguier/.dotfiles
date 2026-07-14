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

    # cargo install only builds the binary — apt's package used to also
    # register a .desktop entry, which is what desktop environments and
    # x-terminal-emulator resolution actually look for
    if [ ! -f "$HOME/.local/share/applications/alacritty.desktop" ]; then
      mkdir -p "$HOME/.local/share/icons"
      curl -sL "https://github.com/alacritty/alacritty/releases/latest/download/Alacritty.svg" -o "$HOME/.local/share/icons/Alacritty.svg"
      mkdir -p "$HOME/.local/share/applications"
      cat > "$HOME/.local/share/applications/alacritty.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Alacritty
GenericName=Terminal
Comment=A fast, cross-platform, OpenGL terminal emulator
Exec=$HOME/.cargo/bin/alacritty
Icon=$HOME/.local/share/icons/Alacritty.svg
Terminal=false
Categories=System;TerminalEmulator;
EOF
    fi
    ;;
esac

ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
if [ ! -d "$ALACRITTY_CONFIG_DIR" ]; then
  echo "==> Cloning alacritty config into $ALACRITTY_CONFIG_DIR"
  git clone git@github.com:huterguier/alacritty.git "$ALACRITTY_CONFIG_DIR"
fi
