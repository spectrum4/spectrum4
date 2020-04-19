# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.align 2
.text


# On entry:
#   x0 = error number
error_1:                         // L0008
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldr     x9, [x28, CH_ADD-sysvars]       // x9 = character address from CH_ADD.
  str     x9, [x28, X_PTR-sysvars]        // Copy it to the error pointer X_PTR.
  strb    w0, [x28, ERR_NR-sysvars]       // Store error number in ERR_NR.
  ldr     x9, [x28, ERR_SP-sysvars]       // ERR_SP points to an error handler on the
  mov     sp, x9                          // machine stack. There may be a hierarchy
                                          // of routines.
                                          // to MAIN-4 initially at base.
                                          // or REPORT-G on line entry.
                                          // or  ED-ERROR when editing.
                                          // or   ED-FULL during ed-enter.
                                          // or  IN-VAR-1 during runtime input etc.
  // TODO - a lot to implement here, skipping for now as I haven't understood
  // how the stack swapping works yet.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# Print character in lower 8 bits of w0 to current channel.
# On entry:
#   w0 = char to print (lower 8 bits)
print_w0:                        // L0010
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldr     x1, [x28, CURCHL-sysvars]
  blr     x1
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   w0 = char (1 byte)
print_out:                       // L09F4
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  mov     x19, x0                         // Stash x0.
  bl      po_fetch
  mov     x3, x19
  cmp     x3, #0x20
  b.hs    1f
  cmp     x3, #0x06
  b.lo    2f
  cmp     x3, #0x18
  b.hs    2f
  adr     x4, ctlchrtab-(6*8)
  add     x4, x4, x3, lsl #3
  blr     x4
  b       3f
1:
  bl      po_able
  b       3f
2:
  bl      po_quest
3:
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   w0 = 60 - row
#   w1 = 109 - column
#   x2 = address in display file / printer buffer
#   w3 = 0x08 (chr 8)
po_back:                         // L0A23
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  add     w1, w1, #1
  cmp     w1, #110
  b.ne    3f
  ldrb    w4, [x28, FLAGS-sysvars]        // w9[0-7] = [FLAGS]
  tbnz    w4, #1, 2f
  add     w0, w0, #1
  mov     w1, #2
  cmp     w0, #61
  b.ne    3f
  mov     w0, #60
2:
  mov     w1, #109
3:
  bl      cl_set
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


po_right:                        // L0A3D
// TODO


po_enter:                        // L0A4F
// TODO


po_comma:                        // L0A5F
// TODO


po_quest:                        // L0A69
// TODO


po_2_oper:                       // L0A75
// TODO


po_1_oper:                       // L0A7A
// TODO


# On entry:
#   w0 = 60 - row
#   w1 = 109 - column
#   x2 = address in display file / printer buffer(?)
#   w3 = char (32-255)
po_able:                         // L0AD9
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  bl      po_any
  bl      po_store
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = 60 - screen row (for channel S / K)
#   x1 = 109 - screen column (for channel S / K)
#   x2 = address in display file or printer buffer
po_store:                        // L0ADC
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrb    w3, [x28, FLAGS-sysvars]
  tbnz    w3, #1, 2f
  ldrb    w3, [x28, TV_FLAG-sysvars]
  tbnz    w3, #0, 1f
  strb    w0, [x28, S_POSN_ROW-sysvars]
  strb    w1, [x28, S_POSN_COLUMN-sysvars]
  str     x2, [x28, DF_CC-sysvars]
  b       3f
1:
  strb    w0, [x28, S_POSNL_ROW-sysvars]
  strb    w1, [x28, S_POSNL_COLUMN-sysvars]
  strb    w0, [x28, ECHO_E_ROW-sysvars]
  strb    w1, [x28, ECHO_E_COLUMN-sysvars]
  str     x2, [x28, DF_CCL-sysvars]
  b       3f
2:
  strb    w1, [x28, P_POSN-sysvars]
  str     x2, [x28, PR_CC-sysvars]
