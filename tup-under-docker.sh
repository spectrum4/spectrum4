#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

#####################################################################################

# This script runs tup under docker to build and test everything.
# To see how the docker image was created, see the dev-setup/docker subdirectory.

cd "$(dirname "${0}")"
TAG="$(cat dev-setup/docker/TAG)"
# use --init to capture signals correctly (e.g. Ctrl-C)
# see https://ddanilov.me/how-signals-are-handled-in-a-docker-container
docker run --init -t --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined --rm -v "$(pwd):/spectrum4" -w /spectrum4 "${TAG}" tup "${@}"
