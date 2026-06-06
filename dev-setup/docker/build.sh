#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")/.."
TAG="$(cat docker/TAG)"

# Builds and pushes the multiarch docker image for the tag in docker/TAG to
# hub.docker.com. Requires that `docker login` has run first.
#
# This script is for local/manual builds. CI builds the images by a different
# mechanism (.github/workflows/ci.yml: a native per-arch build merged into a
# manifest), triggered by bumping docker/TAG and pushing to the main branch.
#
# To regenerate an existing tag, delete it from hub.docker.com first.
docker pull "${TAG}" > /dev/null 2>&1 || docker buildx build --push --platform linux/arm64,linux/amd64 "-t=${TAG}" -f docker/Dockerfile .
