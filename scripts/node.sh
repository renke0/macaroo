#!/usr/bin/env bash
install_node() {
  if [ "$SKIP_NODE" == "true" ]; then
    msg "Skipping node config"
  else
    source "$MACAROO_SCRIPTS/commons.sh"

    msg "Configuring node"
    _install_nvm
    _install_nodejs

    tools=("yarn" "typescript" "ts-node" "@redocly/cli")
    for tool in "${tools[@]}"
    do
      _npm_install "$tool"
    done
  fi
}

_install_nvm() {
  toolname "nvm"
  if ! command -v nvm; then
    brew install nvm
    mkdir "$HOME/.nvm"
    source "/opt/homebrew/opt/nvm/nvm.sh"
  fi
  markdone
}

_install_nodejs() {
  toolname "node"
  nvm install --lts
  nvm use --lts
  markdone
}

_npm_install() {
  toolname "$1"
  npm install --global "$1"
  markdone
}
