_tmux_status_refresh() {
  [[ -n "$TMUX" ]] && tmux refresh-client -S 2>/dev/null
}
precmd_functions+=(_tmux_status_refresh)
