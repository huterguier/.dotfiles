# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles repo (zsh + vim + per-package install scripts + fonts). One entry point,
`install.sh`, sets everything up on a fresh machine (macOS or Ubuntu). There is no
build/lint/test tooling — this is shell config, not application code.

## Commands

```sh
bash ~/.dotfiles/install.sh
```

Re-running it is always safe: every step is guarded (dir existence checks, `grep -qxF`,
`command -v` checks) so it's idempotent and skips anything already in place. There is no
separate test suite; the way to verify a change is to run `install.sh` (or just the one
`packages/<tool>.sh` you touched) and/or open a new shell and confirm the affected behavior.

## Architecture

`install.sh` is the only entry point and does everything in order: wire zsh → wire vim →
install fonts → run every `packages/*.sh` in turn. It detects OS via `uname -s` and branches
on `Darwin` vs `Linux` for the font directory; per-package OS branching lives in the package
scripts themselves.

- **zsh loading model**: `~/.zshrc` stays a real, untracked, user-owned file. `install.sh`
  appends a single `source "$DOTFILES_DIR/zsh/zshrc.sh"` line to it (once, guarded by
  `grep -qxF`). `zsh/zshrc.sh` then sources every `*.zsh` file in `zsh/` automatically —
  so adding a new `zsh/whatever.zsh` file is enough to have it loaded; nothing else needs
  to reference it. Anything installers (nvm, cargo, etc.) append directly to `~/.zshrc`
  stays local/untracked and is not part of this repo.
- **vim** is wired the same way: `install.sh` appends a single `source .../vim/vimrc.vim`
  line to `~/.vimrc`, guarded by `grep -qxF`.
- **Package installation**: one script per tool, `packages/<tool>.sh`, all run by
  `install.sh`'s loop over `packages/*.sh`. Adding a new file there is enough to have it
  run — nothing needs to register it. Each script is standalone (`#!/usr/bin/env bash`,
  `set -euo pipefail`), guards itself with `command -v <tool> >/dev/null && exit 0` or a
  path/app-bundle check so re-running is a no-op, and branches on `uname -s` internally
  (`brew`/`brew install --cask` on Darwin, apt or an upstream tarball/build on Linux).
  Scripts may invoke each other by path (via a `SCRIPT_DIR`-relative `bash` call) when
  there's a real build dependency, though nothing does so right now.
- **`NO_SUDO`**: `install.sh` sets `NO_SUDO=1` when `sudo -v` isn't available, then skips
  any package script that mentions `sudo` but not `NO_SUDO`. A script that wants to run on
  root-less machines must handle the case itself and reference `NO_SUDO` by name (see
  `zsh.sh`, which falls back to a static `zsh-bin` build into `~/.local` and appends an
  `exec zsh -l` to `~/.bashrc` instead of running `chsh`).
- **Install prefixes**: user-level installs go to `~/.local` (`bin/`, or
  `~/.local/share/<tool>/` for unpacked app trees) and cargo installs to `~/.cargo/bin`.
  `zsh/exports.zsh` puts `~/.local/bin` and `~/.cargo/bin` on `PATH` and auto-globs every
  `~/.local/share/*/bin` directory, so a tarball unpacked there needs no `PATH` edit.
- **Coding agents**: `agents/` holds agent config. `agents/AGENTS.md` is the canonical,
  tool-neutral instruction file (the name most agents read), and `agents/skills/` holds
  tool-neutral Agent Skills (`<name>/SKILL.md`); per-tool config lives in `agents/<tool>/`.
  `packages/claude.sh` symlinks them in as `~/.claude/CLAUDE.md` and `~/.claude/skills`, along
  with `agents/claude/{settings.json,commands,agents}`. The links are per-file on purpose —
  `~/.claude` is mostly runtime state (`projects/`, `history.jsonl`, `.credentials.json`) and
  must stay a real directory. Its `link()` helper skips sources that don't exist, so only the
  subdirectories actually in the repo get linked, uses `ln -sfn` (`-n` so re-running replaces
  the link instead of nesting inside it), and moves a pre-existing real file aside to `.bak`
  once. Unlike the other package scripts it has no early `command -v` exit — the CLI install
  is guarded on its own so the symlink wiring still runs on every invocation.
- **Desktop entries**: GUI apps installed outside the distro package manager on Linux
  (thunderbird, zotero, alacritty) get a hand-written
  `~/.local/share/applications/<app>.desktop`, since only a distro package would otherwise
  register one.
- **External tool configs are separate repos**, not part of this one: nvim, tmux, and
  alacritty configs live in `huterguier/nvim`, `huterguier/tmux`, `huterguier/alacritty`
  and are cloned into `~/.config/<tool>` at the end of the corresponding
  `packages/<tool>.sh`, since that's where those tools require their config to live. Don't
  try to find nvim/tmux/alacritty config in this repo — it isn't here. The clones use SSH
  remotes, so they need a working GitHub SSH key.
- **Upstream-over-distro**: several tools deliberately bypass the system package manager
  because the packaged version lags badly or is otherwise unusable — nvim, fzf, and
  alacritty all say so in a comment. `tmux.sh` goes furthest and builds tmux from source into `~/.local`, including
  building m4/bison/libevent/ncurses first when they're missing; it's pinned to
  `TMUX_VERSION` and rebuilds when the installed `tmux -V` doesn't match.
- **Fonts**: `fonts/*/*.ttf` are installed by symlink on Linux (`~/.local/share/fonts`) and
  by copy on macOS (`~/Library/Fonts`, since Finder/Font Book don't reliably pick up
  symlinked fonts), followed by `fc-cache` on Linux.
