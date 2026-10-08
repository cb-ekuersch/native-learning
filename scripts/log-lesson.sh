#!/usr/bin/env bash
# Maintain the lessons table in LESSONS.md (the automation's only memory of what has been learned).
#   log-lesson.sh add <NN> <date> <platform> "<title>" "<concepts>" <path>
#   log-lesson.sh status <NN> <assigned|in-progress|completed|skipped> ["note"]
#   log-lesson.sh show
#   log-lesson.sh start <lesson-dir> ["concepts"] — enroll in an existing shared lesson
set -euo pipefail; source "$(dirname "$0")/_lib.sh"
[ $# -gt 0 ] || die "usage: log-lesson.sh <start|add|status|show> ..."
"$ROOT/scripts/init.sh" >/dev/null
if [ "$1" = start ]; then
  [ $# -ge 2 ] && [ $# -le 3 ] || die 'usage: log-lesson.sh start <lesson-dir> ["concepts"]'
  load_lesson "$2"
  [ "$(dirname "$LESSON_DIR")" = "$LESSONS_DIR" ] || die "lesson must be inside $LESSONS_DIR"
  case "$PLATFORM" in
    ios) LABEL=SwiftUI ;;
    android) LABEL='Jetpack Compose' ;;
    *) die "unknown lesson platform: $PLATFORM" ;;
  esac
  set -- add "$NUM" "$(date +%F)" "$LABEL" "$TITLE" "${3:-$TITLE}" "lessons/$(basename "$LESSON_DIR")"
fi
exec python3 - "$ROOT/LESSONS.md" "$@" <<'PY'
import sys, re
path, cmd, *a = sys.argv[1:]
s = open(path).read()
head = "| # | Date | Platform | Goal | Concepts introduced | Path | Status | Notes |"
start = s.index(head); end = s.find("\n\n", start); end = len(s) if end == -1 else end
rows = [r for r in s[start:end].split("\n")[2:] if r.strip()]
cells = lambda r: [c.strip() for c in r.strip().strip("|").split("|")]
fmt = lambda c: "| " + " | ".join(c) + " |"
if cmd == "add":
    num, date, plat, title, concepts, p = a
    if any(cells(r)[0] == num for r in rows):
        sys.exit(f"lesson {num} is already registered; use status to update it")
    rows.append(fmt([num, date, plat, title, concepts, p, "assigned", ""]))
elif cmd == "status":
    num, status, note = a[0], a[1], (a[2] if len(a) > 2 else None)
    if status not in {"assigned", "in-progress", "completed", "skipped"}:
        sys.exit(f"invalid lesson status: {status}")
    out = []
    for r in rows:
        c = cells(r)
        if c[0] == num:
            c[6] = status
            if note: c[7] = note.replace("|", "/")
        out.append(fmt(c))
    if out == [fmt(cells(r)) for r in rows] and not any(cells(r)[0] == num for r in rows): sys.exit(f"lesson {num} not found")
    rows = out
elif cmd == "show":
    print(s[start:end]); sys.exit()
else:
    sys.exit("unknown command")
rows.sort(key=lambda r: cells(r)[0])
s = s[:start] + "\n".join([head, "|---|---|---|---|---|---|---|---|"] + rows) + s[end:]
open(path, "w").write(s)
print(f"LESSONS.md updated ({cmd} {a[0]})")
PY
