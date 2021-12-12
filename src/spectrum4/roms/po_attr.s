.text
.align 2
# -------------
# Set attribute
# -------------
# Update the attribute entry in the attributes file for a corresponding display
# file address, based on attribute characteristics stored in system variables
# ATTR_T, MASK_T, P_FLAG.
#
# TODO: this section is no longer accurate since it now calls poke_address.
# First document poke_address, and then correct this section.
#
# On entry:
#   x0 = address in display file
# On exit:
#   x0 = [P_FLAG]
# #   x1 = [ATTR_T] | ([MASK_T] << 8)
#   x3 = ??
#   x5 = ??
#   x6 = ??
#   x7 = ??
#   x8 = ??
#   x9 = mbreq
# #   x10 = x attribute coordinate (0-107)
# #   x11 = display file offset
#   x12 = 108
# #   x13 = multiplication constant for dividing by 216
# #   x14 = display file offset / 216
# #   x15 = multiplication constant for dividing by 5
# #   x16 = attribute_file address offset
# #   x17 = [0-7] attribute value applied / [8-15] [MASK_T]
#   x18 = 5 * screen third (0x0 / 0x5 / 0xa)
#   x24 = attributes_file
#
# TODO: We shouldn't need to convert a display file address to an attributes file
#       address; instead we should just pass the attributes file address into the
#       routine.
po_attr:                                 // L0BDB
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x9, display_file                        // x9 = start display file address
  add     x9, x9, :lo12:display_file
  adrp    x24, attributes_file                    // x24 = start attributes file address
  add     x24, x24, :lo12:attributes_file
  sub     x11, x0, x9                             // x11 = display file offset
  // attribute address = attributes_file + ((x11/2) % 108) + 108 * (((x11/216) % 20) + 20 * (x11/(216*20*16)))
  mov     x13, #0x0000684c00000000
  movk    x13, #0x012f, lsl #48                   // x13 = 0x012f684c00000000 = 85401593570131968
  umulh   x14, x13, x11                           // x14 = (85401593570131968 * x11) / 18446744073709551616 = int(x11/216)
  mov     x15, #0xcccd000000000000                // x15 = 14757451553962983424
  umulh   x16, x15, x14                           // x16 = 14757451553962983424 * int(x11/216) / 2^64 = (4/5) * int(x11/216)
  lsr     x16, x16, #4                            // x16 = int(int(x11/216)/20)
  add     x16, x16, x16, lsl #2                   // x16 = 5 * int(int(x11/216)/20)
  sub     x16, x14, x16, lsl #2                   // x16 = int(x11/216) - 20 * int(int(x11/216)/20) = (x11/216)%20
  mov     x17, #0x0000f2ba00000000                // x17 = 266880677838848
  umulh   x18, x17, x11                           // x18 = 266880677838848 * x11 / 2^64 = int(x11/(216*20*16))
  add     x18, x18, x18, lsl #2                   // x18 = 5*int(x11/(216*20*16))
  mov     x12, #0x6c                              // x12 = 108
  lsr     x10, x11, #1                            // x10 = int(x11/2)
  msub    x10, x12, x14, x10                      // x10 = int(x11/2)-108*int((x11/2)/108)=(x11/2)%108
  add     x16, x16, x18, lsl #2                   // x16 = (x11/216)%20+20*int(x11/(216*20*16))
  madd    x16, x16, x12, x10                      // x16 = 108*(((x11/216)%20+20*int(x11/(216*20*16))) + (x11/2)%108
                                                  //     = attribute address offset from attributes_file (x24)
  ldrb    w17, [x24, x16]                         // w17 = attribute data
  ldrh    w1, [x28, ATTR_T-sysvars]               // w1[0-7] = [ATTR_T]
                                                  // w1[8-15] = [MASK_T]
  eor     w17, w17, w1                            // w17[0-7] = attribute data EOR [ATTR_T]
                                                  // w17[8-15] = [MASK_T]
  and     w17, w17, w1, lsr #8                    // w17 = attribute data EOR [ATTR_T] AND [MASK_T] (bits 8-31 clear)
  eor     w17, w17, w1                            // w17[0-7] = attribute data EOR [ATTR_T] AND [MASK_T] EOR [ATTR_T]
                                                  // w17[0-8] = [MASK_T]
                                                  // So lower 8 bits of w17 are taken from current screen values when
                                                  // MASK_T bit is 1, and taken from ATTR_T when MASK_T bit is 0.
  ldrb    w0, [x28, P_FLAG-sysvars]               // w0 = [P_FLAG]
                                                  //   Bit 0: Temporary 1=OVER 1, 0=OVER 0.
                                                  //   Bit 1: Permanent 1=OVER 1, 0=OVER 0.
                                                  //   Bit 2: Temporary 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 3: Permanent 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 4: Temporary 1=Using INK 9.
                                                  //   Bit 5: Permanent 1=Using INK 9.
                                                  //   Bit 6: Temporary 1=Using PAPER 9.
                                                  //   Bit 7: Permanent 1=Using PAPER 9.
  tbz     w0, #6, 1f                              // Jump forward to 1: if not PAPER 9.
// PAPER 9
  and     w17, w17, #~0b00111000                  // PAPER = black
  tbnz    w17, #2, 1f                             // If INK is 4/5/6/7 (green/cyan/yellow/white), jump ahead to 1:.
// INK is 0/1/2/3 (black/blue/red/magenta)
  eor     w17, w17, #0b00111000                   // PAPER = white (orr instruction also ok here)
1:
  tbz     w0, #4, 2f                              // Jump forward to 2: if not INK 9.
// INK 9
  and     w17, w17, #~0b00000111                  // INK = black
  tbnz    w17, #5, 2f                             // If PAPER is 4/5/6/7 (green/cyan/yellow/white), jump ahead to 2:.
// PAPER is 0/1/2/3 (black/blue/red/magenta)
  eor     w17, w17, #0b00000111                   // INK = white (orr instruction also ok here)
2:
  strb    w17, [x24, x16]
  add     x0, x24, x16
  mov     w1, w17
  bl      poke_address                            // Update attribute file entry
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
