#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

# Standalone linting script for developer use outside the tup build system.
# Builds the linter from source (requires Go) and runs it against source files.
#
# Usage:
#   ./lint.sh          Lint only files with uncommitted changes (git status).
#   ./lint.sh --all    Lint all tracked files in the repo.
#
# The linter auto-fixes files in place. Any files it cannot fix are reported as
# errors. Run this to fix lint failures reported by tup.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

echo "Building linter..."
linter="$(mktemp)"
trap 'rm -f "$linter"' EXIT
(cd utils/linter && go build -trimpath -buildvcs=false -ldflags="-buildid=" -mod=readonly -o "$linter" .)

if [ "${1:-}" = "--all" ]; then
  file_list="$(git ls-files)"
else
  file_list="$(git status --porcelain | sed 's/.* //')"
fi

echo "Linting..."
lint_failed=0

echo "$file_list" | while read -r file; do
  [ -z "$file" ] && continue
  [ ! -f "$file" ] && continue
  if ! "$linter" fix "$file"; then
    lint_failed=1
  fi
done

if [ "$lint_failed" -ne 0 ]; then
  echo "Lint errors found (see above)"
  exit 1
fi

echo "Done."
