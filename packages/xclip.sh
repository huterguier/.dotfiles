#!/usr/bin/env bash
set -euo pipefail

[ "$(uname -s)" = "Linux" ] || exit 0
command -v xclip >/dev/null && exit 0

sudo apt install -y xclip
