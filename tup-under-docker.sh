#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


#####################################################################################

# This script builds everything under docker.
# To see how the docker image was created, see the docker subdirectory.

cd "$(dirname "${0}")"
TAG="$(cat docker/TAG)"
docker run -t --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined --rm -v "$(pwd):/spectrum4" -w /spectrum4 "${TAG}" tup "${@}"
