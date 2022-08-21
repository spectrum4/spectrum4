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
  movl    w0, BORDER_COLOUR
  bl      paint_border                            // Paint border
  mov     w0, #2
  bl      chan_open                               // Main screen in use
  strb    wzr, [x28, TV_FLAG-sysvars]             // [TV_FLAG] = 0
  mov     w7, #0x3f                               // initial attribute value
1:
  and     w0, w7, #0x07
  add     w0, w0, #0x35
  mov     w1, #0x67
  bl      cl_set
2:
  strb    w7, [x28, ATTR_T-sysvars]               // update temp attribute sysvar
  adr     x4, tvt_data
3:
  ldrb    w0, [x4], #1
  cmp     w0, #0x03
  b.eq    4f                                      // char 0x03 => end of string, so exit loop
  stp     x7, x4, [sp, #-16]!
  bl      print_w0
  ldp     x7, x4, [sp], #0x10
  b       3b
4:
  subs    w7, w7, #8
  b.hs    2b
  add     w7, w7, #0x3f
  cmp     w7, #0x37
  b.eq    5f
  b       1b
5:
  adrp    x19, attributes_file
  add     x19, x19, :lo12:attributes_file
  add     x20, x19, 108*8
  adrp    x21, attributes_file_end
  add     x21, x21, :lo12:attributes_file_end
6:
  mov     x0, x20
  ldrb    w1, [x19], #0x01
  add     x20, x20, #0x01
  bl      poke_address
  cmp     x20, x21
  b.ne    6b
7:
# b       7b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

tvt_data:
  .byte   0x13, 0x00                              // Bright, off
  .ascii  " 2022 "
  .byte   0x13, 0x01                              // Bright, on
  .ascii  " 2022 "
  .byte   0x03                                    // Can't use 0x00 for termination byte since in string
tvt_data_end:
