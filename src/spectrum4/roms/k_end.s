// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// Deliver a terminal code to the editor.
// Writes w2 to LASTK, sets FLAGS bit 5 ("new key available"), and caches w2
// in KSTATE+3 so the 50 Hz timer (k_repeat, roms/k_repeat.s) can re-deliver
// the same code while the key is held.
//
// Equivalent to Z80 rom1.s:1424 k_end. The Z80 version is just the LASTK /
// FLAGS write. The KSTATE+3 cache is an artefact of our split where Z80 does
// it in k_new (after k_decode) — on spectrum4 the decode pipeline still lives
// in xhci.s so we piggy-back the cache onto k_end. Phase 7 of
// plan_keyboard_migration will move the decode to roms/k_decode.s and at
// that point the KSTATE+3 cache can migrate back into k_new.
//
// Note: the repeat-countdown arming (KSTATE+2 = REPDEL) happens in k_new
// (L02F1) on the press edge, not here.
// ------------------------------------------------------------------------------
// On entry:
//   w2 = terminal code (Spectrum keyboard code) to deliver
//   x28 = sysvars base
// On exit:
//   w1 corrupted
//   LASTK = w2
//   FLAGS bit 5 set
//   KSTATE+3 = w2 (cached for k_repeat)
k_end:                                   // L0308
  strb    w2, [x28, LASTK-sysvars]
  ldrb    w1, [x28, FLAGS-sysvars]
  orr     w1, w1, #0x20                           // set FLAGS bit 5 (new key available)
  strb    w1, [x28, FLAGS-sysvars]
  strb    w2, [x28, #(KSTATE-sysvars+3)]          // cache for k_repeat
  ret
