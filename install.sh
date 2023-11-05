#!/usr/bin/env bash

echo "Setting up your Mac 💻"

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `macos` has finished
while true; do
  sudo -n true;
  sleep 60;
  kill -0 "$$" || exit;
done 2>/dev/null &

read -rp "What is the name you want to give to this computer? " computer_name

source ./brew/setup
source ./sdkman/setup
source ./dotfiles/setup
source ./docker/setup
source ./git/setup
source ./iterm2/setup
source ./macos/setup "$computer_name"
