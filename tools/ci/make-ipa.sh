#!/bin/bash
# Builds an unsigned IPA. xtool or Sideloadly sign it with the real Apple account when installing.
set -euo pipefail

output_dir="${1:-build/ipa}"
mkdir -p "$output_dir"
archive="$output_dir/NetztechnikLernApp.xcarchive"
xcodebuild archive -project NetztechnikLernApp.xcodeproj -scheme NetztechnikLernApp \
    -configuration Release -destination 'generic/platform=iOS' \
    -archivePath "$archive" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

stage="$(mktemp -d "${TMPDIR:-/tmp}/netztechnik-ipa.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/Payload"
ditto "$archive/Products/Applications/NetztechnikLernApp.app" "$stage/Payload/NetztechnikLernApp.app"
codesign --force --sign - "$stage/Payload/NetztechnikLernApp.app"
codesign --verify --deep --strict "$stage/Payload/NetztechnikLernApp.app"
ditto -c -k --keepParent "$stage/Payload" "$output_dir/NetztechnikLernApp.ipa"
ls -lh "$output_dir/NetztechnikLernApp.ipa"
