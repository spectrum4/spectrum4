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
  local max_attempts="${5}"

  local attempts=0

  "${func}"
  local pid=$!
  disown

  until [ "$(cat "${output_file}" | sed -n '/All tests completed./p' | wc -l)" -gt 0 ] \
    || [ "$(cat "${output_file}" | sed -n '/Test failures!/p' | wc -l)" -gt 0 ] \
    || [ "$(cat "${output_file}" | sed -n '/No tests to run./p' | wc -l)" -gt 0 ] \
    || [ "$(cat "${output_file}" | sed -n '/FATAL: Out of space/p' | wc -l)" -gt 0 ] \
    || [ "${attempts}" -eq "${max_attempts}" ]; do
    attempts=$((attempts+1))
    sleep 1
  done

  kill -9 "${pid}" >/dev/null 2>&1

  failure_count="$(cat "${output_file}" | sed -n '/^FAIL:/p' | wc -l)"
  local failed='false'
  if [ "${attempts}" -eq "${max_attempts}" ] || \
     [ "${failure_count}" -gt 0 ] || \
     [ "$(cat "${output_file}" | sed -n '/FATAL: Out of space/p' | wc -l)" -gt 0 ] || \
     [ "$(cat "${output_file}" | sed -n '/Test failures!/p' | wc -l)" -gt 0 ] || \
     ( \
       [ "$(cat "${output_file}" | sed -n '/All tests completed./p' | wc -l)" -eq 0 ] && \
       [ "$(cat "${output_file}" | sed -n '/No tests to run./p' | wc -l)" -eq 0 ] \
     ); then
    failed='true'
  fi

  if "${failed}"; then
    cat "${output_file}"
  fi

  if [ "${attempts}" -eq "${max_attempts}" ]; then
    echo 'Timed out!' >&2
    exit "${timeoutexitcode}"
  fi

  if "${failed}"; then
    echo "Test failures" >&2
    exit "${failuresexitcode}"
  fi
}

function fuse-tests {
  echo -n > "${test_log}"
  qemu-system-aarch64 -nographic -monitor none -M raspi3b -kernel "${test}.elf" -serial null -serial stdio >"${test_log}" 2>&1 &
}

cd "$(dirname "${0}")"
test="${1}"
test_log="${test}.log"
run_tests fuse-tests "${test_log}" 69 70 60
