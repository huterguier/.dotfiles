#!/usr/bin/env bash
set -euo pipefail

command -v teamtype >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install teamtype ;;
  Linux)
    # teamtype isn't packaged in apt, so install the official static binary
    case "$(uname -m)" in
      x86_64)  TT_ARCH="x86_64" ;;
      aarch64) TT_ARCH="aarch64" ;;
    esac
    curl -sL "https://github.com/teamtype/teamtype/releases/latest/download/teamtype-${TT_ARCH}-linux-static.tar.gz" -o /tmp/teamtype.tar.gz
    mkdir -p "$HOME/.local/bin"
    tar -xzf /tmp/teamtype.tar.gz -C "$HOME/.local/bin" teamtype
    chmod +x "$HOME/.local/bin/teamtype"
    rm /tmp/teamtype.tar.gz
    ;;
esac
