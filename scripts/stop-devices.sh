#!/usr/bin/env bash
# Shut down the simulators/emulators this workspace booted (recorded by run-lesson.sh in .state/devices).
# Devices that were already running when a lesson launched are never shut down; they're only reported.
# Usage: stop-devices.sh [--dry-run] [lesson-dir]
#   lesson-dir  also quits that lesson's app on devices that are left running.
set -euo pipefail; source "$(dirname "$0")/_lib.sh"
DRY=; LESSON=
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    -h|--help) sed -n 2,6p "$0"; exit 0 ;;
    *) [ -z "$LESSON" ] || die "usage: stop-devices.sh [--dry-run] [lesson-dir]"; LESSON="$arg" ;;
  esac
done
run() { if [ -n "$DRY" ]; then echo "  would run: $*"; else "$@"; fi; }
have() { command -v "$1" >/dev/null 2>&1; }
android_env
booted_sims() { have xcrun && xcrun simctl list devices booted 2>/dev/null | grep -Eo '[0-9A-F-]{36}' || true; }
emulators() { have adb && adb devices 2>/dev/null | grep -Eo '^emulator-[0-9]+' || true; }

QUIT_SIM_APP=; STOPPED=0
if [ -s "$DEVICES_FILE" ]; then
  while IFS=$'\t' read -r platform id num extra <&3; do
    [ -n "$platform" ] || continue
    case "$platform:$id" in
      ios:simulator-app) QUIT_SIM_APP=1 ;;
      ios:*)
        if booted_sims | grep -qx "$id"; then
          echo "▸ shutting down iOS simulator $id (booted for lesson $num)"
          run xcrun simctl shutdown "$id" && STOPPED=$((STOPPED + 1))
        fi ;;
      android:*)
        pid="${extra##*:}"
        if emulators | grep -qx "$id"; then
          echo "▸ shutting down Android emulator $id (${extra%%:*}, booted for lesson $num)"
          run adb -s "$id" emu kill >/dev/null || true
          STOPPED=$((STOPPED + 1))
          if [ -z "$DRY" ]; then for _ in $(seq 1 15); do emulators | grep -qx "$id" || break; sleep 1; done; fi
        fi
        # Fallback for a hung emulator: only kill the recorded PID if it is still an emulator process.
        if [ -z "$DRY" ] && [ -n "$pid" ] && ps -p "$pid" -o command= 2>/dev/null | grep -Eq 'emulator|qemu'; then
          kill "$pid" 2>/dev/null || true
        fi ;;
    esac
  done 3< "$DEVICES_FILE"
fi

# Quit Simulator.app only if this workspace opened it and no other simulator is still booted.
if [ -n "$QUIT_SIM_APP" ] && pgrep -xq Simulator; then
  if [ -z "$(booted_sims | grep -vxF "$(cut -f2 "$DEVICES_FILE" 2>/dev/null)" || true)" ]; then
    echo "▸ quitting Simulator.app (opened by this workspace)"
    run osascript -e 'quit app "Simulator"' >/dev/null || true
  else
    echo "• leaving Simulator.app open: other simulators are still booted"
  fi
fi

[ -n "$DRY" ] || rm -f "$DEVICES_FILE"
if [ -n "$DRY" ]; then echo "Would stop $STOPPED workspace-managed device(s)."; else echo "Stopped $STOPPED workspace-managed device(s)."; fi

# Report anything still running (the user's own devices, or ones booted before tracking existed).
LEFT_SIMS=$(booted_sims); LEFT_EMUS=$(emulators)
if [ -n "$LESSON" ]; then
  load_lesson "$LESSON"
  for d in $LEFT_SIMS; do [ -n "${BUNDLE:-}" ] && run xcrun simctl terminate "$d" "$BUNDLE" 2>/dev/null || true; done
  for d in $LEFT_EMUS; do [ -n "${PKG:-}" ] && run adb -s "$d" shell am force-stop "$PKG" 2>/dev/null || true; done
fi
if [ -n "$DRY" ]; then
  echo "(dry run: nothing was changed)"
elif [ -n "$LEFT_SIMS$LEFT_EMUS" ]; then
  echo "Left running (not started by this workspace, or booted before tracking):"
  for d in $LEFT_SIMS; do echo "  ios $d  $(xcrun simctl list devices | grep "$d" | sed -E 's/ *\(.*//; s/^ *//')"; done
  for d in $LEFT_EMUS; do echo "  android $d"; done
fi
