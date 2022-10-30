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
rm -rf dist
lint.sh
tup -k
cp -Lr src/spectrum4/dist .
# docker run --privileged=true -e "release_version=${release_version}" --rm -v "$(pwd)/dist:/dist" -w /dist -ti ubuntu /bin/bash -c '
docker run --privileged=true -e "release_version=${release_version}" --rm -v "$(pwd)/dist:/dist" -w /dist -ti "${TAG}" /bin/bash -c '
apt-get update -y
apt-get install -y dosfstools
for build in debug release; do
  file="spectrum4-${release_version}-${build}.img"
  dd if=/dev/zero of="${file}" bs=1M count=512
  /usr/sbin/mkfs.vfat -n "SPECTRUM 4" "${file}"
  mkdir "/sp4-${build}"
  mount -o loop "${file}" "/sp4-${build}"
  cp "${build}"/* "/sp4-${build}"
  umount "/sp4-${build}"
  rm -r "/sp4-${build}"
  tar -cJf "${file}.xz" "${file}"
  rm "${file}"
done'
for file in "spectrum4-${release_version}"-{debug,release}.img.xz; do
  mv "dist/${file}" .
done
rm -rf dist
