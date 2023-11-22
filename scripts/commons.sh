source "$MACAROO_HOME/dotfiles/ansi"

splashscreen() {
  println " ooo. .oo.  .oo.   .oooo.    .ooooo.   .oooo.   oooo d8b  .ooooo.   .ooooo." "$FG_RED"
  println "\`888P\"Y88bP\"Y88b  \`P  )88b  d88' \`\"Y8 \`P  )88b  \`888\"\"8P d88' \`88b d88' \`88b" "$FG_RED"
  println " 888   888   888   .oP\"888  888        .oP\"888   888     888   888 888   888" "$FG_RED"
  println " 888   888   888  d8(  888  888   .o8 d8(  888   888     888   888 888   888" "$FG_RED"
  println "o888o o888o o888o \`Y888\"\"8o \`Y8bod8P' \`Y888\"\"8o d888b    \`Y8bod8P' \`Y8bod8P'" "$FG_RED"
  println "$(alignright "Version 1.0" 77)" "$FG_CYAN"
}

msg() {
  println "$(alignleft " $1" 30)" "$BG_CYAN"
}

error() {
  println "$1" "$FG_RED"
}

toolname() {
  print "$(alignleft " $1" 26)" "$FG_BLACK" "$BG_YELLOW"
}

markdone() {
  println " ✔️ " "$BG_GREEN"
}

markerror() {
  println " ✖️ $1 " "$BG_RED"
}

pause() {
  read -rp "Press enter to continue..." > /dev/tty
}
