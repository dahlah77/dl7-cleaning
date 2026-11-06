#!/bin/zsh
# Smoke tests: no source checkout, Xcode, or system changes required.
emulate -L zsh
set -euo pipefail

script_root="${0:A:h}"
installer="$script_root/install.sh"

/bin/zsh -n "$installer"

for target in macos iphone ipad both watchos tvos visionos all; do
  output="$(/bin/zsh "$installer" --platform "$target" --dry-run)"
  [[ "$output" == *'DRY RUN'* ]] || { print -u2 "FAIL: $target"; exit 1; }
  if [[ "$target" == "both" ]]; then
    [[ "$output" == *'macos, iphone'* ]] || { print -u2 'FAIL: both target mapping'; exit 1; }
  fi
done

if /bin/zsh "$installer" --platform invalid --dry-run >/dev/null 2>&1; then
  print -u2 'FAIL: invalid platform accepted'
  exit 1
fi

print -r -- 'PASS: installer syntax, all menu targets, dry-run, and invalid input.'
