for f in "${0:A:h}"/*.zsh; do
  source "$f"
done

chpwd
