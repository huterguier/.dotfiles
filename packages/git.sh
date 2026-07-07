#!/usr/bin/env bash
set -euo pipefail

command -v git >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install git ;;
  Linux)  sudo apt install -y git ;;
esac
