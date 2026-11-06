#!/bin/zsh
# Source checks for the explicit external DEVELOPER navigation on Mac and iOS.
emulate -L zsh
set -euo pipefail

project_root="${0:A:h:h}"
mac_source="$project_root/MacBranding/RootView.swift"
ios_source="$project_root/Companions/Shared/DL7PremiumView.swift"
portfolio_url='https://dahlah7-personal-portfolio1.vercel.app'

for source_file in "$mac_source" "$ios_source"; do
  /usr/bin/grep -Fq "$portfolio_url" "$source_file" || {
    print -u2 "Missing developer URL: $source_file"
    exit 1
  }
  /usr/bin/grep -Fq 'DEVELOPER' "$source_file" || {
    print -u2 "Missing navigation label: $source_file"
    exit 1
  }
done

/usr/bin/grep -Fq 'Link(destination: developerURL)' "$mac_source" || {
  print -u2 'Mac DEVELOPER must be an external link.'
  exit 1
}
/usr/bin/grep -Fq 'openURL(url)' "$ios_source" || {
  print -u2 'iOS DEVELOPER must open the URL externally.'
  exit 1
}
/usr/bin/grep -Fq 'tab = previous == .developer ? .home : previous' "$ios_source" || {
  print -u2 'iOS DEVELOPER must restore the previous tab after opening Safari.'
  exit 1
}

print 'PASS: Mac and iPhone DEVELOPER navigation source checks.'
