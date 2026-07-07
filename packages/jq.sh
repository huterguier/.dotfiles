#!/usr/bin/env bash
set -euo pipefail

command -v jq >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install jq ;;
  Linux)  sudo apt install -y jq ;;
esac
