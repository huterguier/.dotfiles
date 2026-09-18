#!/usr/bin/env bash
set -euo pipefail

# No early `command -v claude && exit 0` guard here: even when the CLI is already
# installed we still want to (re-)wire the config symlinks below.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(dirname "$SCRIPT_DIR")/agents"
CLAUDE_DIR="$HOME/.claude"

command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash

# ~/.claude is mostly runtime state (projects/, history.jsonl, .credentials.json), so
# link the tracked config in file by file rather than symlinking the directory itself.
link() {
  [ -e "$1" ] || return 0
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    mv "$2" "$2.bak"
    echo "==> Backed up $2 -> $2.bak"
  fi
  # -n so re-running replaces the link instead of descending into it
  ln -sfn "$1" "$2"
}

mkdir -p "$CLAUDE_DIR"
link "$AGENTS_DIR/AGENTS.md"            "$CLAUDE_DIR/CLAUDE.md"
link "$AGENTS_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
link "$AGENTS_DIR/claude/commands"      "$CLAUDE_DIR/commands"
link "$AGENTS_DIR/claude/agents"        "$CLAUDE_DIR/agents"
link "$AGENTS_DIR/skills"               "$CLAUDE_DIR/skills"
