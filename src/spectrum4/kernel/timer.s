# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Sets a timer for 200,000 ticks in the future, i.e.
# [mailbox_base + 0x10] = [mailbox_base + 0x4] + 200,000
#
# On exit:
#   x0: mailbox_base
#   x1: new timer value ([mailbox_base + 0x4] + 200000)
#   x2: 1
.align 2
timer_init:
  mrs     x1, cntp_cval_el0
  movl    w2, 200000                              // TODO: this value should be dependent on clock speed (different for rpi3/rpi4)
  add     x1, x1, x2
  msr     cntp_cval_el0, x1
  mov     w2, #0x1
  msr     cntp_ctl_el0, x2
  ret


# On exit:
#   <depends on timed_interrupt>
#   x0: mailbox_base
#   x1: 0x2
#   x2: 200000
handle_timer_irq:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mrs     x1, cntp_cval_el0
  movl    w2, 200000                              // TODO: this value should be dependent on clock speed (different for rpi3/rpi4)
  add     x1, x1, x2
  msr     cntp_cval_el0, x1
  dsb     sy
  bl      timed_interrupt
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


timed_interrupt:
  log     '.'                                     // uncomment to check that interrupt routine is firing
  ret
