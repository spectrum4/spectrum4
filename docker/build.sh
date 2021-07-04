#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


set -eu

cd "$(dirname "${0}")"
TAG="$(cat TAG)"
docker login

if [ ! -d build ]; then
  # Build a statically linked curl executable, since the regular build has a ton
  # of library dependencies
  rm -rf build
  mkdir build
  cd build
  curl -L 'https://raw.githubusercontent.com/petemoore/curl-static/specify-tls-backend/build.sh' > build.sh
  bash build.sh
  cd ..
fi

# Build the docker file, containing bash, the cross compile tools, and curl
docker build --no-cache "-t=${TAG}" .

docker push "${TAG}"
