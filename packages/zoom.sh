#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    [ -d "/Applications/zoom.us.app" ] && exit 0
    brew install --cask zoom
    ;;
  Linux)
    command -v zoom >/dev/null && exit 0
    curl -sL "https://zoom.us/client/latest/zoom_amd64.deb" -o /tmp/zoom.deb
    sudo apt install -y /tmp/zoom.deb
    rm /tmp/zoom.deb
    ;;
esac
