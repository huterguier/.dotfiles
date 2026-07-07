#!/usr/bin/env bash
set -euo pipefail

command -v cargo >/dev/null && exit 0
[ -x "$HOME/.cargo/bin/cargo" ] && exit 0

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
