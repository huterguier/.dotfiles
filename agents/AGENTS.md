# Environment

- Shell is zsh, editor is neovim (`vim` and `vi` are aliased to it).
- Machines are Ubuntu Linux and macOS — anything touching the system needs to work on both.
- Prefer `rg` over grep, `fd` over find, `gh` for GitHub, `uv` for Python.
- User-level installs go to `~/.local`; cargo installs to `~/.cargo/bin`. Don't install into
  system prefixes without asking.

# Responses

- Be brief. Lead with the answer, stop there, and let me ask for detail — I'd rather ask a
  follow-up than skim. If I say "tldr", the previous answer was too long.
- Structure is good — bullets and short sections beat paragraphs. Cut length, not structure.
- Don't restate my question, summarize what you just did, or list options you already
  rejected.
- Explaining your reasoning is worth it when a choice was non-obvious; not otherwise.

# Plans

- Plan at overview level: the steps, one line each, no implementation detail. I'll ask you to
  expand the points I don't follow — that's the normal flow, not a sign the plan was too thin.
- Name the files or components a step touches, since that's what I use to decide which step
  needs expanding.
- Flag real risks and unknowns inline, briefly. Don't pad with caveats I'd assume anyway.
