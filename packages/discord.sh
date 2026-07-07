#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    [ -d /Applications/Discord.app ] && exit 0
    brew install --cask discord
    ;;
  Linux)
    command -v discord >/dev/null && exit 0
    curl -sL "https://discord.com/api/download?platform=linux&format=deb" -o /tmp/discord.deb
    sudo apt install -y /tmp/discord.deb
    rm /tmp/discord.deb
    ;;
esac
