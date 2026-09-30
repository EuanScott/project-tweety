#!/bin/sh
# Runs `bloc lint` on the given paths. Infos are reported but only warnings and
# errors fail, because bloc_tools exits non-zero on any issue and has no flag
# equivalent to `flutter analyze --no-fatal-infos`.

if [ "$#" -eq 0 ]; then
  echo "Usage: tool/hooks/bloc_lint.sh <path>..." >&2
  exit 64
fi

# stdin is closed so the update prompt bloc_tools prints never waits for input.
output=$(dart run bloc_tools:bloc lint "$@" </dev/null 2>&1)
status=$?

printf '%s\n' "$output" | sed '/^+-\{10,\}+$/,$d'

if [ "$status" -eq 0 ]; then
  exit 0
fi
if printf '%s\n' "$output" | grep -qE '^(warning|error)\['; then
  exit 1
fi
if printf '%s\n' "$output" | grep -qE '^info\['; then
  exit 0
fi

echo "bloc lint failed without reporting an issue (exit $status)." >&2
exit "$status"
