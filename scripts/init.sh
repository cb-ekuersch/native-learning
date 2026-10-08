#!/usr/bin/env bash
# Initialize private learner state. Safe to rerun; never replaces an existing log.
set -euo pipefail
source "$(dirname "$0")/_lib.sh"
[ $# -eq 0 ] || die "usage: init.sh"
command -v python3 >/dev/null || die "Python 3 is required; install it, then rerun scripts/init.sh"
python3 - "$ROOT" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
log = root / "LESSONS.md"
if log.is_symlink():
    sys.exit("error: LESSONS.md is a symlink; refusing to initialize learner state")
try:
    template = (root / "templates/LESSONS.template.md").read_text()
    with log.open("x") as f:
        f.write(template)
except FileExistsError:
    if not log.is_file():
        sys.exit("error: LESSONS.md exists but is not a regular file")
    print("Kept existing LESSONS.md unchanged.")
else:
    print("Created private LESSONS.md with no assigned or completed lessons.")
PY
printf '%s\n' \
  'Next: see README.md for platform prerequisites, then run scripts/doctor.sh.' \
  'Ask your coding agent to start your first native lesson, or use scripts/log-lesson.sh start <lesson-dir>.' \
  'LESSONS.md is Git-ignored; back it up privately. Shared lesson files do not imply completion.'
