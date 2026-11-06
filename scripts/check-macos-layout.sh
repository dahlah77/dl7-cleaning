#!/bin/zsh
# Source-level guard for the macOS split-view regression.
set -euo pipefail

source_file="${0:A:h:h}/MacBranding/RootView.swift"

if /usr/bin/grep -Fq 'NavigationSplitView(' "$source_file"; then
  print -u2 'UI regression: NavigationSplitView can overlay the sidebar over Uninstaller.'
  exit 1
fi

for required in \
  'HStack(spacing: 0)' \
  '.frame(width: 248)' \
  'ToolbarItem(placement: .navigation)' \
  'GeometryReader { geometry in' \
  '.frame(width: geometry.size.width, height: geometry.size.height)'; do
  if ! /usr/bin/grep -Fq "$required" "$source_file"; then
    print -u2 "Missing required layout guard: $required"
    exit 1
  fi
done

print 'macOS layout source checks passed.'
