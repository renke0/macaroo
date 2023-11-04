#!/usr/bin/env bash

echo "Setting up your Mac 💻"

read -rp "What is the name you want to give to this computer? " computer_name

source ./brew
source ./sdkman
source ./link-dotfiles
source ./docker
source ./macos "$computer_name"
