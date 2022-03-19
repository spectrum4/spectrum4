#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

#############################################################################
# Keep a record of which functions call other functions to ease writing tests
#############################################################################

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

release_elf="${1}"
shift 1
test_elfs="${@}"
ROUTINES_WITHOUT_TESTS=$("${AARCH64_TOOLCHAIN_PREFIX}objdump" -d "${release_elf}" | sed -n '1,${;s/.*[[:space:]]bl*[[:space:]].*/&/p;s/.*<.*>:$/&/p;}' | sed '/msg_/d' | sed '/<test_/d' | sed 's/[^ ].*</</' | sed 's/<//g' | sed 's/>//g' | sed 's/^  */    /' | sed '/+/d' | sed '/^tkn_/d')
for file in ${test_elfs[@]}; do
  testroutine="$(echo "${file}" | sed -n 's/^.*test_\([^.]*\).*\.suite$/\1/p')"
  ROUTINES_WITHOUT_TESTS="$(echo "${ROUTINES_WITHOUT_TESTS}" | sed "/^[[:space:]]*${testroutine}:*\$/d")"
done
echo "${ROUTINES_WITHOUT_TESTS}"
