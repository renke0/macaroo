#!/usr/bin/env bash

read_user_configuration() {
  local git_profiles=("$@")
  if [ "$SKIP_USER_CONFIGURATION" == "true" ]; then
    msg "Skipping user config"
    return
  fi
  msg "Reading user configuration"
  if [ -f "$MACAROO_HOME/.userconfig.json" ]; then
    USER_CONFIGURATION_JSON=$(< "$MACAROO_HOME/.userconfig.json")
  else
    yarn install
    store_password=$(xxd -l16 -ps /dev/urandom)
    ts-node "$MACAROO_TS" "config" "$store_password" "$MACAROO_TEMP/config" "${git_profiles[@]}" > /dev/tty 2>&1
    USER_CONFIGURATION_JSON=$(ts-node "$MACAROO_TS" "decrypt" "$store_password" "$MACAROO_TEMP/config")
    rm -f "$MACAROO_TEMP/config"
  fi
  export USER_CONFIGURATION_JSON
}
