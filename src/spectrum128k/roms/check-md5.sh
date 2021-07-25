#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


set -eu
set -o pipefail
export SHELLOPTS

file="${1}"
expected_md5="${2}"
failure_code="${3}"

actual_md5="$(md5sum "${file}" | sed 's/ .*//')"

if [ "${actual_md5}" != "${expected_md5}" ]; then
  echo "File ${file} has MD5 ${actual_md5} but should have MD5 ${expected_md5}" >&2
  exit "${failure_code}"
fi
