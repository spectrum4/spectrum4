#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

################################################################################
# Run this script, passing in a release number, e.g. ./release.sh 0.0.1
# This script will not tag the code, but it will create the files
# spectrum4-${release_version}-debug.img and spectrum4-${release_version}-release.img.
################################################################################

set -eu
set -o pipefail
export SHELLOPTS

if [ "${#}" -ne 1 ]; then
  echo "$(basename "${0}"): specify a version number to release, e.g." >&2
  echo "  $ '${0}' 0.0.1" >&2
  exit 64
fi

release_version="${1}"

cd "$(dirname "${0}")"
TAG="$(cat dev-setup/docker/TAG)"
tup -k

find src/spectrum4/dist -maxdepth 1 -mindepth 1 -type d | sed 's/.*\///' | while read build; do
  zipfile="spectrum4-${release_version}-${build}.zip"
  (
    cd "src/spectrum4/dist/${build}"
    zip -9 -r "../../../../${zipfile}" .
  )
done
