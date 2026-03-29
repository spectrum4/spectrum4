# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# ----------------------
# Main Key Waiting Loop
# ----------------------
# Waits for a key press, then dispatches it.
# This is the 128K equivalent of rom0.s:9926 (L2653).
#
# The loop:
#   1. Reset L-mode (mode_l_2)
#   2. Poll FLAGS bit 5 (new key available), sleeping via WFI between polls
#   3. Read LASTK, clear FLAGS bit 5
#   4. Dispatch key via process_key (L2669)
#   5. Repeat
#
# On entry: x28 = sysvars base (preserved across calls)
# On exit: never returns (infinite loop)
wait_key_press:                          // L2653

  bl      mode_l_2                                // Reset 'L' mode.

  // Poll FLAGS bit 5 with WFI between polls.
  // WFI sleeps the CPU until the next interrupt (xHCI MSI for keyboard,
  // or timer). On wake, we check if a new key is available.
1:
  dsb     sy
  wfi                                             // Sleep until interrupt
  ldrb    w0, [x28, FLAGS-sysvars]
  tbz     w0, #5, 1b                              // Loop if FLAGS bit 5 not set

  // New key available: read LASTK and clear FLAGS bit 5
  and     w0, w0, #~0x20                          // Clear bit 5
  strb    w0, [x28, FLAGS-sysvars]
  ldrb    w0, [x28, LASTK-sysvars]                // w0 = key code

  // Dispatch key press (skip key click for now — no sound hardware)
  bl      process_key                             // L2669: process the key press

  b       wait_key_press                          // Loop
