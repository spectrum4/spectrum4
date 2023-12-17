# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.align 2
timer_init:
  adr     x0, mailbox_base                        // x0 = mailbox_base
  ldr     x0, [x0, timer_base-mailbox_base]       // x0 = [timer_base] = 0xffff00003f003000 (rpi3) or 0xffff0000fe003000 (rpi4)
  ldr     w1, [x0, #0x04]
  movl    w2, 200000                              // TODO: this value should be dependent on clock speed (different for rpi3/rpi4)
  add     w1, w1, w2
  str     w1, [x0, #0x10]                         // [0xffff00003f003010] += [0xffff00003f003004] + 200000 (rpi3) /  [0xffff0000fe003010] += [0xffff0000fe003004] + 200000 (rpi4)
  ret


handle_timer_irq:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      timer_init                              // [0xffff00003f003010] += [0xffff00003f003004] + 200000 (rpi3) /  [0xffff0000fe003010] += [0xffff0000fe003004] + 200000 (rpi4)
  mov     w1, #0x02
  str     w1, [x0]                                // [0xffff00003f003000] = 2 (rpi3) / [0xffff0000fe003000] = 2 (rpi4)
  bl      timed_interrupt
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


timed_interrupt:
# log     '.'                                     // uncomment to check that interrupt routine is firing
  ret
