#!/bin/sh
# Derives a semver bump from a Conventional Commit message and applies it to
# pubspec.yaml. Prints the new version on stdout when it changes something.
# Usage: bump_version.sh <message-file>
set -e

MSG_FILE="$1"
PUBSPEC="$(git rev-parse --show-toplevel)/pubspec.yaml"

[ "${NO_VERSION_BUMP:-}" = "1" ] && exit 0
[ -f "$MSG_FILE" ] || exit 0
[ -f "$PUBSPEC" ] || exit 0

HEADER=$(grep -v '^#' "$MSG_FILE" | grep -v '^[[:space:]]*$' | head -1)
case "$HEADER" in
  fixup!*|squash!*|Revert*|revert*|Merge*) exit 0 ;;
esac

TYPE=$(printf '%s' "$HEADER" | sed -n 's/^\([a-zA-Z]\{1,\}\)\(([^)]*)\)\{0,1\}!\{0,1\}:.*/\1/p')
[ -n "$TYPE" ] || exit 0

BREAKING=0
printf '%s' "$HEADER" | grep -q '^[a-zA-Z]\{1,\}\(([^)]*)\)\{0,1\}!:' && BREAKING=1
grep -q '^BREAKING[ -]CHANGE:' "$MSG_FILE" && BREAKING=1

if [ "$BREAKING" = "1" ]; then
  BUMP=major
else
  case "$TYPE" in
    feat|feature) BUMP=minor ;;
    fix|perf)     BUMP=patch ;;
    *)            exit 0 ;;
  esac
fi

RAW=$(awk '/^version:[[:space:]]/{print $2; exit}' "$PUBSPEC")
CORE=${RAW%%+*}
case "$RAW" in *+*) BUILD="+${RAW#*+}" ;; *) BUILD="" ;; esac

MAJOR=$(printf '%s' "$CORE" | cut -d. -f1)
MINOR=$(printf '%s' "$CORE" | cut -d. -f2)
PATCH=$(printf '%s' "$CORE" | cut -d. -f3)

case "$MAJOR.$MINOR.$PATCH" in
  *[!0-9.]*|*..*|.*|*.) echo "version-bump: cannot parse '$RAW', skipping." >&2; exit 0 ;;
esac

# Pre-1.0: a breaking change moves the minor, not the major.
[ "$BUMP" = major ] && [ "$MAJOR" -eq 0 ] && BUMP=minor

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW="$MAJOR.$MINOR.$PATCH$BUILD"

sed "s|^version:[[:space:]].*|version: $NEW|" "$PUBSPEC" > "$PUBSPEC.tmp"
mv "$PUBSPEC.tmp" "$PUBSPEC"
git add -- "$PUBSPEC"

echo "version-bump: $RAW -> $NEW ($BUMP, from '$TYPE')"
