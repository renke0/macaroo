#!/usr/bin/env bash
install_node() {
  if [ "$SKIP_NODE" == "true" ]; then
    msg "Skipping node config"
  else
    source "$MACAROO_SCRIPTS/commons.sh"

    msg "Configuring node"
    _install_nvm
    _install_nodejs
    _install_yarn
    _install_typescript
    _install_tsnode
    msg "Done."
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

_install_yarn() {
  toolname "yarn"
  npm install --global yarn
  markdone
}

_install_typescript() {
  toolname "typescript"
  npm install --global typescript
  markdone
}

_install_tsnode() {
  toolname "ts-node"
  npm install --global ts-node
  markdone
}
