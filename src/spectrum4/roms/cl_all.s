# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ---------------------------
# Clearing whole display area
# ---------------------------
# This subroutine called from CLS, AUTO-LIST and MAIN-3
# clears 24 lines of the display and resets the relevant system variables
# and system channels.
cl_all:                                  // L0DAF
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  str     wzr, [x28, COORDS_X-sysvars]            // set COORDS to 0,0.
  ldrb    w9, [x28, FLAGS2-sysvars]               // w9 = [FLAGS2]
  and     w9, w9, #0xfe                           // w9 = [FLAGS2] with bit 0 clear
  strb    w9, [x28, FLAGS2-sysvars]               // Update [FLAGS2] to have bit 0 clear (signal main screen is clear).
  bl      cl_chan
  mov     x0, #-2                                 // Select system channel 'S'.
  bl      chan_open                               // Routine chan_open opens it.
  bl      temps                                   // Routine temps picks up permanent values.
  mov     x0, #60                                 // There are 60 lines.
  bl      cl_line                                 // Routine cl_line clears all 60 lines.
  ldr     x0, [x28, CURCHL-sysvars]               // x0 = [CURCHL] (channel 'S')
  adr     x1, print_out
  str     x1, [x0], #8                            // Reset output routine to print_out for channel S.
  mov     w0, 1
  strb    w0, [x28, SCR_CT-sysvars]               // Reset SCR_CT (scroll count) to default of 1.
  mov     x0, 60                                  // reversed row = 60 => row = 0 (row = 60 - reversed row)
  mov     x1, 109                                 // reversed column = 109 => column = 0 (column = 109 - reversed column)
  bl      cl_set                                  // Save new position in system variables.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
