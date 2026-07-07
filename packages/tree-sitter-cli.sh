#!/usr/bin/env bash
set -euo pipefail

# tree-sitter-cli (apt's version lags several releases behind, e.g. 0.20 vs
# upstream 0.26+), so install the official release zip directly
command -v tree-sitter >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) TS_OS="macos" ;;
  Linux)  TS_OS="linux" ;;
esac

case "$(uname -m)" in
  arm64|aarch64) TS_ARCH="arm64" ;;
  x86_64)        TS_ARCH="x64" ;;
esac

command -v unzip >/dev/null || sudo apt install -y unzip

echo "==> Installing tree-sitter-cli (tree-sitter-cli-${TS_OS}-${TS_ARCH})"
curl -sL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-cli-${TS_OS}-${TS_ARCH}.zip" -o /tmp/tree-sitter.zip
mkdir -p "$HOME/.local/bin"
unzip -oq /tmp/tree-sitter.zip -d "$HOME/.local/bin"
chmod +x "$HOME/.local/bin/tree-sitter"
rm /tmp/tree-sitter.zip
