# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Note, Raspberry Pi docs suggest that using the legacy interrupt controller on
# rpi4/rpi400 requires setting `enable_gic=0` in the config.txt file:
#   * https://www.raspberrypi.com/documentation/computers/legacy_config_txt.html#enable_gic-raspberry-pi-4-only
#
# However, this code seems to work with the legacy controller even without this
# setting in config.txt. Perhaps this is because we set `kernel_old=1`
# and thus skip the code in:
#
#   * https://github.com/raspberrypi/tools/blob/master/armstubs/armstub8.S
#
# Alternatively, maybe since the setting `enable_gic` is itself a legacy setting
# maybe the legacy interrupt controller is active by default, and this setting
# has no bearing.
#
# Or another possibility - this setting was interpreted by the Linux kernel
# rather than the GPU when bringing up the ARM and the peripheral devices.
#
# TODO: take a look at the stub to see if it is responsible for disabling the
# legacy interrupt controller. If it isn't, try to find out why we didn't
# need to explicitly enable it, or check if we are inadvertently using the
# GIC or something else without realising it.
#
# There seems to be a walkthrough of the stub code here:
#
#   * https://leiradel.github.io/2019/01/20/Raspberry-Pi-Stubs.html#armstub8s

.text

.align 2
irq_vector_init:
  adr     x0, vectors                             // load VBAR_EL1 with virtual
  msr     vbar_el1, x0                            // vector table address
  ret


enable_irq:
  msr     daifclr, #2
  ret


disable_irq:
  msr     daifset, #2
  ret


show_invalid_entry_message:
  logregs
  ret


enable_ic_bcm283x:
  adrp    x0, 0x40000000 + _start
  ldr     w1, [x0, #0x40]                         // w1 = [ARM_LOCAL register TIMER_CNTRL0] = [0x40000040]
  orr     w1, w1, 0x2                             // set bit 1 (CNT_PNS_IRQ) to cause system timer to raise an IRQ to core 0
  str     w1, [x0, #0x40]
  ret


enable_ic_bcm2711:
  adrp    x1, 0xff841000 + _start                 // x1 = GICD base address
  str     wzr, [x1]                               // [0xff841000]     = [GICD_CTLR]        = 0x00000000                                             => disable GIC distributor
  mov     w3, #0x8
  mov     w4, #0xffffffff
  add     x5, x1, #0x180
  1:
    str     w4, [x5, #0x200]                      // [0xff841380+4*n] = [GICD_ICACTIVERn]  = 0xffffffff for n=0 to 7 (1 bit per interrupt)          => clear all 256 active interrupts
    str     w4, [x5, #0x100]                      // [0xff841280+4*n] = [GICD_ICPENDRn]    = 0xffffffff for n=0 to 7 (1 bit per interrupt)          => clear all 256 pending interrupts
    str     w4, [x5], #0x4                        // [0xff841180+4*n] = [GICD_ICENABLERn]  = 0xffffffff for n=0 to 7 (1 bit per interrupt)          => disable all 256 interrupts
    subs    w3, w3, #1
    b.ne    1b
  mov     w3, #0x40
  mov     w6, #0x01010101
  movl    w7, 0xa0a0a0a0
  add     x5, x1, #0x400
  2:
    str     w6, [x5, #0x400]                      // [0xff841800+4*n] = [GICD_ITARGETSRn]  = 0x01010101 for n=0 to 63 (0x3f) (8 bits per interrupt) => route all 256 interrupts to core 0
    str     w7, [x5], #0x4                        // [0xff841400+4*n] = [GICD_IPRIORITYRn] = 0xa0a0a0a0 for n=0 to 63 (0x3f) (8 bits per interrupt) => set all 256 interrupts priority to 0xa0
    subs    w3, w3, #1
    b.ne    2b
  mov     w3, #0x10
  mov     w8, #0x55555555
  add     x5, x1, #0xc00
  3:
    str     w8, [x5], #0x4                        // [0xff841c00+4*n] = [GICD_ICFGRn]      = 0x55555555 for n=0 to 15 (0xf) (2 bits per interrupt) => set all 256 interrupts to level-sensitive
    subs    w3, w3, #1
    b.ne    3b
  mov     w4, #0x1
  str     w4, [x1]                                // [0xff841000]     = [GICD_CTLR]        = 0x00000001                                            => forward group 1 interrupts from GIC distributor
  mov     w5, #0xf0
  str     w5, [x1, #0x1004]                       // [0xff842004]     = [GICC_PMR]         = 0x000000f0                                            => priority mask = 0xf0
  mov     w6, #0x261
  str     w6, [x1, #0x1000]                       // [0xff842000]     = [GICC_CTLR]        = 0x00000261                                            => EOImodeNS: 1, IRQBypDisGrp1: 1, FIQBypDisGrp1: 1, EnableGrp1: 1
  mov     w4, #0x40000000
  str     w4, [x1, #0x100]                        // [0xff841100]     = [GICD_ISENABLER0]  = 0x40000000                                            => enable interrupt 30 (0x1e)
  ret


handle_irq_bcm283x:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x1, 0x40000000 + _start
  ldr     w0, [x1, #0x60]                         // w0 = [0x40000060]
# cmp     w0, #0x00000002
# b.eq    1f
  logreg  0                                       // Unexpected IRQ
# b       2f
# 1:
  bl      handle_timer_irq
# 2:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


handle_irq_bcm2711:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x8, 0xff842000 + _start
  ldr     w7, [x8, #0xc]                          // w7 = [0xff84200c] = [GICC_IAR]
  logreg  7
  str     w7, [x8, #0x10]                         // [0xff842010] = [GICC_EOIR] = [GICC_IAR]
                                                  // Note: Writing to GICC_EOIR before servicing interrupt, which I believe means the
                                                  // interrupt routine will be reentrant at this point. Writing to EOIR after
                                                  // handling timer may be safer.
  dsb     sy                                      // The GIC architecture specification requires that valid EOIR writes are ordered
                                                  // however probably not needed since device memory writes should already be ordered.
  bl      handle_timer_irq
  str     w7, [x8, #0x1000]                       // [0xff843000] = [GICC_DIR]  = [GICC_IAR]
                                                  // Note: Could set GICC_CTLR.EOImodeNS to 0 and not have separate GICC_EOIR and
                                                  // GICC_DIR writes, i.e. just write to GICC_EOIR after servicing interrupt.

  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
