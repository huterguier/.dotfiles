export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/nvim/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

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
