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

sopen() {
  if [ -z "$1" ]; then
    echo "usage: sopen host:remote/path/to/file" >&2
    return 1
  fi

  local remote="$1" host path tmpdir local_file opener

  host="${remote%%:*}"
  path="${remote#*:}"
  if [ "$host" = "$remote" ]; then
    echo "sopen: expected host:path (e.g. myserver:~/pic.png)" >&2
    return 1
  fi

  tmpdir=$(mktemp -d) || return 1
  local_file="$tmpdir/$(basename "$path")"

  if ! scp -q "$remote" "$local_file"; then
    rm -rf "$tmpdir"
    return 1
  fi

  case "$(uname -s)" in
    Darwin) opener="open" ;;
    Linux)  opener="xdg-open" ;;
  esac

  "$opener" "$local_file" >/dev/null 2>&1 &
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
