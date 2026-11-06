#!/bin/zsh
# Source-level guard for the macOS split-view regression.
set -euo pipefail

source_file="${0:A:h:h}/MacBranding/RootView.swift"

if /usr/bin/grep -Fq '.navigationSplitViewStyle(.prominentDetail)' "$source_file"; then
  print -u2 'UI regression: prominentDetail overlays the sidebar over the app list.'
  exit 1
fi

for required in \
  '.navigationSplitViewStyle(.balanced)' \
  'GeometryReader { geometry in' \
  '.navigationSplitViewColumnWidth(min: 220, ideal: 245, max: 280)' \
  '.frame(width: geometry.size.width, height: geometry.size.height)'; do
  if ! /usr/bin/grep -Fq "$required" "$source_file"; then
    print -u2 "Missing required layout guard: $required"
    exit 1
  fi
done

print 'macOS layout source checks passed.'
