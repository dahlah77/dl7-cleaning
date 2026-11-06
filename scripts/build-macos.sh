#!/bin/zsh
# Build an independent DL7 app from the pinned MIT-licensed Havus source.
# Does not install, delete, or overwrite any existing application.
set -euo pipefail

project_root="${0:A:h:h}"
upstream_commit='df0478671adce53d0a0b24597b0ccfa620311d55'
build_root="$(mktemp -d "${TMPDIR:-/tmp}/dl7-macos.XXXXXX")"
checkout="$build_root/Havus"
output="$project_root/dist/DL7 CLEANING v0.4.2.app"

if [[ -e "$output" ]]; then
  print -u2 "Output already exists: $output"
  print -u2 'Move the previous output elsewhere before building again.'
  exit 2
fi
if ! xcodebuild -version >/dev/null 2>&1; then
  print -u2 'Full Xcode is required. Install Xcode and select it in Xcode Settings.'
  exit 2
fi
/bin/zsh "$project_root/scripts/check-macos-layout.sh"
for command_name in git swift sips codesign; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    print -u2 "Missing required tool: $command_name"
    exit 2
  fi
done

print 'Downloading the open-source engine…'
git clone --quiet https://github.com/XNyetok/Havus.git "$checkout"
git -C "$checkout" checkout --quiet --detach "$upstream_commit"

print 'Applying DL7 identity and interface…'
/bin/zsh "$project_root/MacBranding/apply_to_upstream_clone.sh" "$checkout"

print 'Building DL7 CLEANING for macOS…'
xcodebuild \
  -project "$checkout/Havus.xcodeproj" \
  -scheme Havus \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$build_root/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  build

built_app="$build_root/DerivedData/Build/Products/Release/DL7 CLEANING.app"
if [[ ! -d "$built_app" ]]; then
  print -u2 'The build finished without the expected app bundle.'
  exit 3
fi

codesign --force --deep --sign - --timestamp=none "$built_app"
codesign --verify --deep --strict "$built_app"
mkdir -p "$project_root/dist"
ditto "$built_app" "$output"

print ''
print "Build successful: $output"
print 'Open dist in Finder and copy the app to Applications.'
print 'Previous installed applications were not changed.'
