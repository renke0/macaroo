pinned_apps=("Google Chrome" "IntelliJ IDEA" "Sublime Text" "iTerm" "Postman" "DevToys" "Notion" "Slack"
  "Spotify" "Pocket Casts" "WhatsApp")

dock_items=()
for app_name in "${pinned_apps[@]}"; do
  dock_items+=("$(printf '%s%s%s%s%s' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict>' \
    '<key>_CFURLString</key><string>' \
    "/Applications/$app_name.app" \
    '</string><key>_CFURLStringType</key><integer>0</integer>' \
    '</dict></dict></dict>')")
done

defaults write com.apple.dock persistent-apps -array "${dock_items[@]}"

killall Dock
