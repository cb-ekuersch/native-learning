#!/usr/bin/env bash
# Read-only toolchain check. Does not install tools or boot devices.
set -uo pipefail
source "$(dirname "$0")/_lib.sh"
[ $# -le 1 ] || die "usage: doctor.sh [ios|android|both]"
TRACK="${1:-both}"
case "$TRACK" in ios|android|both) ;; *) die "usage: doctor.sh [ios|android|both]" ;; esac
FAILED=0
missing() { echo "MISSING: $*"; FAILED=1; }
check_command() {
  if command -v "$1" >/dev/null; then
    echo "$1: $(command -v "$1")"
  else
    missing "$*"
  fi
}
[ "$(uname -s)" = Darwin ] || missing "macOS (current build/run scripts require it)"
check_command python3
check_command rsync
if [ "$TRACK" = ios ] || [ "$TRACK" = both ]; then
  echo '--- iOS ---'
  use_xcode
  xcodebuild -version >/dev/null 2>&1 || missing 'full Xcode installation; open Xcode to finish setup, or set DEVELOPER_DIR'
  check_command xcodegen '(brew install xcodegen)'
  RUNTIMES=$(xcrun simctl list runtimes 2>/dev/null | grep 'iOS' | grep -v unavailable || true)
  if [ -n "$RUNTIMES" ]; then echo "$RUNTIMES"; else missing 'iOS simulator runtime (Xcode Settings > Components)'; fi
  DEVICES=$(xcrun simctl list devices available 2>/dev/null | grep 'iPhone' || true)
  if [ -n "$DEVICES" ]; then echo "$DEVICES"; else missing 'iPhone simulator (Xcode > Window > Devices and Simulators)'; fi
fi
if [ "$TRACK" = android ] || [ "$TRACK" = both ]; then
  echo '--- Android ---'
  android_env
  JAVA=java
  [ -z "${JAVA_HOME:-}" ] || JAVA="$JAVA_HOME/bin/java"
  if "$JAVA" -version; then echo "JAVA_HOME=${JAVA_HOME:-unset} (JDK 17+ required)"; else missing 'JDK 17+; install Android Studio or set JAVA_HOME'; fi
  echo "Android SDK: $ANDROID_HOME"
  [ -d "$ANDROID_HOME/platforms/android-37" ] || missing 'Android SDK Platform 37 (Android Studio > SDK Manager)'
  [ -d "$ANDROID_HOME/build-tools" ] || missing 'Android SDK Build-Tools (SDK Manager)'
  check_command adb '(Android SDK Platform-Tools)'
  check_command emulator '(Android Emulator)'
  AVDS=$(emulator -list-avds 2>/dev/null | grep -v '^lune-' || true)
  if [ -n "$AVDS" ]; then echo "AVDs: $AVDS"; else missing 'Android virtual device (Android Studio > Device Manager; create a Pixel)'; fi
fi
if [ "$FAILED" -ne 0 ]; then
  echo 'Resolve the missing prerequisites above, then rerun this check.'
else
  echo 'Tools found. See README.md for required versions; build verification is still needed for each lesson.'
fi
exit "$FAILED"
