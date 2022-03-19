#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

function generate_unit_tests {
  local srcdir="${1}"
  local ptrunit="${2}"
  local ptralignstr="${3}"
  local routine="${4}"
  local bashflags="${-}"
  set +x
  echo "# This file is part of the Spectrum +4 Project."
  echo "# Licencing information can be found in the LICENCE file"
  echo "# (C) 2021 Spectrum +4 Authors. All rights reserved."
  echo
  echo "# Extrapolated from /${srcdir}/ files."
  echo
  echo '.global all_suites'
  echo '.include "lib.s"'
  echo ".include \"${test_source##*/}\""
  echo
  echo
  echo ".text"
  echo -n "${ptralignstr}"
  echo "all_suites:"
  all_suites=""
  all_labels="$(cat "${test_source}" | sed -n 's/^[[:space:]]*\([^#[:space:]]*\):.*/\1/p')"
  all_suites="$({
    echo "${all_labels}" | sed -n 's/_setup$//p'
    echo "${all_labels}" | sed -n 's/_setup_regs$//p'
    echo "${all_labels}" | sed -n 's/_effects$//p'
    echo "${all_labels}" | sed -n 's/_effects_regs$//p'
  } | LC_ALL=C sort -u)"
  if [ -n "${all_suites}" ]; then
    echo "  ${ptrunit}" $(echo "${all_suites}" | wc -l)
    echo "${routine//./_}" | sed "s/^/  ${ptrunit} suite_/"
    labels="$(cat "${test_source}" | sed -n 's/^[[:space:]]*\([^#[:space:]]*\):.*/\1/p')"
    tests="$({
      echo "${labels}" | sed -n 's/_setup$//p'
      echo "${labels}" | sed -n 's/_setup_regs$//p'
      echo "${labels}" | sed -n 's/_effects$//p'
      echo "${labels}" | sed -n 's/_effects_regs$//p'
    } | LC_ALL=C sort -u)"
    echo
    echo
    echo -n "${ptralignstr}"
    echo "suite_${routine//./_}:"
    echo "  ${ptrunit}" $(echo "${tests}" | wc -l)
    echo "  ${ptrunit} ${routine%%.*}"
    echo "${tests}" | while read t; do
      echo "  ${ptrunit} test_${t}"
    done
    echo "${tests}" | while read t; do
      echo
      echo
      echo -n "${ptralignstr}"
      echo "test_${t}:"
      for suffix in _{setup,effects}{,_regs}; do
        if [ -n "$(echo "${labels}" | sed -n "s/^${t}${suffix}$/&/p")" ]; then
          echo "  ${ptrunit} ${t}${suffix}"
        else
          echo "  ${ptrunit} 0"
        fi
      done
      echo "  .asciz \"${t}\""
    done
  else
    echo "  ${ptrunit} 0"
  fi
  if [ "${bashflags/x/-}" != "${bashflags}" ]; then set -x; fi
}

test_source="${1}"
routine="$(echo "${test_source}" | sed -n 's/^test_//p' | sed -n 's/\.[^.]*$//p')"
[ -n "${routine}" ] && generate_unit_tests . .hword "" "${routine}" | ../../../utils/asm-format/asm-format
