#!/usr/bin/env bash

source "$MACAROO_HOME/dotfiles/ansi"
source "$MACAROO_HOME/helper.sh"

msg "Finalizing configurations..."

# set the default shell
chsh -s /bin/zsh

# make notunes start on login
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/noTunes.app", hidden:true}'
