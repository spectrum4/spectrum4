# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.arch armv8-a
.cpu cortex-a53

.include "src/spectrum4.s"
.include "src/ramdisk.s"
.include "src/uart.s"
.include "src/data.s"
.include "src/font.s"
.include "src/screen.s"
.include "src/sysvars.s"
.include "src/reboot.s"
.include "src/paint.s"

# .include "src/constants.s"
# .include "src/macros.s"
# .include "src/kernel.s"
