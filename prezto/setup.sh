#!/usr/bin/env bash

source "$HOME/.mac-config/functions.sh"

preztodir="${ZDOTDIR:-$HOME}/.zprezto"

# Checkout Prezto from their github repo
git clone --recursive https://github.com/sorin-ionescu/prezto.git "$preztodir"

# Replace zpreztorc and zshrc inside prezto's repo with symlinks to our versions
for file in "zpreztorc" "zshrc"; do
  backup "$preztodir/runcoms/$file"
  symlink "../dotfiles/$file" "$preztodir/runcoms/$file"
done

# Create symlinks for the remaining prezto configurations
for file in "zlogin" "zlogout" "zprofile" "zshenv"; do
  symlink "$preztodir/runcoms/$file" "${ZDOTDIR:-$HOME}/.$file"
done
