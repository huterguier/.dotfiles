#!/usr/bin/env bash
set -euo pipefail

command -v ffmpeg >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install ffmpeg ;;
  Linux)  sudo apt install -y ffmpeg ;;
esac
