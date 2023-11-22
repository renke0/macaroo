#!/usr/bin/env bash
install_sdkman() {
  if [ "$SKIP_SDKMAN" == "true" ]; then
    msg "Skipping SDKMAN! config"
    return
  fi
  source "$MACAROO_HOME/dotfiles/functions"
  source "$MACAROO_SCRIPTS/commons.sh"
  _install_sdkman
  _install_package java
  _install_package groovy
  _install_package gradle
  msg "Done."
}

_install_sdkman() {
  msg "Configuring SDKMAN!"
  toolname "sdkman!"
  if [ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    curl -s "https://get.sdkman.io" | bash
  fi
  # Load SDKMAN!
  source "$HOME/.sdkman/bin/sdkman-init.sh"

  # Symlink custom config for SDKMAN!
  backup "$HOME/.sdkman/etc/config"
  symlink "$MACAROO_RESOURCES/sdkman.properties" "$HOME/.sdkman/etc/config"
  markdone
}

_install_package() {
  local tool="$1"

  toolname "$tool"
  if sdk current "$tool" 2>&1 | grep -q "Not using any version of $tool"; then
    sdk install "$tool"
  fi
  markdone
}
