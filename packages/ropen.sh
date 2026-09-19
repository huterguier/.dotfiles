#!/usr/bin/env bash
set -euo pipefail

# Only the machine you sit at runs the listener; remote hosts just need the
# `ropen` function from zsh/functions.zsh and a token (see `ropen-setup`).
[ "$(uname -s)" = "Darwin" ] || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LISTENER="$(dirname "$SCRIPT_DIR")/bin/ropen-listen"
LABEL="local.ropen-listen"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
TOKEN_FILE="$HOME/.config/ropen/token"

if [ ! -s "$TOKEN_FILE" ]; then
  mkdir -p "$(dirname "$TOKEN_FILE")"
  (umask 077 && openssl rand -hex 32 > "$TOKEN_FILE")
fi

NEW_PLIST="$(mktemp)"
trap 'rm -f "$NEW_PLIST"' EXIT
cat > "$NEW_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array><string>/bin/zsh</string><string>$LISTENER</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/ropen-listen.log</string>
</dict>
</plist>
EOF

if cmp -s "$NEW_PLIST" "$PLIST" && launchctl print "gui/$UID/$LABEL" >/dev/null 2>&1; then
  exit 0
fi

mkdir -p "$(dirname "$PLIST")"
cp "$NEW_PLIST" "$PLIST"
launchctl bootout "gui/$UID/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID" "$PLIST"
