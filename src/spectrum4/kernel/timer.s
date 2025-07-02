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
#   x2: 200000
.align 2
timer_init:
# adr     x0, mailbox_base                        // x0 = mailbox_base
# ldr     x0, [x0, timer_base-mailbox_base]       // x0 = [timer_base] = 0x3f003000 (rpi3) or 0xfe003000 (rpi4)
# ldr     w1, [x0, #0x4]
# movl    w2, 200000                              // TODO: this value should be dependent on clock speed (different for rpi3/rpi4)
# add     w1, w1, w2
# str     w1, [x0, #0x10]                         // [0x3f003010] = [0x3f003004] + 200000 (rpi3) /  [0xfe003010] = [0xfe003004] + 200000 (rpi4)

  // rpi4 only, experiment, based on
  //   https://github.com/s-matyukevich/raspberry-pi-os/blob/7295dee52cd6878a686f49ed5b9c47fd20b65888/exercises/lesson03/1/szediwy/src/timer.c#L31
  //   https://github.com/s-matyukevich/raspberry-pi-os/blob/7295dee52cd6878a686f49ed5b9c47fd20b65888/exercises/lesson03/1/szediwy/include/peripherals/timer.h#L19-L24
  //   https://github.com/s-matyukevich/raspberry-pi-os/blob/7295dee52cd6878a686f49ed5b9c47fd20b65888/exercises/lesson03/1/szediwy/include/peripherals/base.h#L17
  //   https://github.com/s-matyukevich/raspberry-pi-os/blob/7295dee52cd6878a686f49ed5b9c47fd20b65888/exercises/lesson03/1/szediwy/include/peripherals/timer.h#L29-L30
  adrp    x0, 0xff800000 + _start
  movl    w1, 0x39a7ec80
  strwi   w1, x0, #0x34

  ret


# On exit:
#   <depends on timed_interrupt>
#   x0: mailbox_base
#   x1: 0x2
#   x2: 200000
handle_timer_irq:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
# bl      timer_init                              // [0x3f003010] = [0x3f003004] + 200000 (rpi3) /  [0xfe003010] = [0xfe003004] + 200000 (rpi4)
# mov     w1, #0x02
# str     w1, [x0]                                // [0x3f003000] = 2 (rpi3) / [0xfe003000] = 2 (rpi4)

  // rpi4 only, experiment, based on
  //   https://github.com/s-matyukevich/raspberry-pi-os/blob/7295dee52cd6878a686f49ed5b9c47fd20b65888/exercises/lesson03/1/szediwy/src/timer.c#L26
  adrp    x0, 0xff800000 + _start
  mov     w1, #0xc0000000
  //   https://github.com/s-matyukevich/raspberry-pi-os/blob/7295dee52cd6878a686f49ed5b9c47fd20b65888/exercises/lesson03/1/szediwy/include/peripherals/timer.h#L26-L27
  strwi   w1, x0, #0x38

  dsb     sy
  bl      timed_interrupt
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


timed_interrupt:
  log     '.'                                     // uncomment to check that interrupt routine is firing
  ret
