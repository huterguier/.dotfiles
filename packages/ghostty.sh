#!/usr/bin/env bash
set -euo pipefail

GHOSTTY_VERSION="1.3.1"

GHOSTTY_DIR="$HOME/.local/share/ghostty"

installed_version() {
  "$GHOSTTY_DIR/AppRun" --version 2>/dev/null | awk 'NR==1 {print $2}'
}

case "$(uname -s)" in
  Darwin)
    # no `exit 0` when it's already installed — the config clone below still
    # has to run
    if [ ! -d "/Applications/Ghostty.app" ]; then
      # the cask is signed and notarized, so no quarantine flag to clear
      brew install --cask ghostty
    fi
    ;;
  Linux)
    if [ "$(installed_version)" != "$GHOSTTY_VERSION" ]; then
      # upstream ships no prebuilt Linux binary (only macOS builds and a source
      # tarball, which would mean pulling in a whole zig toolchain), and apt
      # has no ghostty before Ubuntu 25.10 — so use the community AppImage
      echo "==> Installing ghostty $GHOSTTY_VERSION into $GHOSTTY_DIR"

      case "$(uname -m)" in
        x86_64) GHOSTTY_ARCH="x86_64" ;;
        aarch64 | arm64) GHOSTTY_ARCH="aarch64" ;;
        *) echo "ghostty: unsupported architecture $(uname -m)" >&2; exit 1 ;;
      esac

      BUILD_DIR="$(mktemp -d)"
      trap 'rm -rf "$BUILD_DIR"' EXIT

      curl -fsSL "https://github.com/psadi/ghostty-appimage/releases/download/v${GHOSTTY_VERSION}/Ghostty-${GHOSTTY_VERSION}-${GHOSTTY_ARCH}.AppImage" -o "$BUILD_DIR/ghostty.AppImage"
      chmod +x "$BUILD_DIR/ghostty.AppImage"

      # unpack rather than run the AppImage in place: mounting one needs libfuse2,
      # which isn't installed by default since Ubuntu 22.04
      (cd "$BUILD_DIR" && ./ghostty.AppImage --appimage-extract) >/dev/null

      # the extractor leaves squashfs-root as a symlink to the real AppDir, so
      # resolve it — moving the symlink itself would strand the actual tree
      EXTRACTED="$(cd "$BUILD_DIR/squashfs-root" && pwd -P)"

      rm -rf "$GHOSTTY_DIR"
      mkdir -p "$(dirname "$GHOSTTY_DIR")"
      mv "$EXTRACTED" "$GHOSTTY_DIR"

      rm -rf "$BUILD_DIR"
      trap - EXIT
      echo "==> Installed ghostty $(installed_version)"
    fi

    # AppRun sets up the bundled libs (bin/ghostty on its own picks up the
    # host's too-old gtk and fails), but it derives the app dir from $0 — so it
    # has to be a wrapper rather than the usual symlink, which would resolve to
    # ~/.local/bin. ARGV0 is what AppRun reads to pick the binary to launch.
    mkdir -p "$HOME/.local/bin"
    rm -f "$HOME/.local/bin/ghostty"
    cat > "$HOME/.local/bin/ghostty" <<EOF
#!/bin/sh
exec env ARGV0=ghostty "$GHOSTTY_DIR/AppRun" "\$@"
EOF
    chmod +x "$HOME/.local/bin/ghostty"

    # ghostty hands its own bundled terminfo to the shells it spawns, but
    # anything else resolving TERM=xterm-ghostty (ssh into this box, sudo,
    # a curses app under a plain tmux) reads the user db instead
    mkdir -p "$HOME/.terminfo"
    cp -r "$GHOSTTY_DIR/share/terminfo/." "$HOME/.terminfo/"

    # the .desktop file inside the AppImage hardcodes the CI machine's build
    # paths in Exec/TryExec, so write our own instead of copying it out
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/com.mitchellh.ghostty.desktop" <<EOF
[Desktop Entry]
Name=Ghostty
GenericName=Terminal
Comment=A fast, feature-rich, cross-platform terminal emulator
TryExec=$GHOSTTY_DIR/AppRun
Exec=$GHOSTTY_DIR/AppRun --gtk-single-instance=true
Icon=$GHOSTTY_DIR/com.mitchellh.ghostty.png
Type=Application
Terminal=false
StartupNotify=true
StartupWMClass=com.mitchellh.ghostty
Categories=System;TerminalEmulator;
Keywords=terminal;tty;pty;
Actions=new-window;
X-TerminalArgExec=-e
X-TerminalArgTitle=--title=
X-TerminalArgAppId=--class=
X-TerminalArgDir=--working-directory=
X-TerminalArgHold=--wait-after-command

[Desktop Action new-window]
Name=New Window
Exec=$GHOSTTY_DIR/AppRun --gtk-single-instance=true
EOF
    ;;
esac

GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
if [ ! -d "$GHOSTTY_CONFIG_DIR" ]; then
  echo "==> Cloning ghostty config into $GHOSTTY_CONFIG_DIR"
  git clone git@github.com:huterguier/ghostty.git "$GHOSTTY_CONFIG_DIR"
fi
