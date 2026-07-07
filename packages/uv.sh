#!/usr/bin/env bash
set -euo pipefail

command -v uv >/dev/null && exit 0

curl -LsSf https://astral.sh/uv/install.sh | sh
