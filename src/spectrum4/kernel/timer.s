// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text


// Sets a system timer for 0x2000000 ticks in the future and enables it.
// [ARMV8] sD17.11 pD17-7124 -- Generic Timer registers: CNTPCT_EL0, CNTP_CVAL_EL0, CNTP_CTL_EL0
//
// On exit:
//   x1: new timer value ([next_interrupt])
//   x2: 1
.align 2
// ------------------------------------------------------------------------------
// Set up the generic timer comparator and enable timer interrupts
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
timer_init:
  mrs     x1, cntpct_el0                          // [ARMV8] sD17.11.20 pD17-7095 -- CNTPCT_EL0
  mov     x2, #0x2000000                          // TODO: this value should be dependent on clock speed (different for rpi3/rpi4)
  add     x1, x1, x2
  str     x1, [x28, next_interrupt-sysvars]
  msr     cntp_cval_el0, x1                       // [ARMV8] sD17.11.17 pD17-7085 -- CNTP_CVAL_EL0
  mov     x2, #0x1
  msr     cntp_ctl_el0, x2                        // [ARMV8] sD17.11.16 pD17-7081 -- CNTP_CTL_EL0
  ret


// On exit:
//   x1: new timer value ([next_interrupt])
//   x2: 0x2000000
//   plus any changes made by timed_interrupt routine (potentially replacing x1/x2 changes above)
.align 2
// ------------------------------------------------------------------------------
// Handle timer interrupt: advance comparator and call timed_interrupt
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
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


// ------------------------------------------------------------------------------
// Periodic timer callback (stub, currently a no-op)
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
timed_interrupt:
// log     '.'                                     // uncomment to check that interrupt routine is firing
  ret
