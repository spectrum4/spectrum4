#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


#####################################################################################

# This script builds everything under docker.
# To see how the docker image was created, see the docker subdirectory.

cd "$(dirname "${0}")"
TAG="$(cat docker/TAG)"
docker run --rm -e SPECTRUM4_SCRIPT="${0##*/}" -v "$(pwd):/spectrum4" "${TAG}" /spectrum4/all.sh "${@}"
