#!/usr/bin/env bash
set -euo pipefail

command -v gh >/dev/null && exit 0

case "$(uname -s)" in
  Darwin) brew install gh ;;
  Linux)
    # apt's gh is drastically behind upstream (2.45 vs 2.96+), so install
    # the official release .deb directly
    case "$(uname -m)" in
      x86_64)  GH_ARCH="amd64" ;;
      aarch64) GH_ARCH="arm64" ;;
    esac
    GH_VERSION="$(curl -s https://api.github.com/repos/cli/cli/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].lstrip("v"))')"
    curl -sL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${GH_ARCH}.deb" -o /tmp/gh.deb
    sudo apt install -y /tmp/gh.deb
    rm /tmp/gh.deb
    ;;
esac
