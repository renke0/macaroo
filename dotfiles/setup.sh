#!/usr/bin/env bash

source "$HOME/.mac-config/functions.sh"

# Iterate over the files in dotfiles and create links to them in the home directory
for file in *; do
  if [ ! -d "$file" ] && [ "$file" != "setup" ]; then
    target="$HOME/.$(basename "$file")"
    backup "$target"
    symlink "./$file" "$target"
  fi
done
