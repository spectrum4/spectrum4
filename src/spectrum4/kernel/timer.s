// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text


// Sets up the generic timer for 20ms (50 Hz) interrupts.
// Period derived from cntfrq so rpi3 (19.2 MHz) and rpi4 (54 MHz) match.
// [ARMV8] sD17.11 pD17-7124 -- Generic Timer registers: CNTPCT_EL0, CNTP_CVAL_EL0, CNTP_CTL_EL0
.align 2
// ------------------------------------------------------------------------------
// Compute the 20ms timer period and arm the generic timer comparator
// ------------------------------------------------------------------------------
// On entry:
//   x28 = sysvars base
// On exit:
//   x1 corrupted
//   x2 corrupted
//   x3 corrupted
timer_init:
  ldr     w2, cntfrq                              // w2 = clock frequency (54 MHz rpi4, 19.2 MHz rpi3)
  mov     w3, #50
  udiv    w2, w2, w3                              // w2 = cntfrq / 50 = ticks per 20ms frame
  str     w2, [x28, timer_period-sysvars]
  mrs     x1, cntpct_el0                          // [ARMV8] sD17.11.20 pD17-7095 -- CNTPCT_EL0
  add     x1, x1, x2
  str     x1, [x28, next_interrupt-sysvars]
  msr     cntp_cval_el0, x1                       // [ARMV8] sD17.11.17 pD17-7085 -- CNTP_CVAL_EL0
  mov     x2, #0x1
  msr     cntp_ctl_el0, x2                        // [ARMV8] sD17.11.16 pD17-7081 -- CNTP_CTL_EL0
  ret


.align 2
// ------------------------------------------------------------------------------
// Handle timer interrupt: advance comparator by 20ms and call timed_interrupt
// ------------------------------------------------------------------------------
// On entry:
//   x28 = sysvars base
// On exit:
//   TODO
handle_timer_irq:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x1, [x28, next_interrupt-sysvars]
  ldr     w2, [x28, timer_period-sysvars]         // ticks per 20ms frame (populated by timer_init)
  add     x1, x1, x2
  str     x1, [x28, next_interrupt-sysvars]
  msr     cntp_cval_el0, x1
  dsb     sy
  bl      timed_interrupt
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


// ------------------------------------------------------------------------------
// 50 Hz timer tick dispatch. Currently only drives keyboard auto-repeat via
// k_repeat (roms/k_repeat.s). Future time-based work (audio sample feeder, etc.)
// would also hook in here.
// ------------------------------------------------------------------------------
// On entry:
//   x28 = sysvars base
// On exit:
//   x0-x2 corrupted (via k_repeat)
timed_interrupt:
.if ROMS_INCLUDE
  b       keyboard
.else
  ret                                             // no roms loaded (test build) -- nothing to do
.endif
