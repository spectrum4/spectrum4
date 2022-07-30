#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"
TAG="$(cat TAG)"

# Build and push the multiarch docker images to docker.hub.com. Note, this
# requires that `docker login` has run. It is intended that this script is
# called by github actions, rather than being run manually by a person.
#
# In order to trigger the CI to push new docker images to hub.docker.com, bump
# the version number in file TAG in this directory. If the tag does not exist
# on hub.docker.com, multiarch images will be built and pushed on the next push
# to main branch of github repo.
#
# To regenerate an existing tag on docker.hub.com, first delete the tag from
# docker.hub.com, and the next push to main branch of github repo should cause
# github actions CI to recreate it.
docker pull "${TAG}" > /dev/null 2>&1 || docker buildx build --push --platform linux/arm64,linux/amd64 "-t=${TAG}" .
