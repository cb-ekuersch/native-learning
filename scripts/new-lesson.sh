#!/usr/bin/env bash
# Create the next lesson from a template and register it in LESSONS.md.
# Usage: new-lesson.sh <ios|android> <slug> "<Title>" "<concepts, comma separated>" [AppName]
#   e.g. new-lesson.sh android compose-state "State and recomposition" "remember, mutableStateOf, recomposition"
# Prints the new lesson path. Then: fill README.md + Sources, add Solutions/, run ./verify.sh and ./run.sh.
set -euo pipefail; source "$(dirname "$0")/_lib.sh"
[ $# -ge 4 ] || die "usage: new-lesson.sh <ios|android> <slug> \"<Title>\" \"<concepts>\" [AppName]"
PLATFORM="$1"; SLUG="$2"; TITLE="$3"; CONCEPTS="$4"
case "$PLATFORM" in ios|android) ;; *) die "platform must be ios or android";; esac
"$ROOT/scripts/init.sh" >/dev/null
mkdir -p "$LESSONS_DIR"
LAST=$(ls "$LESSONS_DIR" | grep -E '^[0-9]{2}-' | sort | tail -1 | cut -c1-2 || true)
NUM=$(printf "%02d" $((10#${LAST:-0} + 1)))
APP="${5:-$(python3 -c "import sys;print(''.join(p.capitalize() for p in sys.argv[1].split('-')))" "$SLUG")}"
APP="L${NUM}${APP}"
LOWER=$(echo "$APP" | tr '[:upper:]' '[:lower:]')
DIR="$LESSONS_DIR/$NUM-$PLATFORM-$SLUG"; [ -e "$DIR" ] && die "$DIR exists"
DATE=$(date +%F)
cp -R "$ROOT/templates/$PLATFORM" "$DIR"
if [ "$PLATFORM" = ios ]; then
  ID="com.example.lessons.$LOWER"; LABEL="SwiftUI"; DEVICE="iOS Simulator"
  IDE="Or open \`$APP.xcodeproj\` in Xcode (⌘R to run, ⌥⌘↩ for the live Preview canvas). Regenerate it with \`./run.sh\` if you add files."
  printf 'PLATFORM=ios\nAPP=%s\nBUNDLE=%s\nNUM=%s\nTITLE=%q\n' "$APP" "$ID" "$NUM" "$TITLE" > "$DIR/.lesson"
else
  ID="com.example.lessons.$LOWER"; LABEL="Jetpack Compose"; DEVICE="Android emulator"
  IDE="Or open this folder in Android Studio (▶ to run; the Split/Design view shows \`@Preview\`s)."
  PKGDIR="$DIR/app/src/main/java/$(echo "$ID" | tr . /)"; mkdir -p "$(dirname "$PKGDIR")"
  mv "$DIR/app/src/main/java/__PKGPATH__" "$PKGDIR"
  printf 'PLATFORM=android\nAPP=%s\nPKG=%s\nNUM=%s\nTITLE=%q\n' "$APP" "$ID" "$NUM" "$TITLE" > "$DIR/.lesson"
fi
sed -e "s|__NUM__|$NUM|g" -e "s|__TITLE__|$TITLE|g" -e "s|__DATE__|$DATE|g" -e "s|__PLATFORM_LABEL__|$LABEL|g" \
    -e "s|__DEVICE_LABEL__|$DEVICE|g" -e "s|__IDE_HINT__|$IDE|g" "$ROOT/templates/README.template.md" > "$DIR/README.md"
find "$DIR" -type f \( -name '*.swift' -o -name '*.kt' -o -name '*.kts' -o -name '*.yml' -o -name '*.xml' \) -print0 |
  xargs -0 sed -i '' -e "s|__APP__|$APP|g" -e "s|__BUNDLE__|$ID|g" -e "s|__PKG__|$ID|g" -e "s|__NUM__|$NUM|g" -e "s|__TITLE__|$TITLE|g"
mkdir -p "$DIR/Solutions"
printf '#!/usr/bin/env bash\nexec "$(cd "$(dirname "$0")" && pwd)/../../scripts/run-lesson.sh" "$(dirname "$0")" "$@"\n' > "$DIR/run.sh"
printf '#!/usr/bin/env bash\nexec "$(cd "$(dirname "$0")" && pwd)/../../scripts/verify-lesson.sh" "$(dirname "$0")" "$@"\n' > "$DIR/verify.sh"
chmod +x "$DIR/run.sh" "$DIR/verify.sh"
"$ROOT/scripts/log-lesson.sh" add "$NUM" "$DATE" "$LABEL" "$TITLE" "$CONCEPTS" "lessons/$(basename "$DIR")" >/dev/null
echo "$DIR"
