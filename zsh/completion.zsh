# Initialize zsh's completion system (compsys).
# -i: skip insecure fpath dirs instead of prompting at startup (shared Linux hosts)
# -d: per-host/per-version dump, so a shared $HOME doesn't cause cache clashes
autoload -Uz compinit
compinit -i -d "$HOME/.zcompdump-${HOST}-${ZSH_VERSION}"
