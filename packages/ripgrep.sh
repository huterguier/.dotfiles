#!/usr/bin/env bash
set -euo pipefail

command -v rg >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install ripgrep ;;
  Linux)  sudo apt install -y ripgrep ;;
esac
