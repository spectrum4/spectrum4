# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.


.text
.align 2


# This test calls po_attr passing the address of a pixel from the display file (section 1,
# line 5, column 4, pixel row 6). It first sets the current attribute of the character cell to
# TODO xxxxx, and ATTR_T, MASK_T, P_FLAG to other interesting values.


po_attr_1_setup:
  _strb 0b10010101, ATTR_T                // See http://www.breakintoprogstack.co.uk/computers/zx-spectrum/screen-memory-layout
                                          // temp colours: FLASH 1; BRIGHT 0; PAPER 2; INK 5
  _strb 0b01010110, MASK_T                // Current screen attributes are 0b01010101 => FLASH 0; BRIGHT 1; PAPER 2; INK 5
                                          // Read attribute bits 1,2,4,6 from screen (0b01010101), and 0,3,5,7 from ATTR_T (0b10010101)
                                          // => 0b11010101 => INK 5; PAPER 2; BRIGHT 1; FLASH 1
  _strb 0b10010111, P_FLAG                // OVER 1; INVERSE 1; INK 9 (=> INK 7 since PAPER 2) => 0b11010111 = 0xd7
                                          // => FLASH 1: BRIGHT 1: PAPER 2: INK 7
  # TODO - set screen attribute value to something more interesting than 0b01010101
  ret


po_attr_1_setup_regs:
  ldr x0, = display_file + 1*216*20*16 + 5*216 + 4*2 + 6*20*216
                                          // section 1, line 5, column 4, pixel row 6
  ret


po_attr_1_effects:
  # TODO - there should be an attributes file update, and framebuffer updates
  ret


po_attr_1_effects_regs:
  mov x0, #0x97                           // [P_FLAG]
  mov x1, #0x5695                         // [ATTR_T] | ([MASK_T] << 8)
  adr x9, display_file                    // display_file
  mov x10, #4                             // x attribute coordinate
  mov x11, 1*216*20*16 + 6*20*216 + 5*216 + 4*2
                                          // display_file offset
  mov x12, #108                           // 108
  mov x13, #0x012f684c00000000            // multiplication constant
  mov x14, 1*20*16 + 6*20 + 5             // display_file offset / 216 (pixel line number in layout order)
  mov x15, 0xcccd000000000000             // multiplication constant
  mov x16, 1*108*20 + 5*108 + 4           // attribute_file offset
  mov x17, 0x56d7                         // [0-7] new attribute value; [8-15] [MASK_T]
  mov x18, 1*5                            // 5 * screen third (0/5/10)
  mov x24, attributes_file                // attributes_file
  ret
