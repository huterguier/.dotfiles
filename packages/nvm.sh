#!/usr/bin/env bash
set -euo pipefail

export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  git -C "$NVM_DIR" checkout "$(git -C "$NVM_DIR" describe --abbrev=0 --tags)"
fi

# shellcheck disable=SC1091
\. "$NVM_DIR/nvm.sh"

if [ -z "$(ls -A "$NVM_DIR/versions/node" 2>/dev/null)" ]; then
  nvm install --lts
  nvm alias default 'lts/*'
fi
