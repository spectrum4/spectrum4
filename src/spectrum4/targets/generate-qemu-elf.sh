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

# Link the .o file to generate the elf file
"${@}" -o "${elf_output_file}" "${o_input_file}"
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
# Otherwise, if we specify the .img file in the qemu command, we have no way
# of specifying a load address, and it will use 0x80000 which we don't want.
# If we didn't patch the physical address, qemu would try to load the code
# at the virtual address 0xffff000000000000, which wouldn't work.
printf '\x0\x0\' | dd of="${elf_output_file}" bs=1 seek=94 count=2 conv=notrunc 2> /dev/null
