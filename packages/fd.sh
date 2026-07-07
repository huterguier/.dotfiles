#!/usr/bin/env bash
set -euo pipefail

command -v fd >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install fd ;;
  Linux)
    # apt's fd-find is stale and installs the binary as `fdfind` (name clash
    # with an unrelated package), so use upstream's own .deb instead
    case "$(uname -m)" in
      x86_64)  FD_ARCH="amd64" ;;
      aarch64) FD_ARCH="arm64" ;;
    esac
    FD_VERSION="$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].lstrip("v"))')"
    curl -sL "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_${FD_ARCH}.deb" -o /tmp/fd.deb
    sudo apt install -y /tmp/fd.deb
    rm /tmp/fd.deb
    ;;
esac
