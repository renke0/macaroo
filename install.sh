#!/usr/bin/env bash

echo "Setting up your Mac 💻"

read -rp "What is the name you want to give to this computer? " computer_name

# Install HomeBrew if not yet installed
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install SDKMAN! if not yet installed
if test ! "$(which sdk)"; then
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Create a backup of a file by moving it and appending ".backup" to its name
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "$target was backed up to $target.backup"
    fi
  fi
}

# Create a symlink of a file
symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    echo "Creating link of $file to $link"
    ln -s "$file" "$link"
  fi
}

# Iterate over the files in dotfiles and create links to them in the home directory
for file in dotfiles/*
do
  if [ ! -d "$file" ]; then
    target="$HOME/.$file"
    backup "$target"
    symlink "$PWD/$file" "$target"
  fi
done

# Install all dependencies configured in the Brewfile
brew update
brew upgrade
brew tap homebrew/bundle
brew bundle --file ./Brewfile
brew cleanup

# Setup docker
source ./docker

# Setup macos preferences
source ./macos "$computer_name"
