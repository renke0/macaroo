#!/usr/bin/env bash
if [ "$SKIP_NODE" == "true" ]; then
  msg "Skipping node config"
  divider
  return
fi

source "$MACAROO_HOME/helper.sh"

msg "Configuring node"

toolname "node"
nvm install --lts
nvm use --lts
markdone

toolname "yarn"
npm install --global yarn
markdone

msg "Done."
divider
