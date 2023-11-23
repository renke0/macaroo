init_flags() {
  SKIP_HOMEBREW="$(_should_skip "$@" homebrew)"
  SKIP_NODE="$(_should_skip "$@" node)"
  SKIP_USER_CONFIGURATION="$(_should_skip "$@" userconfig)"
  SKIP_SDKMAN="$(_should_skip "$@" sdkman)"
  SKIP_DOCKER="$(_should_skip "$@" docker)"
  SKIP_PREZTO="$(_should_skip "$@" prezto)"
  SKIP_GIT="$(_should_skip "$@" git)"
  SKIP_DOTFILES="$(_should_skip "$@" dotfiles)"
  SKIP_MACOS="$(_should_skip "$@" macos)"

  export SKIP_HOMEBREW
  export SKIP_NODE
  export SKIP_USER_CONFIGURATION
  export SKIP_SDKMAN
  export SKIP_DOCKER
  export SKIP_PREZTO
  export SKIP_GIT
  export SKIP_DOTFILES
  export SKIP_MACOS
}

_should_skip() {
  local flags=("${@:1:$#-1}")
  local configuration="${!#}"

  if [ "${#flags[@]}" -eq 0 ]; then
    echo "false"
  elif _array_contains "${flags[@]}" "$configuration"; then
    echo "false"
  else
    echo "true"
  fi
}

_array_contains() {
  local array=("${@:1:$#-1}")
  local element="${!#}"

  for item in "${array[@]}"; do
    if [[ "$item" == "$element" ]]; then
      return 0
    fi
  done
  return 1
}
