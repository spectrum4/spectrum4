#!/usr/bin/env bash

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

elf_file="${1}"
img_file="${2}"
tzx_file="${3}"
routine="${4}"

# Determine which address holds the Spectrum output channel number for the test output.
channel_address=$((0x$("${Z80_TOOLCHAIN_PREFIX}readelf" -W -a "${elf_file}" | sed -n '/ channel_assign$/s/.*: \([0-9a-f]*\).*/\1/p') + 1))

../../../utils/tzx-code-loader/tzx-code-loader "${img_file}" "${tzx_file}" 33024 "${channel_address}" 3 runtests.b "${routine:0:10}" 1000
