# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# Reset the system channel input and output addresses.
#
# On entry:
# On exit:
#     [CURCHL] = address in CHANS block of channel K
#     [FLAGS] : clears bit 1 and bit 5 => Printer not in use and no new key
#     [FLAGS2] : sets bit 4 => Channel K in use
#     [TV_FLAG] : sets bit 0 => Lower screen in use
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : temp bits cleared
#     [[CURCHL]] = print_out    (Channel K output routine)
#     [[CURCHL]+8] = key_input  (Channel K input routine)
#     [S_POSN_Y_L] = 59
#     [S_POSN_X_L] = 109
#     [ECHO_E_Y] = 59
#     [ECHO_E_X] = 109
#     [DF_CC_L] = display_file + ((61-[DF_SZ])/20)*216*16*20 + 216*(61-[DF_SZ])%20)
#     x0 = 59
#     x1 = 109
#     x2 = display_file + ((61-[DF_SZ])/20)*216*16*20 + 216*(61-[DF_SZ])%20)
#     w3 = [TV_FLAG]
#     w4 = (61-[DF_SZ])%20
#     w5 = 216
#     w6 = 0x10e00
#     w9 = [FLAGS2]
#     x10 = 'K'
#     NZCV = 0b0110
cl_chan:                                 // L0D94
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     x0, #-3                                 // Stream -3 (-> channel K)
  bl      chan_open                               // Open channel K.
  ldr     x0, [x28, CURCHL-sysvars]               // x0 = [CURCHL]
  adr     x1, print_out
  str     x1, [x0], #8                            // Reset output routine to print_out for channel K.
  adr     x1, key_input
  str     x1, [x0], #8                            // Reset input routine to key_input for channel K.
  mov     x0, 59                                  // screen row (120-[DF_SZ]-59)=screen row 59 for channel K.
  mov     x1, 109                                 // reversed column = 109 => column = 0 (109-column)
  bl      cl_set                                  // Save new position in system variables.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
