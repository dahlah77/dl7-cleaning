#!/bin/zsh
# Generate the Xcode projects for the Apple device companions.
set -euo pipefail
project_root="${0:A:h:h}"

if ! xcodebuild -version >/dev/null 2>&1; then
  print -u2 'Full Xcode is required.'
  exit 2
fi
if ! command -v xcodegen >/dev/null 2>&1; then
  print -u2 'XcodeGen is missing. Install it with: brew install xcodegen'
  exit 2
fi

cd "$project_root/Companions"
xcodegen generate
open DL7CleaningCompanions.xcodeproj
print 'Choose a scheme, device, and signing team in Xcode, then press Run (▶).'
