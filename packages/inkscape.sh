#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    [ -d /Applications/Inkscape.app ] && exit 0
    brew install --cask inkscape
    ;;
  Linux)
    command -v inkscape >/dev/null && exit 0
    # apt's default archive version is stale; Inkscape's own official PPA
    # tracks current stable releases
    command -v add-apt-repository >/dev/null || sudo apt install -y software-properties-common
    if ! grep -qR "inkscape.dev/stable" /etc/apt/sources.list.d/ 2>/dev/null; then
      sudo add-apt-repository -y ppa:inkscape.dev/stable
      sudo apt update
    fi
    sudo apt install -y inkscape
    ;;
esac
