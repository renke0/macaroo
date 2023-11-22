#!/usr/bin/env bash

install_prezto() {
  if [ "$SKIP_PREZTO" == "true" ]; then
    msg "Skipping Prezto config"
    return;
  fi
  source "$MACAROO_HOME/dotfiles/functions"
  source "$MACAROO_SCRIPTS/commons.sh"

  preztodir="$HOME/.zprezto"

  msg "Configuring Prezto"
  toolname "prezto"
  # Checkout Prezto from their github repo
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "$preztodir"

  # Replace zpreztorc and zshrc inside prezto's repo with symlinks to our versions
  for file in "zlogin" "zlogout" "zprofile" "zshenv"; do
    symlink "$preztodir/runcoms/$file" "$HOME/.$file"
  done
  markdone
  msg "Done."
}
