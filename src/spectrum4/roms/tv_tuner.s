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
  mov     w0, #6                                  // screen character column 6
  bl      print_w0
  mov     w0, tvt_data                            // address of string to render to screen
  mov     w3, #0x3f                               // initial attribute value
1:
  strb    w3, [x28, ATTR_T-sysvars]               // update temp attribute sysvar
  adr     x4, tvt_data
2:
  ldrb    w0, [x4], #1
  cmp     w0, #0x03
  b.eq    3f                                      // char 0x03 => end of string, so exit loop
  stp     x3, x4, [sp, #-16]!
  bl      print_w0
  ldp     x3, x4, [sp], #0x10
  b       2b
3:
  subs    w3, w3, #8
  b.hs    1b
  add     w3, w3, #0x3f
  cmp     w3, #0x37
  b.eq    4f
  mov     w0, #0x38                               // black text on white background
  strb    w0, [x28, ATTR_T-sysvars]               // update temp attribute sysvar
  mov     w0, #0x17                               // Print character 'TAB'
  stp     x3, x4, [sp, #-16]!
  bl      print_w0
  mov     w0, #6                                  // LSB for TAB position (6)
  bl      print_w0                                // print LSB char
  mov     w0, #0                                  // MSB for TAB position (6)
  bl      print_w0                                // print MSB char
  ldp     x3, x4, [sp], #0x10
  b       1b
4:
# b       4b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

tvt_data:
  .byte   0x13, 0x00                              // Bright, off
  .ascii  " 2022 "
  .byte   0x13, 0x01                              // Bright, on
  .ascii  " 2022 "
  .byte   0x03                                    // Can't use 0x00 for termination byte since in string
