#!/bin/zsh
set -euo pipefail

if (( $# != 1 )); then
  print -u2 'Usage: apply_to_upstream_clone.sh /absolute/path/to/Havus-clone'
  exit 2
fi

repo="$1"
source_dir="${0:A:h}"
if [[ ! -d "$repo/Havus" || ! -f "$repo/LICENSE" ]]; then
  print -u2 'Not a Havus source checkout; no files changed.'
  exit 2
fi

# These paths are inside this newly created fork only, never the installed Havus app.
cp "$source_dir/RootView.swift" "$repo/Havus/Navigation/RootView.swift"
cp "$source_dir/../Companions/Shared/DL7Palette.swift" "$repo/Havus/DL7Palette.swift"
cp "$source_dir/DL7App.swift" "$repo/Havus/HavusApp.swift"
cp "$source_dir/DL7.xcconfig" "$repo/Config/Havus.xcconfig"

# Rebrand only the standalone name token, preserving HavusCore source identifiers.
find "$repo/Havus" -type f \( -name '*.swift' -o -name '*.xcstrings' \) -print0 |
  xargs -0 perl -pi -e 's/\bHavus\b/DL7 CLEANING/g'

# The fork never calls upstream's update service: remove those prompts and commands.
perl -pi -e 's/^\s*UpdateBanner\(\)\s*\n//; s/^\s*AutomaticCheckPrompt\(\)\s*\n//' \
  "$repo/Havus/Features/Overview/OverviewView.swift"

iconset="$repo/Havus/Assets.xcassets/AppIcon.appiconset"
icon_master="$repo/design/DL7-Icon-1024.png"
swift "$source_dir/GenerateIcon.swift" "$icon_master"
for pixel_size in 16 32 64 128 256 512 1024; do
  for image_file in "$iconset"/*.png; do
    filename="${image_file:t}"
    case "$filename" in
      icon_16x16.png) desired=16 ;;
      icon_16x16@2x.png|icon_32x32.png) desired=32 ;;
      icon_32x32@2x.png) desired=64 ;;
      icon_128x128.png) desired=128 ;;
      icon_128x128@2x.png|icon_256x256.png) desired=256 ;;
      icon_256x256@2x.png|icon_512x512.png) desired=512 ;;
      icon_512x512@2x.png) desired=1024 ;;
      *) continue ;;
    esac
    if (( desired == pixel_size )); then
      sips -s format png -z "$pixel_size" "$pixel_size" "$icon_master" --out "$image_file" >/dev/null
    fi
  done
done

print 'DL7 Mac fork branding applied. Original LICENSE and attribution preserved.'
