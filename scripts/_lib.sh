# Shared helpers. Source me.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
LESSONS_DIR="$ROOT/lessons"
# Ignored registry of simulators/emulators this workspace booted (so they can be shut down later).
# One tab-separated row per device: platform, id (UDID / adb serial / "simulator-app"), lesson NUM, extra (AVD:PID).
DEVICES_FILE="$ROOT/.state/devices"
die() { echo "error: $*" >&2; exit 1; }
# Load lesson metadata (.lesson: PLATFORM, APP, BUNDLE/PKG, NUM, TITLE).
load_lesson() {
  LESSON_DIR="$(cd "$1" && pwd -P)"; [ -f "$LESSON_DIR/.lesson" ] || die "$LESSON_DIR is not a lesson (no .lesson)"
  # shellcheck disable=SC1091
  source "$LESSON_DIR/.lesson"
}
# Prefer Xcode 27, then any Xcode 16, else xcode-select default. Never changes global xcode-select.
use_xcode() {
  if [ -z "${DEVELOPER_DIR:-}" ]; then
    for x in /Applications/Xcode-27.app /Applications/Xcode-16*.app; do
      [ -d "$x" ] && export DEVELOPER_DIR="$x/Contents/Developer" && break
    done
  fi
  echo "Xcode: $(xcodebuild -version | head -1) (${DEVELOPER_DIR:-$(xcode-select -p)})"
}
android_env() {
  export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
  if [ -z "${JAVA_HOME:-}" ] && [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  fi
}
rsync_lesson() { rsync -a --exclude .build --exclude build --exclude .gradle --exclude '*.xcodeproj' --exclude .kotlin "$1/" "$2/"; }
record_device() { # platform id lesson [extra]
  mkdir -p "$(dirname "$DEVICES_FILE")"; touch "$DEVICES_FILE"
  awk -F'\t' -v p="$1" -v id="$2" '$1==p && $2==id {f=1} END {exit !f}' "$DEVICES_FILE" ||
    printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "${4:-}" >> "$DEVICES_FILE"
}
