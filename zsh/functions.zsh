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

  # not `path`: zsh ties that to $PATH, so a local one blanks PATH for the
  # rest of the function and nothing external resolves any more
  local remote="$1" host rpath local_file opener

  host="${remote%%:*}"
  rpath="${remote#*:}"
  if [ "$host" = "$remote" ]; then
    echo "sopen: expected host:path (e.g. myserver:~/pic.png)" >&2
    return 1
  fi

  # stable path per remote file: re-opening overwrites the copy, so the viewer
  # reloads its existing window instead of spawning a new one
  local_file="$HOME/.cache/ropen/$host/${rpath#/}"
  mkdir -p "$(dirname "$local_file")" || return 1

  scp -q -- "$remote" "$local_file" || return 1

  case "$(uname -s)" in
    Darwin) opener="open" ;;
    Linux)  opener="xdg-open" ;;
    *)
      echo "sopen: no opener known for $(uname -s)" >&2
      return 1
      ;;
  esac

  "$opener" "$local_file" >/dev/null 2>&1 &
}

# run on the remote end of an ssh session: asks bin/ropen-listen on the local
# machine (via the RemoteForward on port 7878) to fetch and open a file or URL
ropen() {
  if [ -z "$1" ]; then
    echo "usage: ropen file|url" >&2
    return 1
  fi

  local dir="$HOME/.config/ropen" target

  if ! [ -r "$dir/token" ] || ! [ -r "$dir/host" ]; then
    echo "ropen: not set up on this host (run ropen-setup <host> on the local machine)" >&2
    return 1
  fi

  case "$1" in
    http://*|https://*) target="$1" ;;
    *)
      if ! [ -f "$1" ]; then
        echo "ropen: $1: no such file" >&2
        return 1
      fi
      target="$(<"$dir/host"):$(realpath "$1")"
      ;;
  esac

  # piped rather than passed as an argument so the token never shows up in ps
  if ! print -r -- "$(<"$dir/token") $target" | bash -c 'cat > /dev/tcp/127.0.0.1/7878' 2>/dev/null; then
    echo "ropen: no tunnel on port 7878" >&2
    return 1
  fi
}

# run on the local machine: copies the ropen token to a host and records the
# ssh alias the host should identify itself with
ropen-setup() {
  local host="$1" token_file="$HOME/.config/ropen/token"

  if [ -z "$host" ]; then
    echo "usage: ropen-setup host" >&2
    return 1
  fi
  if ! [ -r "$token_file" ]; then
    echo "ropen-setup: no token, run packages/ropen.sh first" >&2
    return 1
  fi

  ssh "$host" "umask 077 && mkdir -p ~/.config/ropen && cat > ~/.config/ropen/token && echo '$host' > ~/.config/ropen/host" < "$token_file"
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
