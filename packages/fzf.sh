#!/usr/bin/env bash
set -euo pipefail

command -v fzf >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install fzf ;;
  Linux)
    # apt's fzf is drastically behind upstream (0.44 vs 0.74+), so install
    # the official release tarball directly
    case "$(uname -m)" in
      x86_64)  FZF_ARCH="amd64" ;;
      aarch64) FZF_ARCH="arm64" ;;
    esac
    FZF_VERSION="$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"
    curl -sL "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION#v}-linux_${FZF_ARCH}.tar.gz" -o /tmp/fzf.tar.gz
    mkdir -p "$HOME/.local/bin"
    tar -xzf /tmp/fzf.tar.gz -C "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/fzf"
    rm /tmp/fzf.tar.gz
    ;;
esac
