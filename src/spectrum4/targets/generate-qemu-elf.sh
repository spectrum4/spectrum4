#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021-2026 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

elf_output_file="${1}"
o_input_file="${2}"

shift 2

# Link the .o file to generate the elf file
"${@}" -o "${elf_output_file}" "${o_input_file}"

# Patch the ELF program headers so each LOAD segment's p_paddr matches the low
# 32 bits of its p_vaddr. Without this, QEMU tries to load segments at the
# upper-half virtual addresses (e.g. 0xfffffff000070000), which it can't, and
# the segment isn't loaded at all -- causing UDEF when execution reaches it.
# See:
#   https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#Program_header
#
# Note, we go to this trouble so that the generated binary image is
# linked with virtual addresses as required, but to trick qemu into loading the
# text image from the elf file at physical address 0x0. This emulates the
# behaviour of kernel_old=1 in the config.txt file that qemu doesn't use.
# Otherwise, if we specify the .img file in the qemu command, we have no way
# of specifying a load address, and it will use 0x80000 which we don't want.
# If we didn't patch the physical address, qemu would try to load the code
# at the virtual address 0xfffffff000000000, which wouldn't work.
#
# Layout per ELF64 spec (each program header is 56 bytes):
#   bytes 64..76:   ELF header phoff/phentsize/phnum/phentcount fields
#   bytes 80..    : program header table
#     ph[i] offset 0:    p_type (4 bytes)
#     ph[i] offset 4:    p_flags (4 bytes)
#     ph[i] offset 8:    p_offset (8 bytes)
#     ph[i] offset 16:   p_vaddr (8 bytes)
#     ph[i] offset 24:   p_paddr (8 bytes)   <-- patch high 4 bytes to 0
#     ph[i] offset 32+:  p_filesz, p_memsz, p_flags, p_align
#
# The kernel is linked at 0xfffffff000000000+, so zeroing the high 4 bytes of
# p_paddr maps each segment's physical load address to its (virtual offset
# from the kernel base), which is what QEMU's `-kernel` loader needs. We do
# this in the same script as ld so tup doesn't see two writes to one output.
PT_LOAD=1
phoff=$(od -An -tu8 -j32 -N8 "${elf_output_file}" | tr -d ' ')
phentsize=$(od -An -tu2 -j54 -N2 "${elf_output_file}" | tr -d ' ')
phnum=$(od -An -tu2 -j56 -N2 "${elf_output_file}" | tr -d ' ')
i=0
while [ "${i}" -lt "${phnum}" ]; do
  ph_base=$((phoff + i * phentsize))
  p_type=$(od -An -tu4 -j"${ph_base}" -N4 "${elf_output_file}" | tr -d ' ')
  if [ "${p_type}" = "${PT_LOAD}" ]; then
    # Zero the upper 4 bytes of p_paddr (offset 24+4 = 28 within program header)
    dd if=/dev/zero of="${elf_output_file}" bs=1 seek=$((ph_base + 28)) count=4 conv=notrunc 2> /dev/null
  fi
  i=$((i + 1))
done