3:
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On exit:
#   w0 = 60 - actual row (not set if printing)
#   w1 = 109 - actual column
#   x2 = address in printer buffer or display file
po_fetch:                        // L0B03
  ldrb    w0, [x28, FLAGS-sysvars]
  tbnz    w0, #1, 2f
  ldrb    w0, [x28, TV_FLAG-sysvars]
  tbnz    w0, #0, 1f
  // upper screen
  ldrb    w0, [x28, S_POSNL_ROW-sysvars]
  ldrb    w1, [x28, S_POSNL_COLUMN-sysvars]
  ldr     x2, [x28, DF_CCL]
  b       3f
1:
  // lower screen
  ldrb    w0, [x28, S_POSN_ROW-sysvars]
  ldrb    w1, [x28, S_POSN_COLUMN-sysvars]
  ldr     x2, [x28, DF_CC]
  b 4f
2:
  // printer
  ldrb    w1, [x28, P_POSN-sysvars]
  ldr     x2, [x28, PR_CC]
3:
  ret


# On entry:
#   w0 = 60 - row
#   w1 = 109 - column
#   x2 = address in display file / printer buffer(?)
#   w3 = char (32-255)
po_any:                          // L0B24
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  cmp     w3, #0x80                       // Check if printable chars 32-127.
  b.lo    po_char
  cmp     w3, #0x90
  b.hs    po_t_udg

  // TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


po_t_udg:                        // L0B52
  // TODO


po_char:                         // L0B65
  // TODO


temps:                           // L0D4D
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrh    w0, [x28, ATTR_P-sysvars]       // w0 = ATTR_P + MASK_P
  ldrb    w1, [x28, TV_FLAG-sysvars]
  tbz     w1, #0, 1f
  ldrb    w0, [x28, BORDCR-sysvars]       // attr = BORDCR, mask = 0
1:
  strh    w0, [x28, ATTR_T-sysvars]       // Store ATTR_P/MASK_P in ATTR_T/MASK_T if upper screen, BORDCR/0 if lower screen.
  mov     w0, 0
  tbnz    w1, #0, 2f
  ldrb    w0, [x28, P_FLAG-sysvars]
  lsr     w0, w0, #1
2:
  ldrb    w1, [x28, P_FLAG-sysvars]
  eor     w0, w0, w1
  and     w0, w0, 0x55555555
  eor     w0, w0, w1
  strb    w0, [x28, P_FLAG-sysvars]
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


cls:                             // L0D6B
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  bl      cl_all
  bl      cls_lower
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


cls_lower:                       // L0D6E
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack.
  ldrb    w9, [x28, TV_FLAG-sysvars]      // w9[0-7] = [TV_FLAG]
  and     w9, w9, #0xffffffdf             // Reset bit 5 - signal do not clear lower screen.
  orr     w9, w9, #0x00000001             // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]      // [TV_FLAG] = w9[0-7]
  bl      temps                           // Routine temps picks up temporary colours.
  ldrb    w0, [x28, DF_SZ-sysvars]        // Fetch lower screen DF_SZ.
  bl      cl_line                         // Routine CL-LINE clears lower part and sets permanent attributes.
  adr     x0, attributes_file_end         // x0 = address of first byte after attributes file
  sub     x19, x0, 108*2                  // x19 = attribute address leftmost cell, second line up (first byte after last cell to clear)
  ldrb    w2, [x28, DF_SZ-sysvars]        // Fetch lower screen DF_SZ.
  mov     w3, #108
  umsubl  x20, w2, w3, x0                 // x20 = first attribute cell to clear
  ldrb    w21, [x28, ATTR_P-sysvars]      // Fetch permanent attribute from ATTR_P.
1:                                        // Set attributes file values to [ATTR_P] for lowest [DF_SZ] lines except bottom two lines.
  cmp     x19, x20
  b.ls    2f                              // Exit loop if x19 <= x20 (unsigned)
  sub     x19, x19, #1
  mov     x0, x19
  mov     w1, w21
  bl      poke_address
  b       1b
