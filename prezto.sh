#!/usr/bin/env bash

if [ "$SKIP_PREZTO" == "true" ]; then
  msg "Skipping Prezto config"
  divider
  return
fi

source "$MACAROO_HOME/dotfiles/functions"
source "$MACAROO_HOME/helper.sh"

preztodir="${ZDOTDIR:-$HOME}/.zprezto"

msg "Configuring Prezto"
toolname "prezto"
# Checkout Prezto from their github repo
git clone --recursive https://github.com/sorin-ionescu/prezto.git "$preztodir"

# Replace zpreztorc and zshrc inside prezto's repo with symlinks to our versions
for file in "zpreztorc" "zshrc"; do
  backup "$preztodir/runcoms/$file"
  symlink "$MACAROO_HOME/dotfiles/$file" "$preztodir/runcoms/$file"
done

# Create symlinks for the remaining prezto configurations
for file in "zlogin" "zlogout" "zprofile" "zshenv"; do
  symlink "$preztodir/runcoms/$file" "${ZDOTDIR:-$HOME}/.$file"
done

markdone
msg "Done."
divider
