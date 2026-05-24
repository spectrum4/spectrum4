#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

################################################################################
# This is a quick way to build, if you don't want to run all the tests...
# Note, you should have run tup (or ./tup-under-docker.sh) at least once before
# calling this, so that needed directories and symbolic links already exist.
################################################################################

set -eu
set -o pipefail
export SHELLOPTS

: ${AARCH64_TOOLCHAIN_PREFIX:=aarch64-none-elf-}

cd "$(dirname "${0}")"

for target in debug tests release; do
  ./tup-under-docker.sh "src/spectrum4/targets/${target}.img"
  ./tup-under-docker.sh "src/spectrum4/targets/${target}.disassembly"
  ./tup-under-docker.sh "src/spectrum4/targets/${target}.symbols"
done
