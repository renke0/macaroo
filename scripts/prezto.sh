#!/usr/bin/env bash

install_prezto() {
  if [ "$SKIP_PREZTO" == "true" ]; then
    msg "Skipping Prezto config"
    return
  fi
  source "$MACAROO_HOME/dotfiles/functions"
  source "$MACAROO_SCRIPTS/commons.sh"

  preztodir="$HOME/.zprezto"

  msg "Configuring Prezto"
  toolname "prezto"
  # Checkout Prezto from their github repo
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "$preztodir"

  markdone
  msg "Done."
}
