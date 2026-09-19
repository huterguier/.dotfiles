#!/usr/bin/env bash
set -euo pipefail

command -v mslurm >/dev/null && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# runs before uv.sh alphabetically, so make sure uv is there first
bash "$SCRIPT_DIR/uv.sh"
export PATH="$HOME/.local/bin:$PATH"

uv tool install git+https://github.com/huterguier/mslurm
