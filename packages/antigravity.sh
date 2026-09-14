#!/usr/bin/env bash
set -euo pipefail

# no-op until Antigravity is installed. Note ~/.gemini/GEMINI.md is shared with
# the Gemini CLI, so the two collide if you ever run both.
[ -d "$HOME/.gemini" ] || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sfn "$SCRIPT_DIR/../agents/AGENTS.md" "$HOME/.gemini/GEMINI.md"
