// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// Held-key auto-repeat. Called from `keyboard` (roms/keyboard.s) when a key is
// already known to be held (KSTATE+3 != 0).
//
// Decrements the frame counter (KSTATE+2). When it hits zero, re-delivers the
// cached terminal code via LASTK + FLAGS bit 5 and reloads the counter from
// REPPER (not REPDEL — that was the initial delay written when the key was
// first pressed).
//
// Equivalent to Z80 rom1.s:1435 k_repeat. w0 pre-loaded with cached code by
// the caller (`keyboard`) to avoid a redundant load here; matches Z80 where
// `keyboard` has the cached code in A before falling into k_repeat.
// ------------------------------------------------------------------------------
// On entry:
//   x28 = sysvars base
//   w0 = KSTATE+3 (cached terminal code, pre-loaded by caller; guaranteed != 0)
// On exit:
//   x1, x2 corrupted
k_repeat:                                // L0310
  ldrb    w1, [x28, #(KSTATE-sysvars+2)]          // KSTATE+2 = repeat countdown
  subs    w1, w1, #1
  strb    w1, [x28, #(KSTATE-sysvars+2)]
  b.ne    1f                                      // counter not yet at zero
  strb    w0, [x28, LASTK-sysvars]                // deliver held key again
  ldrb    w2, [x28, FLAGS-sysvars]
  orr     w2, w2, #0x20                           // set FLAGS bit 5 (new key available)
  strb    w2, [x28, FLAGS-sysvars]
  ldrb    w1, [x28, REPPER-sysvars]               // reload with repeat-period delay
  strb    w1, [x28, #(KSTATE-sysvars+2)]
1:
  ret
