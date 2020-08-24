#!/usr/bin/env bash
set -eu

cd "$(dirname "${0}")"
TAG="$(cat TAG)"
docker login

# Build a statically linked curl executable, since the regular build has a ton
# of library dependencies
rm -rf build
mkdir build
cd build
curl -L 'https://raw.githubusercontent.com/dtschan/curl-static/ab8ccc3ff140af860065c04b1e9bcd20bbe2c2d2/build.sh' > build.sh
bash build.sh
cd ..

# Build the docker file, containing bash, the cross compile tools, and curl
docker build --no-cache "-t=${TAG}" .

# Remove the curl build files
rm -rf build

docker push "${TAG}"
