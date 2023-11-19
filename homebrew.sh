#!/usr/bin/env bash

if [ "$SKIP_HOMEBREW" == "true" ]; then
  msg "Skipping Homebrew config"
  divider
  return
fi

# imports
source "$MACAROO_HOME/helper.sh"

# functions
process_brew_file() {
  local filename="$1"

  while IFS= read -r line; do
    process_line "$line"
  done < "$filename"
}

process_line() {
  local line="$1"

  if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
    return
  elif [[ "$line" =~ tap\ \'([^\']+)\' ]]; then
    tap "${BASH_REMATCH[1]}"
  elif [[ "$line" =~ brew\ \'([^\']+)\' ]]; then
    install "${BASH_REMATCH[1]}"
  elif [[ "$line" =~ cask\ \'([^\']+)\' ]]; then
    cask "${BASH_REMATCH[1]}"
  else
    error "Unrecognized line: $line"
  fi
}

tap() {
  brew tap "$1"
}

install() {
  local tool=$1
  toolname "$tool"
  brew list "$tool" || brew install "$tool"
  markdone
}

cask() {
  local tool=$1
  toolname "$tool"
  brew list "$tool" || brew install --cask "$tool"
  markdone
}

msg "Configuring homebrew"
toolname "homebrew"
if test ! "$(which brew)"; then
  brew_install_script="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL $brew_install_script)"
else
  brew update
  brew upgrade
fi
markdone

process_brew_file "$MACAROO_HOME/brewfile"

msg "Cleaning up..."
brew cleanup
msg "Done."
divider
