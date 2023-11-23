#!/usr/bin/env bash

# environment
export MACAROO_HOME="$HOME/.macaroo"
export MACAROO_SCRIPTS="$MACAROO_HOME/scripts"
export MACAROO_RESOURCES="$MACAROO_HOME/resources"
export MACAROO_TEMP="$MACAROO_HOME/.temp"
export MACAROO_LOG="$HOME/Library/Logs/macaroo.log"
export MACAROO_ERROR_LOG="$HOME/Library/Logs/macaroo-error.log"
export MACAROO_TS="$MACAROO_HOME/macaroo.ts"

# imports
source "$MACAROO_HOME/dotfiles/functions"
source "$MACAROO_SCRIPTS/commons.sh"
source "$MACAROO_SCRIPTS/homebrew.sh"
source "$MACAROO_SCRIPTS/user_configuration.sh"
source "$MACAROO_SCRIPTS/sdkman.sh"
source "$MACAROO_SCRIPTS/node.sh"
source "$MACAROO_SCRIPTS/git.sh"
source "$MACAROO_SCRIPTS/prezto.sh"
source "$MACAROO_SCRIPTS/docker.sh"
source "$MACAROO_SCRIPTS/dotfiles.sh"
source "$MACAROO_SCRIPTS/macos.sh"
source "$MACAROO_SCRIPTS/dev_flags.sh"
source "$MACAROO_SCRIPTS/post_install.sh"

git_default_profiles=("me" "work")

bootstrap() {
  _init_bootstrap
  init_flags "$@"

  install_homebrew
  println

  install_node
  println

  read_user_configuration "${git_default_profiles[@]}"
  println

  install_homebrew_packages
  println

  configure_git
  println

  install_sdkman
  println

  install_prezto
  println

  configure_docker
  println
  configure_dotfiles
  println

  configure_macos
  println

  _finalize_bootstrap
}

# functions
_init_bootstrap() {
  _authorize

  msg "Initializing..."

  rm -f "$MACAROO_LOG"
  rm -f "$MACAROO_ERROR_LOG"
  touch "$MACAROO_LOG"
  touch "$MACAROO_ERROR_LOG"
  exec > "$MACAROO_LOG" 2> "$MACAROO_ERROR_LOG"

  rm -rf "$MACAROO_TEMP"
  mkdir "$MACAROO_TEMP"

  splashscreen
}

_finalize_bootstrap() {
  msg "Finalizing configurations..."
  link_macaroo_to_repo
  use_zsh
  create_notunes_login_item

  msg "Cleaning up..."
  rm -rf "$MACAROO_TEMP"
  msg "All set!"
}

_authorize() {
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2> /dev/null &
}

bootstrap "$@"
