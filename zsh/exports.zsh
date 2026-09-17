export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

for _local_share_bin in "$HOME"/.local/share/*/bin(N); do
  export PATH="$_local_share_bin:$PATH"
done
unset _local_share_bin

export NVM_DIR="$HOME/.nvm"

for _nvm_bin in "$NVM_DIR"/versions/node/*/bin(N); do
  export PATH="$_nvm_bin:$PATH"
done
unset _nvm_bin

nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
  nvm "$@"
}

export WANDB_USE_DOT_WANDB=true
