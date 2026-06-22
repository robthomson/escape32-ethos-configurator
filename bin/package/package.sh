#!/usr/bin/env sh
set -eu

VERSION="${1:-0.1.0}"
OUT_DIR="${2:-dist}"

python3 bin/package/build_package.py \
  --artifact-version "$VERSION" \
  --output-dir "$OUT_DIR"

