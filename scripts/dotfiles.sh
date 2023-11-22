#!/usr/bin/env bash

source "$MACAROO_HOME/dotfiles/functions"
source "$MACAROO_SCRIPTS/commons.sh"

# Iterate over the files in dotfiles and create links to them in the home directory
configure_dotfiles() {
  if [ "$SKIP_DOTFILES" == "true" ]; then
    msg "Skipping dotfiles config"
    return
  fi
  msg "Creating dotfiles"
  for target in "$MACAROO_HOME"/dotfiles/*; do
    local filename
    filename="$(basename "$target")"
    toolname "$filename"
    local link="$HOME/.$filename"
    if [ -d "$link" ]; then
      markerror "Is a directory"
    elif [ -L "$link" ] && [ "$target" = "$(readlink -f "$link")" ]; then
      markdone
    else
      backup "$link"
      symlink "$target" "$link"
      markdone
    fi
  done
  msg "Done."
}
