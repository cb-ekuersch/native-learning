#!/usr/bin/env bash
# Builds the starter, then the starter with Solutions/ overlaid (same relative paths), in a temp copy.
# Usage: verify-lesson.sh <lesson-dir> [--starter-only]
set -euo pipefail; source "$(dirname "$0")/_lib.sh"
load_lesson "${1:-.}"
build() { # $1 = dir
  if [ "$PLATFORM" = ios ]; then
    (cd "$1" && xcodegen generate --quiet && xcodebuild -project "$APP.xcodeproj" -scheme "$APP" \
      -destination "generic/platform=iOS Simulator" -derivedDataPath .build build -quiet 2>&1 | grep -v IDERunDestination; exit "${PIPESTATUS[0]}")
  else
    (cd "$1" && ./gradlew -q :app:assembleDebug)
  fi
}
[ "$PLATFORM" = ios ] && use_xcode || android_env
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
rsync_lesson "$LESSON_DIR" "$T/starter"
echo "▸ building starter..."; build "$T/starter" && echo "✓ starter builds"
[ "${2:-}" = --starter-only ] && exit 0
if [ -z "$(find "$LESSON_DIR/Solutions" -type f ! -name 'README*' 2>/dev/null)" ]; then echo "• no solution files to verify"; exit 0; fi
rsync_lesson "$LESSON_DIR" "$T/solution"
rsync -a --exclude 'README*' "$LESSON_DIR/Solutions/" "$T/solution/"
echo "▸ building solution overlay..."; build "$T/solution" && echo "✓ solution builds"
