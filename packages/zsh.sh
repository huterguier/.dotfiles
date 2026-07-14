#!/usr/bin/env bash
set -euo pipefail

if ! command -v zsh >/dev/null; then
  case "$(uname -s)" in
    Darwin) brew install zsh ;;
    Linux)
      if [ -n "${NO_SUDO:-}" ]; then
        # no root: install a static zsh into ~/.local via zsh-bin
        curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install -o /tmp/zsh-bin-install
        sh /tmp/zsh-bin-install -d "$HOME/.local" -e no
        rm /tmp/zsh-bin-install
      else
        sudo apt install -y zsh
      fi
      ;;
  esac
fi

if [ -n "${NO_SUDO:-}" ]; then
  # chsh is usually disabled on machines without root (LDAP accounts), so
  # drop into zsh from bash for interactive logins instead
  if ! grep -qF 'exec zsh -l' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
if [ -t 1 ] && [ -z "${ZSH_VERSION:-}" ] && command -v zsh >/dev/null; then
  exec zsh -l
fi
EOF
  fi
elif [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
fi
