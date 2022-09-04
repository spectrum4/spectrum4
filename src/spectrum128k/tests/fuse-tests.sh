#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

function run_tests {
  local func="${1}"
  local output_file="${2}"
  local timeoutexitcode="${3}"
  local failuresexitcode="${4}"
  local max_seconds_per_run="${5}"
  local max_runs="${6}"

  local seconds=0
  local runs=0
  local completed='false'

  while [ "${runs}" -lt "${max_runs}" ] && ! "${completed}"; do
    "${func}"
    local pid=$!
    disown

    runs=$((runs + 1))
    passed='false'

    until "${completed}" || [ "${seconds}" -eq "${max_seconds_per_run}" ]; do
      if [ "$(cat "${output_file}" | sed -n '/All tests completed./p' | wc -l)" -gt 0 ] ||
        [ "$(cat "${output_file}" | sed -n '/No tests to run./p' | wc -l)" -gt 0 ]; then
        completed='true'
        if [ "$(cat "${output_file}" | sed -n '/^FAIL:/p' | wc -l)" -eq 0 ]; then
          passed='true'
        fi
      elif [ "$(cat "${output_file}" | sed -n '/Test failures!/p' | wc -l)" -gt 0 ] ||
        [ "$(cat "${output_file}" | sed -n '/FATAL: Out of space/p' | wc -l)" -gt 0 ]; then
        completed='true'
      else
        sleep 1
        seconds=$((seconds + 1))
      fi
    done

    kill -9 "${pid}" > /dev/null 2>&1 || true

    if ! "${passed}"; then
      cat "${output_file}" | sed 's///g'
    fi

    if ! "${completed}"; then
      echo 'Timed out!' >&2
    fi
  done

  if ! "${completed}"; then
    exit "${timeoutexitcode}"
  fi

  if ! "${passed}"; then
    exit "${failuresexitcode}"
  fi
}

function fuse-tests {
  echo -n > "${suite_log}"
  fuse --textfile "${suite_log}" --speed 100000 --machine 128 --no-sound --zxprinter --printer --tape "${tzx_file}" --auto-load --no-autosave-settings > "${fuse_log}" 2>&1 &
}

cd "$(dirname "${0}")"
suite="${1}"
tzx_file="${suite}.tzx"
suite_log="${suite}.log"
fuse_log="${suite}.fuselog"
run_tests fuse-tests "${suite_log}" 67 68 300 3
