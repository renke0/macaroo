#!/usr/bin/env bash

# environment
export MACAROO_HOME="$HOME/.macaroo"
export MACAROO_TEMP="$MACAROO_HOME/temp"
export MACAROO_LOG="$MACAROO_HOME/macaroo.log"

# dev flags
export SKIP_SDKMAN=true
export SKIP_HOMEBREW=true
export SKIP_DOCKER=true
export SKIP_NODE=true
export SKIP_PREZTO=false
export SKIP_GIT=true
export SKIP_ITERM2=true
export SKIP_MACOS=true

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
  msg "All set!"
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
source node.sh
source prezto.sh
source docker.sh
finalize
