tm() {
  local dir name

  if dir=$(git rev-parse --show-toplevel 2>/dev/null); then
    name=$(basename "$dir")
  else
    dir=$(pwd)
    name="$dir"
  fi
  name=${name//./_}
  name=${name//:/_}

  if ! tmux has-session -t "$name" 2>/dev/null; then
    tmux new-session -ds "$name" -c "$dir"
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$name"
  else
    tmux attach-session -t "$name"
  fi
}

chpwd() {
  if [[ -n "$VIRTUAL_ENV" ]] && { [[ "$PWD"/ != "$(dirname "$VIRTUAL_ENV")"/* ]] || ! type deactivate &>/dev/null; }; then
    if type deactivate &>/dev/null; then
      deactivate
    else
      unset VIRTUAL_ENV
    fi
  fi

  [[ -z "$VIRTUAL_ENV" && -f ./.venv/bin/activate ]] && source ./.venv/bin/activate
}

chpwd
