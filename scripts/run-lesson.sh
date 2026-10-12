#!/usr/bin/env bash
# Build, install and launch a lesson on a simulator/emulator. Boots one if needed.
# Usage: run-lesson.sh <lesson-dir>      Env: SIM_DEVICE=<udid> (iOS), AVD=<name> (Android)
set -euo pipefail; source "$(dirname "$0")/_lib.sh"
load_lesson "${1:-.}"; cd "$LESSON_DIR"
if [ "$PLATFORM" = ios ]; then
  use_xcode
  xcodegen generate --quiet
  DEVICE="${SIM_DEVICE:-$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1 || true)}"
  # Newest runtime's newest "Pro" iPhone (list is ordered oldest→newest runtime).
  [ -n "$DEVICE" ] || DEVICE=$(xcrun simctl list devices available | grep -E 'iPhone [0-9]+ Pro \(' | tail -1 | grep -Eo '[0-9A-F-]{36}')
  # Only devices/apps this script starts are recorded; anything already running stays the user's.
  if ! xcrun simctl list devices | grep "$DEVICE" | grep -q '(Booted)'; then
    xcrun simctl boot "$DEVICE" && record_device ios "$DEVICE" "$NUM"
  fi
  pgrep -xq Simulator || record_device ios simulator-app "$NUM"
  open -a Simulator --args -CurrentDeviceUDID "$DEVICE"
  xcodebuild -project "$APP.xcodeproj" -scheme "$APP" -destination "id=$DEVICE" -derivedDataPath .build build -quiet 2>&1 | grep -v IDERunDestination || true
  APP_PATH=".build/Build/Products/Debug-iphonesimulator/$APP.app"; [ -d "$APP_PATH" ] || die "build failed"
  xcrun simctl install "$DEVICE" "$APP_PATH"
  xcrun simctl launch --terminate-running-process "$DEVICE" "$BUNDLE" >/dev/null
  echo "Running $APP on simulator $DEVICE"
else
  android_env
  if ! adb devices | grep -qE 'emulator-[0-9]+\s+device'; then
    AVD="${AVD:-$(emulator -list-avds | grep -v '^lune-' | grep -i pixel | head -1)}"; AVD="${AVD:-$(emulator -list-avds | grep -v '^lune-' | head -1)}"
    [ -n "$AVD" ] || die "no AVD found; create one in Android Studio ▸ Device Manager"
    echo "Booting emulator ${AVD}..."
    nohup emulator -avd "$AVD" -no-snapshot-save >/tmp/native-ui-emulator.log 2>&1 &
    EMU_PID=$!
    adb wait-for-device
    until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; do sleep 2; done
    record_device android "$(adb devices | grep -Eo 'emulator-[0-9]+' | head -1)" "$NUM" "$AVD:$EMU_PID"
  fi
  ./gradlew -q :app:installDebug
  adb shell am start -S -n "$PKG/.MainActivity" >/dev/null
  echo "Running $APP on $(adb devices | grep -Eo 'emulator-[0-9]+' | head -1)"
fi