2:
  mov     w5, 2
  strb    w5, [x28, DF_SZ-sysvars]        // Set the lower screen size to two rows.
  bl      cl_chan
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


cl_chan:                         // L0D94
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, -3                          // Stream -3 (-> channel K)
  bl      chan_open                       // Open channel K.
  ldr     x0, [x28, CURCHL-sysvars]       // x0 = [CURCHL]
  adr     x1, print_out
  str     x1, [x0], #8                    // Reset output routine to print_out for channel K.
  adr     x1, key_input
  str     x1, [x0], #8                    // Reset input routine to key_input for channel K.
# Set cursor position for lower screen, using strange half-reversed coordinates.
# The row seems not to be reversed, and match the actual row number.
# The reversed column seems to range from 109 (leftmost column) down to 2 (rightmost column).
  mov     x0, 59                          // screen row (120-[DF_SZ]-59)=screen row 59 for channel K.
  mov     x1, 109                         // reversed column = 109 => column = 0 (109-column)
  bl      cl_set
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


cl_all:                          // L0DAF
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  str     wzr, [x28, COORDS-sysvars]      // set COORDS to 0,0.
  ldrb    w9, [x28, FLAGS2-sysvars]       // w9 = [FLAGS2]
  and     w9, w9, #0xfe                   // w9 = [FLAGS2] with bit 0 unset
  strb    w9, [x28, FLAGS2-sysvars]       // Update [FLAGS2] to have bit 0 unset (signal main screen is clear).
  bl      cl_chan
  mov     x0, #-2                         // Select system channel 'S'.
  bl      chan_open                       // Routine chan_open opens it.
  bl      temps                           // Routine temps picks up permanent values.
  mov     x0, #60                         // There are 60 lines.
  bl      cl_line                         // Routine cl_line clears all 60 lines.
  ldr     x0, [x28, CURCHL-sysvars]       // x0 = [CURCHL] (channel 'S')
  adr     x1, print_out
  str     x1, [x0], #8                    // Reset output routine to print_out for channel S.
  mov     w0, 1
  strb    w0, [x28, SCR_CT-sysvars]       // Reset SCR_CT (scroll count) to default of 1.
# Set cursor position for upper screen, using strange reversed coordinates.
# Note, reversed row ranges from 60 (top), presumably down to 1+DF_SZ (bottom row).
# However, the reversed column ranges from 109 (leftmost column) down to 2 (rightmost column).
  mov     x0, 60                          // reversed row = 60 => row = 0 (row = 60 - reversed row)
  mov     x1, 109                         // reversed column = 109 => column = 0 (column = 109 - reversed column)
  bl      cl_set
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# Sets the cursor position for the currently active K/S/P channel.
# On entry:
#   x0 = 60 - line offset into section
#     for K: x0 = 120 - [DF_SZ] - actual screen row (x0 range: 1 -> 60)
#     for S: x0 = 60 - actual screen row (x0 range: 1 -> 60)
#     for P: I suspect the same, although maybe x0 range might be bigger.
#   x1 = 109 - actual column
#     for S and K: from 109 (leftmost column) to 2 (rightmost column)
#     for P: I think the same.
cl_set:                          // L0DD9
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  adr     x2, printer_buffer+109
  sub     x2, x2, x1                      // x2 = address inside printer buffer to write char
  ldrb    w3, [x28, FLAGS-sysvars]
  tbnz    w3, #1, 2f                      // if printer is in use, jump to 2:
  ldrb    w4, [x28, TV_FLAG-sysvars]
  tbz     w4, #0, 1f                      // if upper screen in use, jump to 1:
# lower screen in use
  ldrb    w5, [x28, DF_SZ-sysvars]
  add     w0, w0, w5
  sub     w0, w0, #60                     // w0 = 60 - actual row number
