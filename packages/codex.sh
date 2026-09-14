#!/usr/bin/env bash
set -euo pipefail

# no-op until codex is actually installed; this script only shares AGENTS.md,
# it does not install the CLI
command -v codex >/dev/null || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.codex"
ln -sfn "$SCRIPT_DIR/../agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
