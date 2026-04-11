// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// Initialise state for a newly pressed key: arm the repeat counter with
// REPDEL and dispatch to k_decode.
//
// Equivalent to Z80 rom1.s:1403 k_new. The Z80 version also writes the raw
// key into KSTATE+0 (matrix-slot bookkeeping); on spectrum4 that slot is the
// previous-HID-scancode used for edge detection, and it is written by the
// edge-detect block in handle_keyboard_input (xhci.s) before we get here.
// ------------------------------------------------------------------------------
// On entry:
//   w0 = HID scancode (already range-checked to be non-zero and != previous)
//   w16 = merged L|R modifier bits (Ctrl / Shift / Alt in bits 0-3)
//   x28 = sysvars base
// On exit:
//   w3 corrupted
//   KSTATE+2 = REPDEL (initial repeat delay)
k_new:                                   // L02F1
  ldrb    w3, [x28, REPDEL-sysvars]
  strb    w3, [x28, #(KSTATE-sysvars+2)]          // KSTATE+2 = initial repeat countdown
  b       k_decode                                // dispatch: range check → special keys → modifier tables
