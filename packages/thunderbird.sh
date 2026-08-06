#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  Darwin)
    [ -d "/Applications/Thunderbird.app" ] && exit 0
    brew install --cask thunderbird
    ;;
  Linux)
    command -v thunderbird >/dev/null && exit 0
    THUNDERBIRD_DIR="$HOME/.local/share/thunderbird"
    curl -sL "https://download.mozilla.org/?product=thunderbird-latest-ssl&os=linux64&lang=en-US" -o /tmp/thunderbird.tar
    mkdir -p "$THUNDERBIRD_DIR"
    # -a: Mozilla has shipped .tar.bz2 and .tar.xz over time, let tar detect it
    tar -xaf /tmp/thunderbird.tar -C "$THUNDERBIRD_DIR" --strip-components=1
    rm /tmp/thunderbird.tar

    mkdir -p "$HOME/.local/bin"
    ln -sf "$THUNDERBIRD_DIR/thunderbird" "$HOME/.local/bin/thunderbird"

    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/thunderbird.desktop" <<EOF
[Desktop Entry]
Name=Thunderbird
GenericName=Mail Client
Exec=$THUNDERBIRD_DIR/thunderbird %u
Icon=$THUNDERBIRD_DIR/chrome/icons/default/default128.png
Type=Application
Terminal=false
StartupNotify=true
StartupWMClass=thunderbird
Categories=Network;Email;
MimeType=message/rfc822;x-scheme-handler/mailto;x-scheme-handler/mid;text/calendar;text/x-vcard;
EOF
    ;;
esac
