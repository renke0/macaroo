#!/usr/bin/env bash

install_homebrew() {
  if [ "$SKIP_HOMEBREW" == "true" ]; then
    msg "Skipping Homebrew config"
    return
  fi
  source "$MACAROO_SCRIPTS/commons.sh"
  msg "Configuring homebrew"
  toolname "homebrew"
  if test ! "$(which brew)"; then
    brew_install_script="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL $brew_install_script)"
    echo "PATH=\"/usr/local/bin:$PATH\"" >> "$HOME/.bash_profile"
    source "$HOME/.bash_profile"
  else
    brew update
    brew upgrade
  fi
  markdone
  msg "Done."
}

install_homebrew_packages() {
  if [ "$SKIP_HOMEBREW" == "true" ]; then
    msg "Skipping Homebrew config"
    return
  fi
  msg "Installing homebrew packages"
  source "$MACAROO_SCRIPTS/commons.sh"
  _process_brew_file "$MACAROO_RESOURCES/brewfile"
  msg "Cleaning up..."
  brew cleanup
  msg "Done."
}

# functions
_process_brew_file() {
  local filename="$1"

  while IFS= read -r line; do
    _process_line "$line"
  done < "$filename"
}

_process_line() {
  local line="$1"

  if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
    return
  elif [[ "$line" =~ tap\ \'([^\']+)\' ]]; then
    _tap "${BASH_REMATCH[1]}"
  elif [[ "$line" =~ brew\ \'([^\']+)\' ]]; then
    _brew_install "${BASH_REMATCH[1]}"
  elif [[ "$line" =~ cask\ \'([^\']+)\' ]]; then
    _brew_install_cask "${BASH_REMATCH[1]}"
  else
    error "Unrecognized line: $line"
  fi
}

_tap() {
  brew tap "$1"
}

_brew_install() {
  local package=$1
  toolname "$package"
  brew list "$package" || brew install "$package"
  markdone
}

_brew_install_cask() {
  local package=$1
  toolname "$package"
  brew list "$package" || brew install --cask "$package"
  markdone
}
