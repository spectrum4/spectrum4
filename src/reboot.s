# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.align 2
.text

.set PM_BASE,                    0x3f100000
.set PM_WDOG,                    0x24
.set PM_RSTC,                    0x1c
.set PM_RSTC_WRCFG_CLR,          0xffffffcf
.set PM_RSTC_WRCFG_FULL_RESET,   0x00000020
.set PM_PASSWORD,                0x5a000000

# ------------------------------------------------------------------------------
# Reboots the machine after ~150us
# See:
#   https://github.com/torvalds/linux/blob/366a4e38b8d0d3e8c7673ab5c1b5e76bbfbc0085/drivers/firmware/raspberrypi.c#L249-L257
#   https://github.com/torvalds/linux/blob/366a4e38b8d0d3e8c7673ab5c1b5e76bbfbc0085/drivers/watchdog/bcm2835_wdt.c#L100-L123
# ------------------------------------------------------------------------------
reboot:
  adr     x0, msg_rebooting
  mov     x1, #48
  mov     x2, #59
  mov     x3, #0x00ffffff
  mov     x4, #0x00ff0000
  bl      paint_string
  mov     x0, 0x8000000
  bl      wait_cycles
  adr     x0, mbox_reboot
  bl      mbox_call
  mov     x0, PM_BASE
  mov     w1, PM_PASSWORD
  orr     w2, w1, #0x0c
  str     w2, [x0, PM_WDOG]               // [0x3f100024] = 0x5a00000a
  ldr     w3, [x0, PM_RSTC]
  and     w3, w3, PM_RSTC_WRCFG_CLR
  orr     w3, w3, w1
  orr     w3, w3, PM_RSTC_WRCFG_FULL_RESET
  str     w3, [x0, PM_RSTC]               // [0x3f10001c] = ([0x3f10001c] & 0xffffffcf) | 0x5a000020
# msr     daifset, #2
  b       sleep

.data

msg_rebooting: .asciz "Rebooting..."

# Memory block for GPU mailbox call to advise of incoming reboot
.align 4
mbox_reboot:
  .word (mbox_reboot_end-mbox_reboot)     // Buffer size = 24 = 0x18
  .word 0                                 // Request/response code
  .word 0x00030048                        // Tag 0 - RPI_FIRMWARE_NOTIFY_REBOOT
  .word 0                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 // End Tags
mbox_reboot_end:
