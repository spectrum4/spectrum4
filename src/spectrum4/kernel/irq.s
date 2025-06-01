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
  mov     w0, #0x00000002
  adrp    x1, 0x3f00b000 + _start
  str     w0, [x1, #0x210]                        // [0x3f00b210] = 0x00000002
  ret


enable_ic_bcm2711:
  mov     w0, #0x00000002
  adrp    x1, 0xfe00b000 + _start
  str     w0, [x1, #0x210]                        // [0xfe00b210] = 0x00000002
//   adrp    x2, 0xff841000 + _start                 // GIC Distributor
//   adrp    x1, 0xff842000 + _start                 // GIC CPU Interface
//   mov     w0, #0x000001e7
//   str     w0, [x1]                                // Enable group 1 IRQs from CPU interface [GICC_CTLR]=[0xff841000]=0x000001e7
//                                                   // See https://developer.arm.com/documentation/ihi0048/b/Programmers--Model/About-the-programmers--model/CPU-interface-register-map?lang=en
//   mov     w0, #0x000000ff
//   str     w0, [x1, #0x4]                          // priority mask [0xff841004]=0x000000ff
//   add     x2, x2, #0x80                           // x2 = 0xff842080 + _start
//   mov     x0, #0x20
//   mov     w1, #~0                                 // group 1 all the things
// 1:
//   subs    x0, x0, #4                              // x0 = 0x1c, 0x18, 0x14, 0x10, 0x0c, 0x08, 0x04, 0x00
//   str     w1, [x2, x0]                            // [0xff84209c] / [0xff82098] / [0xff82094] / [0xff82090] / [0xff8208c] / [0xff82088] / [0xff82084] / [0xff82080] = 0xffffffff
//   b.ne    1b
  ret


handle_irq_bcm283x:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x1, 0x3f00b000 + _start
  ldr     w0, [x1, #0x204]                        // w0 = [0x3f00b204]
  cmp     w0, #2
  b.ne    1f
  bl      handle_timer_irq
.if UART_DEBUG
  b       2f
.endif
1:
.if UART_DEBUG
  bl      log_unknown_interrupt_value
2:
.endif
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


handle_irq_bcm2711:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x1, 0xfe00b000 + _start
  ldr     w0, [x1, #0x200]                        // w0 = [0xfe00b200]
  cmp     w0, #2
  b.ne    1f
  bl      handle_timer_irq
.if UART_DEBUG
  b       2f
.endif
1:
.if UART_DEBUG
  bl      log_unknown_interrupt_value
2:
.endif
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


.if UART_DEBUG
log_unknown_interrupt_value:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x1, msg_unknown_interrupt_value
  mov     x2, #32
  bl      hex_x0
  adr     x0, msg_unknown_interrupt
  bl      uart_puts
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


msg_unknown_interrupt:
  .ascii "Unknown interrupt: 0x"                  // concatenates with the string below
msg_unknown_interrupt_value:
  .asciz "........\r\n"                           // stops (.) are replaced with value in hex_x0 routine
.endif
