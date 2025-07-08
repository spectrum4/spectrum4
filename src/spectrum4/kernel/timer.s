# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Sets a system timer for 0x2000000 ticks in the future and enables it.
#
# On exit:
#   x1: new timer value ([next_interrupt])
#   x2: 1
.align 2
timer_init:
  mrs     x1, cntp_cval_el0
  mov     x2, #0x2000000                          // TODO: this value should be dependent on clock speed (different for rpi3/rpi4)
  add     x1, x1, x2
  str     x1, [x28, next_interrupt-sysvars]
  msr     cntp_cval_el0, x1
  mov     x2, #0x1
  msr     cntp_ctl_el0, x2
  ret


# On exit:
#   x1: new timer value ([next_interrupt])
#   x2: 0x2000000
#   plus any changes made by timed_interrupt routine (potentially replacing x1/x2 changes above)
.align 2
handle_timer_irq:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x1, [x28, next_interrupt-sysvars]
  mov     x2, #0x2000000                          // TODO: this value should be dependent on clock speed (different for rpi3/rpi4)
  add     x1, x1, x2
  str     x1, [x28, next_interrupt-sysvars]
  msr     cntp_cval_el0, x1
  dsb     sy
  bl      timed_interrupt
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


timed_interrupt:
  log     '.'                                     // uncomment to check that interrupt routine is firing
  ret
