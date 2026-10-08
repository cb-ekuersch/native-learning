#!/usr/bin/env bash
exec "$(cd "$(dirname "$0")" && pwd)/../../scripts/run-lesson.sh" "$(dirname "$0")" "$@"
