#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

testsuite="${1}"

echo "// This file is part of the Spectrum +4 Project."
echo "// Licencing information can be found in the LICENCE file"
echo "// (C) 2021-$(date +%Y) Spectrum +4 Authors. All rights reserved."
echo
echo
echo ".include \"one-test-suite.s\""
echo ".include \"${testsuite##*/}\""
