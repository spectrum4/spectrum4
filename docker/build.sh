#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu

cd "$(dirname "${0}")"
TAG="$(cat TAG)"
docker login

# Build the docker file, containing bash, the cross compile tools, and curl
# docker build --no-cache "-t=${TAG}" .
docker build "-t=${TAG}" .

docker push "${TAG}"
