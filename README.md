# dotfiles

## Setup

```sh
git clone git@github.com:huterguier/.dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install.sh
```

Running `install.sh` again is safe — every step is guarded and skips anything already in place.

## Layout

- `zsh/` — shell config. `~/.zshrc` stays a real, untracked file; `install.sh` adds a single
  `source` line pointing at `zsh/zshrc.sh`, which in turn sources every other `*.zsh` file in
  this directory. Anything installers (nvm, cargo, etc.) append to `~/.zshrc` directly stays
  local and untracked.
- `packages/` — `Brewfile` (macOS), `apt.txt` (Ubuntu), and `custom.sh` for anything installed
  by hand (curl scripts, manual builds). Entries in `custom.sh` are guarded with
  `command -v <tool> >/dev/null || <install command>` so re-running is a no-op once installed.

nvim, tmux, and alacritty configs are **not** in this repo — they're their own repos
(`huterguier/nvim`, `/tmux`, `/alacritty`) cloned by `install.sh` straight into
`~/.config/<tool>`, since that's where those tools require their config to live.

## Manual steps

- **Alacritty on macOS** — the Homebrew cask is deprecated, so install it by hand from
  https://alacritty.org (or the GitHub releases page) rather than expecting `install.sh` to
  handle it.
