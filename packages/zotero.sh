#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    [ -d "/Applications/Zotero.app" ] && exit 0
    brew install --cask zotero
    ;;
  Linux)
    command -v zotero >/dev/null && exit 0
    ZOTERO_DIR="$HOME/.local/share/zotero"
    curl -sL "https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64" -o /tmp/zotero.tar.xz
    mkdir -p "$ZOTERO_DIR"
    tar -xJf /tmp/zotero.tar.xz -C "$ZOTERO_DIR" --strip-components=1
    rm /tmp/zotero.tar.xz

    mkdir -p "$HOME/.local/bin"
    ln -sf "$ZOTERO_DIR/zotero" "$HOME/.local/bin/zotero"

    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/zotero.desktop" <<EOF
[Desktop Entry]
Name=Zotero
Exec=$ZOTERO_DIR/zotero -url %U
Icon=$ZOTERO_DIR/icons/icon128.png
Type=Application
Terminal=false
Categories=Office;
MimeType=text/plain;x-scheme-handler/zotero;application/x-research-info-systems;text/x-research-info-systems;text/ris;application/x-endnote-refer;application/x-inst-for-Scientific-info;application/mods+xml;application/rdf+xml;application/x-bibtex;text/x-bibtex;application/marc;application/vnd.citationstyles.style+xml
X-GNOME-SingleWindow=true
EOF
    ;;
esac
