#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/../../.." && pwd)
TEMPLATE_DIR="$SCRIPT_DIR/templates"

if [[ $# -ne 2 ]]; then
  echo "Usage: $(basename "$0") feature_name entity_name" >&2
  exit 1
fi

FEATURE_NAME="$1"
ENTITY_NAME="$2"
PACKAGE_NAME=$(awk '/^name:/ { print $2; exit }' "$ROOT_DIR/pubspec.yaml")

if [[ ! "$FEATURE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Feature name must be snake_case: $FEATURE_NAME" >&2
  exit 1
fi

if [[ ! "$ENTITY_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Entity name must be snake_case: $ENTITY_NAME" >&2
  exit 1
fi

if [[ -z "$PACKAGE_NAME" ]]; then
  echo "Could not determine package name from $ROOT_DIR/pubspec.yaml" >&2
  exit 1
fi

to_pascal() {
  echo "$1" | awk -F'_' '{
    for (i = 1; i <= NF; i++) {
      printf "%s%s", toupper(substr($i, 1, 1)), substr($i, 2)
    }
  }'
}

FEATURE_PASCAL=$(to_pascal "$FEATURE_NAME")
ENTITY_PASCAL=$(to_pascal "$ENTITY_NAME")

DOMAIN_ENTITY="$ROOT_DIR/lib/domain/entities/${ENTITY_NAME}.dart"
DOMAIN_USE_CASE="$ROOT_DIR/lib/domain/usecases/get_${FEATURE_NAME}_usecase.dart"

if [[ ! -f "$DOMAIN_ENTITY" || ! -f "$DOMAIN_USE_CASE" ]]; then
  echo "Domain skeleton for $FEATURE_NAME must exist before generating presentation." >&2
  echo "Expected:" >&2
  echo "  $DOMAIN_ENTITY" >&2
  echo "  $DOMAIN_USE_CASE" >&2
  exit 1
fi

PAGE_ROOT="$ROOT_DIR/lib/presentation/pages/$FEATURE_NAME"
BLOC_ROOT="$PAGE_ROOT/bloc"

TARGET_FILES=(
  "$PAGE_ROOT/${FEATURE_NAME}.page.dart"
  "$BLOC_ROOT/${FEATURE_NAME}_bloc.dart"
  "$BLOC_ROOT/${FEATURE_NAME}_event.dart"
  "$BLOC_ROOT/${FEATURE_NAME}_state.dart"
)

for target_file in "${TARGET_FILES[@]}"; do
  if [[ -e "$target_file" ]]; then
    echo "Refusing to overwrite existing file: $target_file" >&2
    exit 1
  fi
done

mkdir -p "$PAGE_ROOT" "$BLOC_ROOT"

render_template() {
  local source_file="$1"
  local target_file="$2"

  sed \
    -e "s/__FEATURE_NAME__/$FEATURE_NAME/g" \
    -e "s/__FEATURE_PASCAL__/$FEATURE_PASCAL/g" \
    -e "s/__ENTITY_NAME__/$ENTITY_NAME/g" \
    -e "s/__ENTITY_PASCAL__/$ENTITY_PASCAL/g" \
    -e "s/__PACKAGE_NAME__/$PACKAGE_NAME/g" \
    "$source_file" > "$target_file"
}

render_template \
  "$TEMPLATE_DIR/presentation_page.dart.tpl" \
  "$PAGE_ROOT/${FEATURE_NAME}.page.dart"
render_template \
  "$TEMPLATE_DIR/presentation_bloc.dart.tpl" \
  "$BLOC_ROOT/${FEATURE_NAME}_bloc.dart"
render_template \
  "$TEMPLATE_DIR/presentation_event.dart.tpl" \
  "$BLOC_ROOT/${FEATURE_NAME}_event.dart"
render_template \
  "$TEMPLATE_DIR/presentation_state.dart.tpl" \
  "$BLOC_ROOT/${FEATURE_NAME}_state.dart"
echo "Created presentation skeleton for feature $FEATURE_NAME using entity $ENTITY_NAME"
echo "Next: dart run build_runner build --delete-conflicting-outputs"