1:
  mov     x19, x1
  bl      cl_addr                         // x2 = address of top left pixel of row
  mov     x1, x19                         // x1 = reversed column
  mov     x3, #109
  sub     x3, x3, x1                      // x3 = actual column (0-107)
  add     x2, x2, x3, lsl #1              // x2 = address of top left pixel of char
                                          // x1 = 109 - actual column number
                                          // x0 = 60 - actual row number
2:
  bl      po_store
  ldp     x19, x20, [sp], #16             // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# ---------------------------
# Clear text lines of display
# ---------------------------
# This subroutine, called from cl_all, cls_lower and auto_list and above,
# clears text lines at bottom of display.
#
# On entry:
#   x0 = number of lines to be cleared (1-60)
cl_line:                         // L0E44
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!           // Backup x23 / x24 on stack.
  stp     x25, x26, [sp, #-16]!           // Backup x25 / x26 on stack.
  mov     x19, x0                         // x19 = number of lines to be cleared (1-60)
  bl      cl_addr                         // Routine CL-ADDR gets top address.
                                          //   x0 = number of lines to be cleared (1-60)
                                          //   x1 = start line number to clear
                                          //   x2 = address of top left pixel of line to clear inside display file
                                          //   x3 = first screen third to clear (0-2)
                                          //   x4 = start char line inside first screen third to clear (0-19)
  mov     x5, #216
  mov     x6, #0x10e0
  umsubl  x19, w4, w5, x6                 // x19 = number of lines in top screen third * 216 = byte count for one pixel row across first screen third
  umull   x20, w0, w5                     // x20 = 216 * line count
  mov     x22, x3                         // x22 = top screen section (0/1/2)

  // counters
  mov     x26, x2                         // x26 = address of first pixel in first section of current pixel row
  mov     w23, #16                        // x23 = number of remaining pixel lines to clear (0-15)
2:
  mov     x21, x26                        // x21 = address of next byte to clear
  mov     x24, x19                        // x24 = number of remaining bytes to clear in current loop
  mov     x25, x22                        // x25 = current screen section (0-2)
3:
  mov     x0, x21
  mov     x1, #0
  bl      poke_address
  add     x21, x21, #1
  subs    x24, x24, #1                    // Reduce byte counter.
  b.ne    3b                              // Repeat until all rows are cleared.
  add     x21, x21, #0x00f, lsl #12       // x21 += 216*15*20 (=0xfd20) to reach same pixel row in first char line of next
  add     x21, x21, #0xd20                // screen third.
  mov     x24, #4320                      // x24 = 20 lines * 216 bytes = 4320 bytes
  add     x25, x25, #1                    // x22 = next screen third to update
  cmp     x25, #3
  b.ne    3b                              // Repeat if more sections to update
  add     x26, x26, #0x001, lsl #12       // Next row pixel address = previous base address + 216 bytes * 20 rows
  add     x26, x26, #0x0e0                // = previous base address + 4320 bytes = previous + 0x10e0 bytes
  subs    w23, w23, #1                    // Decrease text line pixel counter.
  b.ne    2b                              // Repeat if not all screen lines of text have been cleared.
  adr     x21, attributes_file_end        // x21 = first byte after end of attributes file.
  sub     x22, x21, x20, lsr #1           // x22 = start address in attributes file to clear
  ldrb    w19, [x28, TV_FLAG-sysvars]     // w19[0-7] = [TV_FLAG]
  tbz     w19, #0, 4f                     // If bit 0 is clear, lower screen is in use; jump ahead to 4:.
  ldrb    w20, [x28, BORDCR-sysvars]
  b       5f
4:
  ldrb    w20, [x28, ATTR_P-sysvars]
5:
  mov     x0, x22
  mov     w1, w20
  bl      poke_address
  add     x22, x22, #1
  cmp     x22, x21
  b.lo    5b                              // Repeat iff x22 < x21
  ldp     x25, x26, [sp], #0x10           // Restore old x25, x26.
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = number of lines to be cleared (1-60)
# On exit:
#   x0 unchanged
#   x1 = start line number to clear
#   x2 = address of top left pixel of line to clear inside display file
#   x3 = start char line / 20
#   x4 = start char line % 20
cl_addr:                         // L0E9B
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!           // Backup x23 / x24 on stack.
  mov     x1, #60
  sub     x1, x1, x0
  adr     x2, display_file
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                      // x3 = 0x0xcccccccccccccccd
  umulh   x3, x3, x1                      // x3 = 14757395258967641293 * x1 / 2^64 = int(0.8*x1)
  lsr     x3, x3, #4                      // x3 = int(x1/20)
  add     x4, x3, x3, lsl #2              // x4 = 5 * int(x1/20)
  sub     x4, x1, x4, lsl #2              // x4 = x1 - 20 * int(x1/20) = x1%20
  mov     x5, #216
  umaddl  x2, w4, w5, x2                  // x2 = display_file + (x1%20)*216
  mov     x6, 0x00010000
  movk    x6, 0xe00
  umaddl  x2, w6, w3, x2                  // x2 = display_file + (x1%20)*216 + (x1/20)*69120
  mov     x19, x0
  mov     x20, x1
  mov     x21, x2
  mov     x22, x3
  mov     x23, x4
  bl      uart_x0
  bl      uart_newline
  mov     x0, x20
  bl      uart_x0
  bl      uart_newline
  mov     x0, x21
  bl      uart_x0
  bl      uart_newline
  mov     x0, x22
  bl      uart_x0
  bl      uart_newline
  mov     x0, x23
  bl      uart_x0
  bl      uart_newline
  mov     x0, x19
  mov     x1, x20
  mov     x2, x21
  mov     x3, x22
  mov     x4, x23
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


add_char:                        // L0F81
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
// TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


key_input:                       // L10A8
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
// TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = stream number in range [-3,15]
# On exit:
#   x0 = ?
chan_open:                       // L1601
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  add     x9, x28, x0, lsl #1             // x9 = sysvars + stream number * 2
  ldrh    w10, [x9, STRMS-sysvars+6]      // w10 = [stream number * 2 + STRMS + 6] = CHANS offset + 1
  cbnz    w10, 1f                         // Non-zero indicates channel open, in which case continue
  mov     x0, 0x17                        // Error Report: Invalid stream
//   bl      error_1
  b       2f
1:
  ldr     x9, [x28, CHANS-sysvars]        // x9 = [CHANS]
  add     x10, x10, x9                    // w10 = [CHANS] + CHANS offset + 1
  sub     x0, x10, #1                     // x0 = address of channel data in CHANS
  bl      chan_flag
2:
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = address of channel information inside CHANS
chan_flag:                       // L1615
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  str     x0, [x28, CURCHL-sysvars]       // set CURCHL system variable to CHANS record address
  ldrb    w9, [x28, FLAGS2-sysvars]       // w9 = [FLAGS2].
  and     w9, w9, #0xffffffef             // w9 = [FLAGS2] with bit 4 unset.
  strb    w9, [x28, FLAGS2-sysvars]       // Update [FLAGS2] to have bit 4 unset (signal K channel not in use).
  ldr     x0, [x0, 16]                    // w0 = channel letter (stored at CHANS record address + 16)
  adr     x1, chn_cd_lu                   // x1 = address of flag setting routine lookup table
  bl      indexer                         // look up flag setting routine
  cbz     x1, 1f                          // If not found then there is no routine (channel 'R') to call.
  blr     x2                              // Call flag setting routine.
1:
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# 'K' channel flag setting routine
chan_k:                          // L1634
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, 'K'
  bl      uart_send
  bl      uart_newline
  ldrb    w9, [x28, TV_FLAG-sysvars]      // w9[0-7] = [TV_FLAG]
  orr     w9, w9, #0x00000001             // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]      // [TV_FLAG] = w9[0-7]
  ldrb    w9, [x28, FLAGS-sysvars]        // w9[0-7] = [FLAGS]
  and     w9, w9, #0xdddddddd             // Reset bit 1 (printer not in use) and bit 5 (no new key).
                                          // See https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64
                                          // for choice of #0xdddddddd
  strb    w9, [x28, FLAGS-sysvars]        // [FLAGS] = w9[0-7]
  ldrb    w9, [x28, FLAGS2-sysvars]       // w9[0-7] = [FLAGS2]
  orr     w9, w9, #0x00000010             // Set bit 4 of FLAGS2 - signal K channel in use.
  strb    w9, [x28, FLAGS2-sysvars]       // [FLAGS2] = w9[0-7]
  bl      temps                           // Set temporary attributes.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# 'S' channel flag setting routine
chan_s:                          // L1642
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, 'S'
  bl      uart_send
  bl      uart_newline
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, #0xfffffffe             // Clear bit 0 - signal main screen in use.
  strb    w0, [x28, TV_FLAG-sysvars]      // [TV_FLAG] = w0[0-7]
  ldrb    w0, [x28, FLAGS-sysvars]
  and     w0, w0, #0xfffffffd             // Clear bit 1 - signal printer not in use.
  strb    w0, [x28, FLAGS-sysvars]        // [FLAGS] = w0[0-7]
  bl      temps
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# 'P' channel flag setting routine
chan_p:                          // L164D
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, 'P'
  bl      uart_send
  bl      uart_newline
  ldrb    w0, [x28, FLAGS-sysvars]
  orr     w0, w0, #2                      // Set bit 1 of FLAGS - signal printer in use.
  strb    w0, [x28, FLAGS-sysvars]
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# Routine indexer searches an in-memory key/value store for x0.
#
# Keys and values are double words (64 bit values). Each record contains a single
# key and a single value. Keys and values may have unrestricted 64 bit values.
#
# The structure of the key/value store is:
#
#   uint64: number of records
#   [
#     uint64: key
#     uint64: value
#   ] * number of records
#
# Therefore the size of the store is [ 2*(number of records)+1 ] * 8 bytes (since
# 64 bits require 8 bytes of storage).
#
# * The key/value store must be 8 byte aligned in memory.
# * Records may be stored in an arbitrary order; however if a duplicate key exists,
#   the record with the lowest address in memory will take precendence.
# * Callers should check for non-zero x1 before using x2.
#
# On entry:
#   x0 = 64 bit key to search for
#   x1 = address of key/value store (8 byte aligned)
#
# On exit:
#   x0 unchanged
#   x1 = address of 64 bit key if found, otherwise 0
#   x2 = 64 bit value for key if found, otherwise undefined value
indexer:                         // L16DC
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  mov     x19, x0
  mov     x20, x1
  bl      uart_newline
  mov     x0, 'I'
  bl      uart_send
  bl      uart_newline
  mov     x0, x19
  bl      uart_x0
  bl      uart_newline
  mov     x0, x20
  bl      uart_x0
  bl      uart_newline
  mov     x0, x19
  mov     x1, x20
  ldr     x9, [x1], #-8                   // x9 = number of records. Set x1 to lookup table address - 8 = address of first record - 16.
1:
  cbz     x9, 2f                          // If all records have been exhausted, jump forward to 2:.
  ldr     x10, [x1, #16]!                 // Load key at x1+16 into x10, and proactively increase x1 by 16 for the next iteration.
  sub     x9, x9, 1                       // x9 = number of remaining records to check (which is now one less)
  cmp     x0, x10                         // Check if key matches wanted key.
  b.ne    1b                              // If not, loop back to 1:.
  ldr     x2, [x1, #8]                    // Key matches, set x2 to the value stored in x1 + 8, and leave x1 as it is.
  b       3f                              // Jump forward to 3:.
2:
  mov     x1, 0                           // Set x1 to zero to indicate value wasn't found.
3:
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


report_j:                        // L15C4
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
// TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret
