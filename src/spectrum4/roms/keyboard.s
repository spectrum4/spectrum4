// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// 50 Hz keyboard tick. Called from timed_interrupt (timer.s).
//
// On the Z80 (rom1.s:1344 keyboard) this routine scans the keyboard matrix,
// manages the 5-frame KSTATE debounce, then dispatches to k_new (new press)
// or k_repeat (held key). On spectrum4 the matrix scan is done by USB
// hardware and new presses arrive asynchronously via handle_keyboard_input
// (xhci.s), so this routine handles only the held-key repeat path.
// ------------------------------------------------------------------------------
// On entry:
//   x28 = sysvars base
// On exit:
//   x0-x2 corrupted (via k_repeat)
keyboard:                                // L02BF
  ldrb    w0, [x28, #(KSTATE-sysvars+3)]          // KSTATE+3 = cached terminal code (0 = no key held)
  cbz     w0, 1f
  b       k_repeat                                // tail-branch: k_repeat will ret back to our caller
1:
  ret
