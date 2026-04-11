// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// TODO: Description
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
wait_key_press:                          // L2653


.if DEMO_AUTORUN
  bl      demo                                    // Demonstrate features for manual inspection.
.endif
  b       sleep
