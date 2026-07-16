#!/usr/bin/env bash
set -euo pipefail

TMUX_VERSION="3.7b"
LIBEVENT_VERSION="2.1.12-stable"
NCURSES_VERSION="6.5"
BISON_VERSION="3.8.2"
M4_VERSION="1.4.19"

PREFIX="$HOME/.local"

installed_version() {
  "$PREFIX/bin/tmux" -V 2>/dev/null | awk '{print $2}'
}

case "$(uname -s)" in
  Darwin)
    command -v tmux >/dev/null || brew install tmux
    ;;
  Linux)
    if [ "$(installed_version)" != "$TMUX_VERSION" ]; then
      echo "==> Building tmux $TMUX_VERSION from source into $PREFIX"

      BUILD_DIR="$(mktemp -d)"
      TOOL_PREFIX="$BUILD_DIR/tools"
      mkdir -p "$TOOL_PREFIX"
      trap 'rm -rf "$BUILD_DIR"' EXIT
      export PATH="$TOOL_PREFIX/bin:$PATH"

      # tmux's configure requires yacc, which requires m4 to build if missing.
      if ! command -v yacc >/dev/null; then
        if ! command -v m4 >/dev/null; then
          echo "==> Building m4 (bison build dependency)"
          curl -fsSL "https://ftp.gnu.org/gnu/m4/m4-${M4_VERSION}.tar.gz" -o "$BUILD_DIR/m4.tar.gz"
          tar -xzf "$BUILD_DIR/m4.tar.gz" -C "$BUILD_DIR"
          (cd "$BUILD_DIR/m4-${M4_VERSION}" && ./configure --prefix="$TOOL_PREFIX" && make -j"$(nproc)" && make install) >/dev/null
        fi
        echo "==> Building bison (yacc replacement)"
        curl -fsSL "https://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz" -o "$BUILD_DIR/bison.tar.gz"
        tar -xzf "$BUILD_DIR/bison.tar.gz" -C "$BUILD_DIR"
        (cd "$BUILD_DIR/bison-${BISON_VERSION}" && ./configure --prefix="$TOOL_PREFIX" && make -j"$(nproc)" && make install) >/dev/null
        ln -sf "$TOOL_PREFIX/bin/bison" "$TOOL_PREFIX/bin/yacc"
      fi

      if [ ! -f /usr/include/event2/event.h ] && [ ! -f "$PREFIX/include/event2/event.h" ]; then
        echo "==> Building libevent (tmux build dependency)"
        curl -fsSL "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz" -o "$BUILD_DIR/libevent.tar.gz"
        tar -xzf "$BUILD_DIR/libevent.tar.gz" -C "$BUILD_DIR"
        (cd "$BUILD_DIR/libevent-${LIBEVENT_VERSION}" && ./configure --prefix="$PREFIX" --disable-shared --with-pic --disable-openssl && make -j"$(nproc)" && make install) >/dev/null
      fi

      if [ ! -f /usr/include/ncurses.h ] && [ ! -f /usr/include/ncursesw/curses.h ] && [ ! -f "$PREFIX/include/ncurses.h" ]; then
        echo "==> Building ncurses (tmux build dependency)"
        curl -fsSL "https://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz" -o "$BUILD_DIR/ncurses.tar.gz"
        tar -xzf "$BUILD_DIR/ncurses.tar.gz" -C "$BUILD_DIR"
        (cd "$BUILD_DIR/ncurses-${NCURSES_VERSION}" && ./configure --prefix="$PREFIX" --with-shared --enable-widec --enable-overwrite --without-debug && make -j"$(nproc)" && make install) >/dev/null

        # tmux's configure links -lncurses in addition to -lncursesw; alias the
        # wide-char libs since we only build the widec variant.
        ln -sf libncursesw.a "$PREFIX/lib/libncurses.a"
        ln -sf "libncursesw.so.$NCURSES_VERSION" "$PREFIX/lib/libncurses.so.${NCURSES_VERSION%%.*}"
        ln -sf "libncurses.so.${NCURSES_VERSION%%.*}" "$PREFIX/lib/libncurses.so"
      fi

      echo "==> Building tmux $TMUX_VERSION"
      curl -fsSL "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" -o "$BUILD_DIR/tmux.tar.gz"
      tar -xzf "$BUILD_DIR/tmux.tar.gz" -C "$BUILD_DIR"
      (
        cd "$BUILD_DIR/tmux-${TMUX_VERSION}"
        CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" ./configure --prefix="$PREFIX"
        make -j"$(nproc)"
        make install
      ) >/dev/null

      rm -rf "$BUILD_DIR"
      trap - EXIT
      echo "==> Installed $("$PREFIX/bin/tmux" -V)"
    fi
    ;;
esac

TMUX_CONFIG_DIR="$HOME/.config/tmux"
if [ ! -d "$TMUX_CONFIG_DIR" ]; then
  echo "==> Cloning tmux config into $TMUX_CONFIG_DIR"
  git clone git@github.com:huterguier/tmux.git "$TMUX_CONFIG_DIR"
fi
