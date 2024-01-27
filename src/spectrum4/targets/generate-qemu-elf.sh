#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

elf_output_file="${1}"
o_input_file="${2}"

shift 2

# This horrible hack is needed because --as-needed won't work for us currently
# since pci code depends on spectrum4 (for uart logging), and spectrum4 depends
# on pci (for pci host probe). The way to fix this would be to split uart into
# its own module that spectrum4 and pci both depend on, but this is just an
# experimental branch, so not really worth it, as the C code isn't here to
# stay, just to get things working before converting just the parts we need to
# assembly. Note, we take the trouble to avoid linking in pci code if not
# needed, so all tests don't run when we change pci code that they don't use!
: ${AARCH64_TOOLCHAIN_PREFIX:=aarch64-none-elf-}
if [ "$("${AARCH64_TOOLCHAIN_PREFIX}readelf" -s "${o_input_file}" | sed -n 's/^  *[^ ][^ ]*  *[^ ][^ ]*\(1\).* ABS PCI_INCLUDE$/\1/p')" == '1' ]; then
  "${@}" -o "${elf_output_file}" "${o_input_file}" ../kernel/*.o
else
  "${@}" -o "${elf_output_file}" "${o_input_file}"
fi

# Now patch the elf program header to set p_paddr to physical address
# 0x0000000000000000 instead of 0xffff000000000000. See:
#
#   https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#Program_header
#
# I couldn't find a way to do this in the link step directly. Since modifying
# an already generated elf file, we need to execute the ld and the dd command
# in the same script, so that tup doesn't complain about modifying an "owned"
# file. Note, we go to this trouble so that the generated binary image is
# linked with virtual addresses as required, but to trick qemu into loading the
# text image from the elf file at physical address 0x0. This emulates the
# behaviour of kernel_old=1 in the config.txt file that qemu doesn't use.
# Otherwise, if we specify the .img file in the qemu command, we have no way of
# specifying a load address, and it will use 0x80000 which we don't want.  If
# we didn't patch the physical address, qemu would try to load the code at the
# virtual address 0xffff000000000000, which wouldn't work.
printf '\x0\x0\' | dd of="${elf_output_file}" bs=1 seek=94 count=2 conv=notrunc 2> /dev/null
