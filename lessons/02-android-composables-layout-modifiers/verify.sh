#!/usr/bin/env bash
exec "$(cd "$(dirname "$0")" && pwd)/../../scripts/verify-lesson.sh" "$(dirname "$0")" "$@"
