# Create setup backup of setup file by moving it and appending ".backup" to its name
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "$target was backed up to $target.backup"
    fi
  fi
}

# Create setup symlink of setup file
symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    echo "Creating link of $file to $link"
    ln -s "$file" "$link"
  fi
}
