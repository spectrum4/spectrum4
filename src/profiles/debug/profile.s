# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.bss
.align 4
bss_debug_start:

.text
.include "random.s"
.include "runtests.s"
.include "tests.s"
.include "screen.s"
.include "sysvars.s"
.include "demo.s"
.include "uart_debug.s"
.include "paint_debug.s"
.include "reboot_debug.s"
.include "itoa.s"
