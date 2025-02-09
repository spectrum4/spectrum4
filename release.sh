#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

################################################################################
# Run this script, after tagging the HEAD commit with a version beginning with
# "v", e.g. `git tag -s v0.0.1 -m "Release information..."`. This script will
# then create the files:
#   * spectrum4-${release_version}-debug.img
#   * spectrum4-${release_version}-release.img
#   * spectrum4-${release_version}-tests.img
################################################################################

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

if [ -z "$(git status --porcelain)" ]; then
  git tag --points-at HEAD | sed -n 's/^v//p' | while read release_version; do
    tup
    find src/spectrum4/dist -maxdepth 1 -mindepth 1 -type d | sed 's/.*\///' | while read build; do
      zipfile="spectrum4-${release_version}-${build}.zip"
      (
        cd "src/spectrum4/dist/${build}"
        zip -9 -r "../../../../${zipfile}" .
      )
    done
  done
fi
