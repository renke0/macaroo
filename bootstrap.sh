#!/usr/bin/env bash

# environment
export MACAROO_HOME="$HOME/.macaroo"
export MACAROO_TEMP="$MACAROO_HOME/temp"
export MACAROO_LOG="$MACAROO_HOME/macaroo.log"

# imports
source "$MACAROO_HOME/dotfiles/functions"
source "$MACAROO_HOME/dotfiles/ansi"
source "$MACAROO_HOME/helper.sh"

# functions
init() {
  msg "Initializing..."
  rm -f "$MACAROO_LOG"
  exec > "$MACAROO_LOG" 2>&1
  rm -rf "$MACAROO_TEMP"
  mkdir "$MACAROO_TEMP"
}

finalize() {
  msg "Cleaning up..."
  rm -rf "$MACAROO_TEMP"
  msg "Done!"
}

userconfig() {
  msg "Custom user configuration"
  store_password=$(xxd -l16 -ps /dev/urandom)
  export store_password
  userconfigs "$store_password" "$MACAROO_TEMP/config"
  divider
}

authorize() {
  sudo -v
  while true; do
    sudo -n true;
    sleep 60;
    kill -0 "$$" || exit;
  done 2>/dev/null &
}

# main script flow
authorize
init
splashscreen
source sdkman.sh
userconfig
source homebrew.sh
finalize
