.text
.align 2

# This routine generates a display showing all possible colours and emitting a
# continuous cycle of a 440 Hz tone for 1 second followed by silence for 1
# second. Its purpose on the Spectrum 128K was to ease the tuning in of TV sets
# to the Spectrum 128's RF signal. For the Spectrum +4 it is mostly there for
# the sake of nostalgia. The display consists of vertical stripes of width 12
# character squares showing each of the eight colours available at both their
# normal (six chargs) and bright (six chars) intensities. The display begins
# with white (colour 7) on the left progressing down to black on the right
# (colour 0). Within each colour stripe in the first eight rows the year '2022'
# is shown in varying ink colours. This leads to a display that shows all
# possible ink colours on all possible paper colours.
#
# On entry:
# On exit:
tv_tuner:                                // L3C10
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
// TODO: test for shift-space combo; if _not_ both pressed, return from routine
  movl    w0, 0x00cccccc
  bl      paint_border                            // Paint white border
  mov     w0, #2
  bl      chan_open                               // Main screen in use
  strb    wzr, [x28, TV_FLAG-sysvars]             // [TV_FLAG] = 0
  mov     w0, #0x16                               // Print character 'AT'
  bl      print_w0
  mov     w0, #0                                  // screen character row 0
  bl      print_w0
  mov     w0, #0                                  // screen character column 0
  bl      print_w0
  mov     w0, #16                                 // number of bytes in tvt_data to print
  mov     w1, #7                                  // initial ink colour
  mov     w2, #0                                  // initial paper colour
  add     w3, w1, w2, lsl #3                      // w3 = attribute value
  strb    w3, [x28, ATTR_T-sysvars]               // update temp attribute sysvar
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

tvt_data:
  .byte   0x13, 0x00                              // Bright, off
  .ascii  " 2022 "
  .byte   0x13, 0x01                              // Bright, on
  .ascii  " 2022 "
