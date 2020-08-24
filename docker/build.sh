#!/usr/bin/env bash
set -eu

cd "$(dirname "${0}")"
TAG="$(cat TAG)"
docker login
docker build --no-cache "-t=${TAG}" .
docker push "${TAG}"
