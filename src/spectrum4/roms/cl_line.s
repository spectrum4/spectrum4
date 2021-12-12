.text
.align 2
# ---------------------------
# Clear text lines of display
# ---------------------------
# This subroutine, called from cl_all, cls_lower and auto_list and above,
# clears text lines at bottom of display.
#
# On entry:
#   x0 = number of lines to be cleared (1-60)
# On exit:
#   x0/x1/x2/x3/x4/x5/x6 corrupted
#   plus whatever poke_address also corrupts
cl_line:                                 // L0E44
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!                   // Backup x23 / x24 on stack.
  stp     x25, x26, [sp, #-16]!                   // Backup x25 / x26 on stack.
  mov     x19, x0                                 // x19 = number of lines to be cleared (1-60)
  bl      cl_addr                                 // Routine CL-ADDR gets top address.
                                                  //   x0 = number of lines to be cleared (1-60)
                                                  //   x1 = start line number to clear
                                                  //   x2 = address of top left pixel of line to clear inside display file
                                                  //   x3 = first screen third to clear (0-2)
                                                  //   x4 = start char line inside first screen third to clear (0-19)
  mov     x5, #216
  mov     x6, #0x10e0
  umsubl  x19, w4, w5, x6                         // x19 = number of lines in top screen third * 216 = byte count for one pixel row across first screen third
  umull   x20, w0, w5                             // x20 = 216 * line count
  mov     x22, x3                                 // x22 = top screen section (0/1/2)
#
  // counters
  mov     x26, x2                                 // x26 = address of first pixel in first section of current pixel row
  mov     w23, #16                                // x23 = number of remaining pixel lines to clear (0-15)
2:
  mov     x21, x26                                // x21 = address of next byte to clear
  mov     x24, x19                                // x24 = number of remaining bytes to clear in current loop
  mov     x25, x22                                // x25 = current screen section (0-2)
3:
  mov     x0, x21
  mov     x1, #0
  bl      poke_address
  add     x21, x21, #1
  subs    x24, x24, #1                            // Reduce byte counter.
  b.ne    3b                                      // Repeat until all rows are cleared.
  add     x21, x21, #0x00f, lsl #12               // x21 += 216*15*20 (=0xfd20) to reach same pixel row in first char line of next
  add     x21, x21, #0xd20                        // screen third.
  mov     x24, #4320                              // x24 = 20 lines * 216 bytes = 4320 bytes
  add     x25, x25, #1                            // x22 = next screen third to update
  cmp     x25, #3
  b.ne    3b                                      // Repeat if more sections to update
  add     x26, x26, #0x001, lsl #12               // Next row pixel address = previous base address + 216 bytes * 20 rows
  add     x26, x26, #0x0e0                        // = previous base address + 4320 bytes = previous + 0x10e0 bytes
  subs    w23, w23, #1                            // Decrease text line pixel counter.
  b.ne    2b                                      // Repeat if not all screen lines of text have been cleared.
  adrp    x21, attributes_file_end                // x21 = first byte after end of attributes file.
  add     x21, x21, :lo12:attributes_file_end
  sub     x22, x21, x20, lsr #1                   // x22 = start address in attributes file to clear
  ldrb    w19, [x28, TV_FLAG-sysvars]             // w19[0-7] = [TV_FLAG]
  tbz     w19, #0, 4f                             // If bit 0 is clear, lower screen is in use; jump ahead to 4:.
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
  b.lo    5b                                      // Repeat iff x22 < x21
  ldp     x25, x26, [sp], #0x10                   // Restore old x25, x26.
  ldp     x23, x24, [sp], #0x10                   // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
