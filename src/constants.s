# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# The base of the stack, located at the top of dedicated CPU RAM.
#
# Note, the stack grows downwards, below stack_base, i.e. the highest
# address that is actually used by the stack is 0x3bffffff. This is also the
# highest address of dedicated RAM for the CPU, since 0x3c000000 to
# 0x3ffffff is used by the GPU (assuming gpu_mem=64 in config.txt).
.set stack_base,          0x3c000000

.set S_FRAME_SIZE,            0x0100

.set SYNC_INVALID_EL1t,         0x00
.set IRQ_INVALID_EL1t,          0x01
.set FIQ_INVALID_EL1t,          0x02
.set ERROR_INVALID_EL1t,        0x03

.set SYNC_INVALID_EL1h,         0x04
.set IRQ_INVALID_EL1h,          0x05
.set FIQ_INVALID_EL1h,          0x06
.set ERROR_INVALID_EL1h,        0x07

.set SYNC_INVALID_EL0_64,       0x08
.set IRQ_INVALID_EL0_64,        0x09
.set FIQ_INVALID_EL0_64,        0x0a
.set ERROR_INVALID_EL0_64,      0x0b

.set SYNC_INVALID_EL0_32,       0x0c
.set IRQ_INVALID_EL0_32,        0x0d
.set FIQ_INVALID_EL0_32,        0x0e
.set ERROR_INVALID_EL0_32,      0x0f
