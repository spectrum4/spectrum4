#!/usr/bin/env bash
cd "$(dirname "${0}")"
TAG="$(cat docker/TAG)"
docker image inspect "${TAG}" >/dev/null 2>&1 || docker pull "${TAG}"
docker run --rm -v "$(pwd):/spectrum4" "${TAG}" /spectrum4/all.sh
