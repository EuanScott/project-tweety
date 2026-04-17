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
DOMAIN_REPOSITORY="$ROOT_DIR/lib/domain/repositories/${FEATURE_NAME}_repository.dart"

if [[ ! -f "$DOMAIN_ENTITY" || ! -f "$DOMAIN_REPOSITORY" ]]; then
  echo "Domain skeleton for $FEATURE_NAME must exist before generating data." >&2
  echo "Expected:" >&2
  echo "  $DOMAIN_ENTITY" >&2
  echo "  $DOMAIN_REPOSITORY" >&2
  exit 1
fi

DATA_SOURCES_ROOT="$ROOT_DIR/lib/data/datasources"
DTOS_ROOT="$ROOT_DIR/lib/data/dtos"
REPOSITORIES_ROOT="$ROOT_DIR/lib/data/repositories"

TARGET_FILES=(
  "$DATA_SOURCES_ROOT/mock_${FEATURE_NAME}_data_source.dart"
  "$DTOS_ROOT/${ENTITY_NAME}_dto.dart"
  "$REPOSITORIES_ROOT/${FEATURE_NAME}_repository_impl.dart"
)

for target_file in "${TARGET_FILES[@]}"; do
  if [[ -e "$target_file" ]]; then
    echo "Refusing to overwrite existing file: $target_file" >&2
    exit 1
  fi
done

mkdir -p \
  "$DATA_SOURCES_ROOT" \
  "$DTOS_ROOT" \
  "$REPOSITORIES_ROOT"

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
  "$TEMPLATE_DIR/data_source.dart.tpl" \
  "$DATA_SOURCES_ROOT/mock_${FEATURE_NAME}_data_source.dart"
render_template \
  "$TEMPLATE_DIR/data_dto.dart.tpl" \
  "$DTOS_ROOT/${ENTITY_NAME}_dto.dart"
render_template \
  "$TEMPLATE_DIR/data_repository_impl.dart.tpl" \
  "$REPOSITORIES_ROOT/${FEATURE_NAME}_repository_impl.dart"
echo "Created data skeleton for feature $FEATURE_NAME using entity $ENTITY_NAME"
echo "Next: dart run build_runner build --delete-conflicting-outputs"
