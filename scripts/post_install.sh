link_macaroo_to_repo() {
  git init
  git remote add origin git@github.com:renke0/macaroo.git
  git clean -df
  find . -name '.DS_Store' -type f -delete
  git merge origin/main
  git branch --set-upstream-to=origin/main main

  yarn install
}

use_zsh() {
  if [ "$SHELL" != "/bin/zsh" ]; then
    sudo chsh -s /bin/zsh
  fi
}

create_notunes_login_item() {
  osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/noTunes.app", hidden:true}'
}
