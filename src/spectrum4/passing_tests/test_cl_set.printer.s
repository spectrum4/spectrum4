# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by test_cl_set.sh. DO NOT EDIT!

.text


cl_set_printer_01_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_01_setup_regs:
  mov     x1, 0x01
  ret

cl_set_printer_01_effects:
  _strb   0x01, P_POSN_X
  _str    (printer_buffer + 0x006c), PR_CC
  ret

cl_set_printer_01_effects_regs:
  adr     x2, (printer_buffer + 0x006c)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_02_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_02_setup_regs:
  mov     x1, 0x02
  ret

cl_set_printer_02_effects:
  _strb   0x02, P_POSN_X
  _str    (printer_buffer + 0x006b), PR_CC
  ret

cl_set_printer_02_effects_regs:
  adr     x2, (printer_buffer + 0x006b)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_03_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_03_setup_regs:
  mov     x1, 0x03
  ret

cl_set_printer_03_effects:
  _strb   0x03, P_POSN_X
  _str    (printer_buffer + 0x006a), PR_CC
  ret

cl_set_printer_03_effects_regs:
  adr     x2, (printer_buffer + 0x006a)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_04_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_04_setup_regs:
  mov     x1, 0x04
  ret

cl_set_printer_04_effects:
  _strb   0x04, P_POSN_X
  _str    (printer_buffer + 0x0069), PR_CC
  ret

cl_set_printer_04_effects_regs:
  adr     x2, (printer_buffer + 0x0069)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_05_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_05_setup_regs:
  mov     x1, 0x05
  ret

cl_set_printer_05_effects:
  _strb   0x05, P_POSN_X
  _str    (printer_buffer + 0x0068), PR_CC
  ret

cl_set_printer_05_effects_regs:
  adr     x2, (printer_buffer + 0x0068)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_06_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_06_setup_regs:
  mov     x1, 0x06
  ret

cl_set_printer_06_effects:
  _strb   0x06, P_POSN_X
  _str    (printer_buffer + 0x0067), PR_CC
  ret

cl_set_printer_06_effects_regs:
  adr     x2, (printer_buffer + 0x0067)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_07_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_07_setup_regs:
  mov     x1, 0x07
  ret

cl_set_printer_07_effects:
  _strb   0x07, P_POSN_X
  _str    (printer_buffer + 0x0066), PR_CC
  ret

cl_set_printer_07_effects_regs:
  adr     x2, (printer_buffer + 0x0066)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_08_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_08_setup_regs:
  mov     x1, 0x08
  ret

cl_set_printer_08_effects:
  _strb   0x08, P_POSN_X
  _str    (printer_buffer + 0x0065), PR_CC
  ret

cl_set_printer_08_effects_regs:
  adr     x2, (printer_buffer + 0x0065)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_09_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_09_setup_regs:
  mov     x1, 0x09
  ret

cl_set_printer_09_effects:
  _strb   0x09, P_POSN_X
  _str    (printer_buffer + 0x0064), PR_CC
  ret

cl_set_printer_09_effects_regs:
  adr     x2, (printer_buffer + 0x0064)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_0a_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_0a_setup_regs:
  mov     x1, 0x0a
  ret

cl_set_printer_0a_effects:
  _strb   0x0a, P_POSN_X
  _str    (printer_buffer + 0x0063), PR_CC
  ret

cl_set_printer_0a_effects_regs:
  adr     x2, (printer_buffer + 0x0063)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_0b_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_0b_setup_regs:
  mov     x1, 0x0b
  ret

cl_set_printer_0b_effects:
  _strb   0x0b, P_POSN_X
  _str    (printer_buffer + 0x0062), PR_CC
  ret

cl_set_printer_0b_effects_regs:
  adr     x2, (printer_buffer + 0x0062)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_0c_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_0c_setup_regs:
  mov     x1, 0x0c
  ret

cl_set_printer_0c_effects:
  _strb   0x0c, P_POSN_X
  _str    (printer_buffer + 0x0061), PR_CC
  ret

cl_set_printer_0c_effects_regs:
  adr     x2, (printer_buffer + 0x0061)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_0d_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_0d_setup_regs:
  mov     x1, 0x0d
  ret

cl_set_printer_0d_effects:
  _strb   0x0d, P_POSN_X
  _str    (printer_buffer + 0x0060), PR_CC
  ret

cl_set_printer_0d_effects_regs:
  adr     x2, (printer_buffer + 0x0060)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_0e_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_0e_setup_regs:
  mov     x1, 0x0e
  ret

cl_set_printer_0e_effects:
  _strb   0x0e, P_POSN_X
  _str    (printer_buffer + 0x005f), PR_CC
  ret

cl_set_printer_0e_effects_regs:
  adr     x2, (printer_buffer + 0x005f)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_0f_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_0f_setup_regs:
  mov     x1, 0x0f
  ret

cl_set_printer_0f_effects:
  _strb   0x0f, P_POSN_X
  _str    (printer_buffer + 0x005e), PR_CC
  ret

cl_set_printer_0f_effects_regs:
  adr     x2, (printer_buffer + 0x005e)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_10_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_10_setup_regs:
  mov     x1, 0x10
  ret

cl_set_printer_10_effects:
  _strb   0x10, P_POSN_X
  _str    (printer_buffer + 0x005d), PR_CC
  ret

cl_set_printer_10_effects_regs:
  adr     x2, (printer_buffer + 0x005d)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_11_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_11_setup_regs:
  mov     x1, 0x11
  ret

cl_set_printer_11_effects:
  _strb   0x11, P_POSN_X
  _str    (printer_buffer + 0x005c), PR_CC
  ret

cl_set_printer_11_effects_regs:
  adr     x2, (printer_buffer + 0x005c)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_12_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_12_setup_regs:
  mov     x1, 0x12
  ret

cl_set_printer_12_effects:
  _strb   0x12, P_POSN_X
  _str    (printer_buffer + 0x005b), PR_CC
  ret

cl_set_printer_12_effects_regs:
  adr     x2, (printer_buffer + 0x005b)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_13_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_13_setup_regs:
  mov     x1, 0x13
  ret

cl_set_printer_13_effects:
  _strb   0x13, P_POSN_X
  _str    (printer_buffer + 0x005a), PR_CC
  ret

cl_set_printer_13_effects_regs:
  adr     x2, (printer_buffer + 0x005a)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_14_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_14_setup_regs:
  mov     x1, 0x14
  ret

cl_set_printer_14_effects:
  _strb   0x14, P_POSN_X
  _str    (printer_buffer + 0x0059), PR_CC
  ret

cl_set_printer_14_effects_regs:
  adr     x2, (printer_buffer + 0x0059)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_15_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_15_setup_regs:
  mov     x1, 0x15
  ret

cl_set_printer_15_effects:
  _strb   0x15, P_POSN_X
  _str    (printer_buffer + 0x0058), PR_CC
  ret

cl_set_printer_15_effects_regs:
  adr     x2, (printer_buffer + 0x0058)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_16_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_16_setup_regs:
  mov     x1, 0x16
  ret

cl_set_printer_16_effects:
  _strb   0x16, P_POSN_X
  _str    (printer_buffer + 0x0057), PR_CC
  ret

cl_set_printer_16_effects_regs:
  adr     x2, (printer_buffer + 0x0057)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_17_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_17_setup_regs:
  mov     x1, 0x17
  ret

cl_set_printer_17_effects:
  _strb   0x17, P_POSN_X
  _str    (printer_buffer + 0x0056), PR_CC
  ret

cl_set_printer_17_effects_regs:
  adr     x2, (printer_buffer + 0x0056)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_18_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_18_setup_regs:
  mov     x1, 0x18
  ret

cl_set_printer_18_effects:
  _strb   0x18, P_POSN_X
  _str    (printer_buffer + 0x0055), PR_CC
  ret

cl_set_printer_18_effects_regs:
  adr     x2, (printer_buffer + 0x0055)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_19_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_19_setup_regs:
  mov     x1, 0x19
  ret

cl_set_printer_19_effects:
  _strb   0x19, P_POSN_X
  _str    (printer_buffer + 0x0054), PR_CC
  ret

cl_set_printer_19_effects_regs:
  adr     x2, (printer_buffer + 0x0054)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_1a_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_1a_setup_regs:
  mov     x1, 0x1a
  ret

cl_set_printer_1a_effects:
  _strb   0x1a, P_POSN_X
  _str    (printer_buffer + 0x0053), PR_CC
  ret

cl_set_printer_1a_effects_regs:
  adr     x2, (printer_buffer + 0x0053)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_1b_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_1b_setup_regs:
  mov     x1, 0x1b
  ret

cl_set_printer_1b_effects:
  _strb   0x1b, P_POSN_X
  _str    (printer_buffer + 0x0052), PR_CC
  ret

cl_set_printer_1b_effects_regs:
  adr     x2, (printer_buffer + 0x0052)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_1c_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_1c_setup_regs:
  mov     x1, 0x1c
  ret

cl_set_printer_1c_effects:
  _strb   0x1c, P_POSN_X
  _str    (printer_buffer + 0x0051), PR_CC
  ret

cl_set_printer_1c_effects_regs:
  adr     x2, (printer_buffer + 0x0051)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_1d_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_1d_setup_regs:
  mov     x1, 0x1d
  ret

cl_set_printer_1d_effects:
  _strb   0x1d, P_POSN_X
  _str    (printer_buffer + 0x0050), PR_CC
  ret

cl_set_printer_1d_effects_regs:
  adr     x2, (printer_buffer + 0x0050)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_1e_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_1e_setup_regs:
  mov     x1, 0x1e
  ret

cl_set_printer_1e_effects:
  _strb   0x1e, P_POSN_X
  _str    (printer_buffer + 0x004f), PR_CC
  ret

cl_set_printer_1e_effects_regs:
  adr     x2, (printer_buffer + 0x004f)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_1f_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_1f_setup_regs:
  mov     x1, 0x1f
  ret

cl_set_printer_1f_effects:
  _strb   0x1f, P_POSN_X
  _str    (printer_buffer + 0x004e), PR_CC
  ret

cl_set_printer_1f_effects_regs:
  adr     x2, (printer_buffer + 0x004e)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_20_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_20_setup_regs:
  mov     x1, 0x20
  ret

cl_set_printer_20_effects:
  _strb   0x20, P_POSN_X
  _str    (printer_buffer + 0x004d), PR_CC
  ret

cl_set_printer_20_effects_regs:
  adr     x2, (printer_buffer + 0x004d)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_21_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_21_setup_regs:
  mov     x1, 0x21
  ret

cl_set_printer_21_effects:
  _strb   0x21, P_POSN_X
  _str    (printer_buffer + 0x004c), PR_CC
  ret

cl_set_printer_21_effects_regs:
  adr     x2, (printer_buffer + 0x004c)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_22_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_22_setup_regs:
  mov     x1, 0x22
  ret

cl_set_printer_22_effects:
  _strb   0x22, P_POSN_X
  _str    (printer_buffer + 0x004b), PR_CC
  ret

cl_set_printer_22_effects_regs:
  adr     x2, (printer_buffer + 0x004b)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_23_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_23_setup_regs:
  mov     x1, 0x23
  ret

cl_set_printer_23_effects:
  _strb   0x23, P_POSN_X
  _str    (printer_buffer + 0x004a), PR_CC
  ret

cl_set_printer_23_effects_regs:
  adr     x2, (printer_buffer + 0x004a)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_24_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_24_setup_regs:
  mov     x1, 0x24
  ret

cl_set_printer_24_effects:
  _strb   0x24, P_POSN_X
  _str    (printer_buffer + 0x0049), PR_CC
  ret

cl_set_printer_24_effects_regs:
  adr     x2, (printer_buffer + 0x0049)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_25_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_25_setup_regs:
  mov     x1, 0x25
  ret

cl_set_printer_25_effects:
  _strb   0x25, P_POSN_X
  _str    (printer_buffer + 0x0048), PR_CC
  ret

cl_set_printer_25_effects_regs:
  adr     x2, (printer_buffer + 0x0048)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_26_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_26_setup_regs:
  mov     x1, 0x26
  ret

cl_set_printer_26_effects:
  _strb   0x26, P_POSN_X
  _str    (printer_buffer + 0x0047), PR_CC
  ret

cl_set_printer_26_effects_regs:
  adr     x2, (printer_buffer + 0x0047)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_27_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_27_setup_regs:
  mov     x1, 0x27
  ret

cl_set_printer_27_effects:
  _strb   0x27, P_POSN_X
  _str    (printer_buffer + 0x0046), PR_CC
  ret

cl_set_printer_27_effects_regs:
  adr     x2, (printer_buffer + 0x0046)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_28_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_28_setup_regs:
  mov     x1, 0x28
  ret

cl_set_printer_28_effects:
  _strb   0x28, P_POSN_X
  _str    (printer_buffer + 0x0045), PR_CC
  ret

cl_set_printer_28_effects_regs:
  adr     x2, (printer_buffer + 0x0045)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_29_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_29_setup_regs:
  mov     x1, 0x29
  ret

cl_set_printer_29_effects:
  _strb   0x29, P_POSN_X
  _str    (printer_buffer + 0x0044), PR_CC
  ret

cl_set_printer_29_effects_regs:
  adr     x2, (printer_buffer + 0x0044)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_2a_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_2a_setup_regs:
  mov     x1, 0x2a
  ret

cl_set_printer_2a_effects:
  _strb   0x2a, P_POSN_X
  _str    (printer_buffer + 0x0043), PR_CC
  ret

cl_set_printer_2a_effects_regs:
  adr     x2, (printer_buffer + 0x0043)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_2b_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_2b_setup_regs:
  mov     x1, 0x2b
  ret

cl_set_printer_2b_effects:
  _strb   0x2b, P_POSN_X
  _str    (printer_buffer + 0x0042), PR_CC
  ret

cl_set_printer_2b_effects_regs:
  adr     x2, (printer_buffer + 0x0042)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_2c_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_2c_setup_regs:
  mov     x1, 0x2c
  ret

cl_set_printer_2c_effects:
  _strb   0x2c, P_POSN_X
  _str    (printer_buffer + 0x0041), PR_CC
  ret

cl_set_printer_2c_effects_regs:
  adr     x2, (printer_buffer + 0x0041)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_2d_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_2d_setup_regs:
  mov     x1, 0x2d
  ret

cl_set_printer_2d_effects:
  _strb   0x2d, P_POSN_X
  _str    (printer_buffer + 0x0040), PR_CC
  ret

cl_set_printer_2d_effects_regs:
  adr     x2, (printer_buffer + 0x0040)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_2e_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_2e_setup_regs:
  mov     x1, 0x2e
  ret

cl_set_printer_2e_effects:
  _strb   0x2e, P_POSN_X
  _str    (printer_buffer + 0x003f), PR_CC
  ret

cl_set_printer_2e_effects_regs:
  adr     x2, (printer_buffer + 0x003f)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_2f_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_2f_setup_regs:
  mov     x1, 0x2f
  ret

cl_set_printer_2f_effects:
  _strb   0x2f, P_POSN_X
  _str    (printer_buffer + 0x003e), PR_CC
  ret

cl_set_printer_2f_effects_regs:
  adr     x2, (printer_buffer + 0x003e)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_30_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_30_setup_regs:
  mov     x1, 0x30
  ret

cl_set_printer_30_effects:
  _strb   0x30, P_POSN_X
  _str    (printer_buffer + 0x003d), PR_CC
  ret

cl_set_printer_30_effects_regs:
  adr     x2, (printer_buffer + 0x003d)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_31_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_31_setup_regs:
  mov     x1, 0x31
  ret

cl_set_printer_31_effects:
  _strb   0x31, P_POSN_X
  _str    (printer_buffer + 0x003c), PR_CC
  ret

cl_set_printer_31_effects_regs:
  adr     x2, (printer_buffer + 0x003c)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_32_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_32_setup_regs:
  mov     x1, 0x32
  ret

cl_set_printer_32_effects:
  _strb   0x32, P_POSN_X
  _str    (printer_buffer + 0x003b), PR_CC
  ret

cl_set_printer_32_effects_regs:
  adr     x2, (printer_buffer + 0x003b)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_33_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_33_setup_regs:
  mov     x1, 0x33
  ret

cl_set_printer_33_effects:
  _strb   0x33, P_POSN_X
  _str    (printer_buffer + 0x003a), PR_CC
  ret

cl_set_printer_33_effects_regs:
  adr     x2, (printer_buffer + 0x003a)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_34_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_34_setup_regs:
  mov     x1, 0x34
  ret

cl_set_printer_34_effects:
  _strb   0x34, P_POSN_X
  _str    (printer_buffer + 0x0039), PR_CC
  ret

cl_set_printer_34_effects_regs:
  adr     x2, (printer_buffer + 0x0039)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_35_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_35_setup_regs:
  mov     x1, 0x35
  ret

cl_set_printer_35_effects:
  _strb   0x35, P_POSN_X
  _str    (printer_buffer + 0x0038), PR_CC
  ret

cl_set_printer_35_effects_regs:
  adr     x2, (printer_buffer + 0x0038)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_36_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_36_setup_regs:
  mov     x1, 0x36
  ret

cl_set_printer_36_effects:
  _strb   0x36, P_POSN_X
  _str    (printer_buffer + 0x0037), PR_CC
  ret

cl_set_printer_36_effects_regs:
  adr     x2, (printer_buffer + 0x0037)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_37_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_37_setup_regs:
  mov     x1, 0x37
  ret

cl_set_printer_37_effects:
  _strb   0x37, P_POSN_X
  _str    (printer_buffer + 0x0036), PR_CC
  ret

cl_set_printer_37_effects_regs:
  adr     x2, (printer_buffer + 0x0036)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_38_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_38_setup_regs:
  mov     x1, 0x38
  ret

cl_set_printer_38_effects:
  _strb   0x38, P_POSN_X
  _str    (printer_buffer + 0x0035), PR_CC
  ret

cl_set_printer_38_effects_regs:
  adr     x2, (printer_buffer + 0x0035)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_39_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_39_setup_regs:
  mov     x1, 0x39
  ret

cl_set_printer_39_effects:
  _strb   0x39, P_POSN_X
  _str    (printer_buffer + 0x0034), PR_CC
  ret

cl_set_printer_39_effects_regs:
  adr     x2, (printer_buffer + 0x0034)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_3a_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_3a_setup_regs:
  mov     x1, 0x3a
  ret

cl_set_printer_3a_effects:
  _strb   0x3a, P_POSN_X
  _str    (printer_buffer + 0x0033), PR_CC
  ret

cl_set_printer_3a_effects_regs:
  adr     x2, (printer_buffer + 0x0033)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_3b_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_3b_setup_regs:
  mov     x1, 0x3b
  ret

cl_set_printer_3b_effects:
  _strb   0x3b, P_POSN_X
  _str    (printer_buffer + 0x0032), PR_CC
  ret

cl_set_printer_3b_effects_regs:
  adr     x2, (printer_buffer + 0x0032)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_3c_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_3c_setup_regs:
  mov     x1, 0x3c
  ret

cl_set_printer_3c_effects:
  _strb   0x3c, P_POSN_X
  _str    (printer_buffer + 0x0031), PR_CC
  ret

cl_set_printer_3c_effects_regs:
  adr     x2, (printer_buffer + 0x0031)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_3d_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_3d_setup_regs:
  mov     x1, 0x3d
  ret

cl_set_printer_3d_effects:
  _strb   0x3d, P_POSN_X
  _str    (printer_buffer + 0x0030), PR_CC
  ret

cl_set_printer_3d_effects_regs:
  adr     x2, (printer_buffer + 0x0030)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_3e_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_3e_setup_regs:
  mov     x1, 0x3e
  ret

cl_set_printer_3e_effects:
  _strb   0x3e, P_POSN_X
  _str    (printer_buffer + 0x002f), PR_CC
  ret

cl_set_printer_3e_effects_regs:
  adr     x2, (printer_buffer + 0x002f)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_3f_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_3f_setup_regs:
  mov     x1, 0x3f
  ret

cl_set_printer_3f_effects:
  _strb   0x3f, P_POSN_X
  _str    (printer_buffer + 0x002e), PR_CC
  ret

cl_set_printer_3f_effects_regs:
  adr     x2, (printer_buffer + 0x002e)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_40_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_40_setup_regs:
  mov     x1, 0x40
  ret

cl_set_printer_40_effects:
  _strb   0x40, P_POSN_X
  _str    (printer_buffer + 0x002d), PR_CC
  ret

cl_set_printer_40_effects_regs:
  adr     x2, (printer_buffer + 0x002d)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_41_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_41_setup_regs:
  mov     x1, 0x41
  ret

cl_set_printer_41_effects:
  _strb   0x41, P_POSN_X
  _str    (printer_buffer + 0x002c), PR_CC
  ret

cl_set_printer_41_effects_regs:
  adr     x2, (printer_buffer + 0x002c)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_42_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_42_setup_regs:
  mov     x1, 0x42
  ret

cl_set_printer_42_effects:
  _strb   0x42, P_POSN_X
  _str    (printer_buffer + 0x002b), PR_CC
  ret

cl_set_printer_42_effects_regs:
  adr     x2, (printer_buffer + 0x002b)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_43_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_43_setup_regs:
  mov     x1, 0x43
  ret

cl_set_printer_43_effects:
  _strb   0x43, P_POSN_X
  _str    (printer_buffer + 0x002a), PR_CC
  ret

cl_set_printer_43_effects_regs:
  adr     x2, (printer_buffer + 0x002a)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_44_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_44_setup_regs:
  mov     x1, 0x44
  ret

cl_set_printer_44_effects:
  _strb   0x44, P_POSN_X
  _str    (printer_buffer + 0x0029), PR_CC
  ret

cl_set_printer_44_effects_regs:
  adr     x2, (printer_buffer + 0x0029)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_45_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_45_setup_regs:
  mov     x1, 0x45
  ret

cl_set_printer_45_effects:
  _strb   0x45, P_POSN_X
  _str    (printer_buffer + 0x0028), PR_CC
  ret

cl_set_printer_45_effects_regs:
  adr     x2, (printer_buffer + 0x0028)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_46_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_46_setup_regs:
  mov     x1, 0x46
  ret

cl_set_printer_46_effects:
  _strb   0x46, P_POSN_X
  _str    (printer_buffer + 0x0027), PR_CC
  ret

cl_set_printer_46_effects_regs:
  adr     x2, (printer_buffer + 0x0027)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_47_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_47_setup_regs:
  mov     x1, 0x47
  ret

cl_set_printer_47_effects:
  _strb   0x47, P_POSN_X
  _str    (printer_buffer + 0x0026), PR_CC
  ret

cl_set_printer_47_effects_regs:
  adr     x2, (printer_buffer + 0x0026)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_48_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_48_setup_regs:
  mov     x1, 0x48
  ret

cl_set_printer_48_effects:
  _strb   0x48, P_POSN_X
  _str    (printer_buffer + 0x0025), PR_CC
  ret

cl_set_printer_48_effects_regs:
  adr     x2, (printer_buffer + 0x0025)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_49_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_49_setup_regs:
  mov     x1, 0x49
  ret

cl_set_printer_49_effects:
  _strb   0x49, P_POSN_X
  _str    (printer_buffer + 0x0024), PR_CC
  ret

cl_set_printer_49_effects_regs:
  adr     x2, (printer_buffer + 0x0024)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_4a_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_4a_setup_regs:
  mov     x1, 0x4a
  ret

cl_set_printer_4a_effects:
  _strb   0x4a, P_POSN_X
  _str    (printer_buffer + 0x0023), PR_CC
  ret

cl_set_printer_4a_effects_regs:
  adr     x2, (printer_buffer + 0x0023)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_4b_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_4b_setup_regs:
  mov     x1, 0x4b
  ret

cl_set_printer_4b_effects:
  _strb   0x4b, P_POSN_X
  _str    (printer_buffer + 0x0022), PR_CC
  ret

cl_set_printer_4b_effects_regs:
  adr     x2, (printer_buffer + 0x0022)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_4c_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_4c_setup_regs:
  mov     x1, 0x4c
  ret

cl_set_printer_4c_effects:
  _strb   0x4c, P_POSN_X
  _str    (printer_buffer + 0x0021), PR_CC
  ret

cl_set_printer_4c_effects_regs:
  adr     x2, (printer_buffer + 0x0021)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_4d_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_4d_setup_regs:
  mov     x1, 0x4d
  ret

cl_set_printer_4d_effects:
  _strb   0x4d, P_POSN_X
  _str    (printer_buffer + 0x0020), PR_CC
  ret

cl_set_printer_4d_effects_regs:
  adr     x2, (printer_buffer + 0x0020)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_4e_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_4e_setup_regs:
  mov     x1, 0x4e
  ret

cl_set_printer_4e_effects:
  _strb   0x4e, P_POSN_X
  _str    (printer_buffer + 0x001f), PR_CC
  ret

cl_set_printer_4e_effects_regs:
  adr     x2, (printer_buffer + 0x001f)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_4f_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_4f_setup_regs:
  mov     x1, 0x4f
  ret

cl_set_printer_4f_effects:
  _strb   0x4f, P_POSN_X
  _str    (printer_buffer + 0x001e), PR_CC
  ret

cl_set_printer_4f_effects_regs:
  adr     x2, (printer_buffer + 0x001e)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_50_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_50_setup_regs:
  mov     x1, 0x50
  ret

cl_set_printer_50_effects:
  _strb   0x50, P_POSN_X
  _str    (printer_buffer + 0x001d), PR_CC
  ret

cl_set_printer_50_effects_regs:
  adr     x2, (printer_buffer + 0x001d)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_51_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_51_setup_regs:
  mov     x1, 0x51
  ret

cl_set_printer_51_effects:
  _strb   0x51, P_POSN_X
  _str    (printer_buffer + 0x001c), PR_CC
  ret

cl_set_printer_51_effects_regs:
  adr     x2, (printer_buffer + 0x001c)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_52_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_52_setup_regs:
  mov     x1, 0x52
  ret

cl_set_printer_52_effects:
  _strb   0x52, P_POSN_X
  _str    (printer_buffer + 0x001b), PR_CC
  ret

cl_set_printer_52_effects_regs:
  adr     x2, (printer_buffer + 0x001b)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_53_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_53_setup_regs:
  mov     x1, 0x53
  ret

cl_set_printer_53_effects:
  _strb   0x53, P_POSN_X
  _str    (printer_buffer + 0x001a), PR_CC
  ret

cl_set_printer_53_effects_regs:
  adr     x2, (printer_buffer + 0x001a)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_54_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_54_setup_regs:
  mov     x1, 0x54
  ret

cl_set_printer_54_effects:
  _strb   0x54, P_POSN_X
  _str    (printer_buffer + 0x0019), PR_CC
  ret

cl_set_printer_54_effects_regs:
  adr     x2, (printer_buffer + 0x0019)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_55_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_55_setup_regs:
  mov     x1, 0x55
  ret

cl_set_printer_55_effects:
  _strb   0x55, P_POSN_X
  _str    (printer_buffer + 0x0018), PR_CC
  ret

cl_set_printer_55_effects_regs:
  adr     x2, (printer_buffer + 0x0018)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_56_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_56_setup_regs:
  mov     x1, 0x56
  ret

cl_set_printer_56_effects:
  _strb   0x56, P_POSN_X
  _str    (printer_buffer + 0x0017), PR_CC
  ret

cl_set_printer_56_effects_regs:
  adr     x2, (printer_buffer + 0x0017)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_57_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_57_setup_regs:
  mov     x1, 0x57
  ret

cl_set_printer_57_effects:
  _strb   0x57, P_POSN_X
  _str    (printer_buffer + 0x0016), PR_CC
  ret

cl_set_printer_57_effects_regs:
  adr     x2, (printer_buffer + 0x0016)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_58_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_58_setup_regs:
  mov     x1, 0x58
  ret

cl_set_printer_58_effects:
  _strb   0x58, P_POSN_X
  _str    (printer_buffer + 0x0015), PR_CC
  ret

cl_set_printer_58_effects_regs:
  adr     x2, (printer_buffer + 0x0015)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_59_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_59_setup_regs:
  mov     x1, 0x59
  ret

cl_set_printer_59_effects:
  _strb   0x59, P_POSN_X
  _str    (printer_buffer + 0x0014), PR_CC
  ret

cl_set_printer_59_effects_regs:
  adr     x2, (printer_buffer + 0x0014)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_5a_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_5a_setup_regs:
  mov     x1, 0x5a
  ret

cl_set_printer_5a_effects:
  _strb   0x5a, P_POSN_X
  _str    (printer_buffer + 0x0013), PR_CC
  ret

cl_set_printer_5a_effects_regs:
  adr     x2, (printer_buffer + 0x0013)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_5b_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_5b_setup_regs:
  mov     x1, 0x5b
  ret

cl_set_printer_5b_effects:
  _strb   0x5b, P_POSN_X
  _str    (printer_buffer + 0x0012), PR_CC
  ret

cl_set_printer_5b_effects_regs:
  adr     x2, (printer_buffer + 0x0012)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_5c_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_5c_setup_regs:
  mov     x1, 0x5c
  ret

cl_set_printer_5c_effects:
  _strb   0x5c, P_POSN_X
  _str    (printer_buffer + 0x0011), PR_CC
  ret

cl_set_printer_5c_effects_regs:
  adr     x2, (printer_buffer + 0x0011)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_5d_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_5d_setup_regs:
  mov     x1, 0x5d
  ret

cl_set_printer_5d_effects:
  _strb   0x5d, P_POSN_X
  _str    (printer_buffer + 0x0010), PR_CC
  ret

cl_set_printer_5d_effects_regs:
  adr     x2, (printer_buffer + 0x0010)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_5e_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_5e_setup_regs:
  mov     x1, 0x5e
  ret

cl_set_printer_5e_effects:
  _strb   0x5e, P_POSN_X
  _str    (printer_buffer + 0x000f), PR_CC
  ret

cl_set_printer_5e_effects_regs:
  adr     x2, (printer_buffer + 0x000f)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_5f_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_5f_setup_regs:
  mov     x1, 0x5f
  ret

cl_set_printer_5f_effects:
  _strb   0x5f, P_POSN_X
  _str    (printer_buffer + 0x000e), PR_CC
  ret

cl_set_printer_5f_effects_regs:
  adr     x2, (printer_buffer + 0x000e)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_60_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_60_setup_regs:
  mov     x1, 0x60
  ret

cl_set_printer_60_effects:
  _strb   0x60, P_POSN_X
  _str    (printer_buffer + 0x000d), PR_CC
  ret

cl_set_printer_60_effects_regs:
  adr     x2, (printer_buffer + 0x000d)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_61_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_61_setup_regs:
  mov     x1, 0x61
  ret

cl_set_printer_61_effects:
  _strb   0x61, P_POSN_X
  _str    (printer_buffer + 0x000c), PR_CC
  ret

cl_set_printer_61_effects_regs:
  adr     x2, (printer_buffer + 0x000c)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_62_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_62_setup_regs:
  mov     x1, 0x62
  ret

cl_set_printer_62_effects:
  _strb   0x62, P_POSN_X
  _str    (printer_buffer + 0x000b), PR_CC
  ret

cl_set_printer_62_effects_regs:
  adr     x2, (printer_buffer + 0x000b)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_63_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_63_setup_regs:
  mov     x1, 0x63
  ret

cl_set_printer_63_effects:
  _strb   0x63, P_POSN_X
  _str    (printer_buffer + 0x000a), PR_CC
  ret

cl_set_printer_63_effects_regs:
  adr     x2, (printer_buffer + 0x000a)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_64_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_64_setup_regs:
  mov     x1, 0x64
  ret

cl_set_printer_64_effects:
  _strb   0x64, P_POSN_X
  _str    (printer_buffer + 0x0009), PR_CC
  ret

cl_set_printer_64_effects_regs:
  adr     x2, (printer_buffer + 0x0009)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_65_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_65_setup_regs:
  mov     x1, 0x65
  ret

cl_set_printer_65_effects:
  _strb   0x65, P_POSN_X
  _str    (printer_buffer + 0x0008), PR_CC
  ret

cl_set_printer_65_effects_regs:
  adr     x2, (printer_buffer + 0x0008)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_66_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_66_setup_regs:
  mov     x1, 0x66
  ret

cl_set_printer_66_effects:
  _strb   0x66, P_POSN_X
  _str    (printer_buffer + 0x0007), PR_CC
  ret

cl_set_printer_66_effects_regs:
  adr     x2, (printer_buffer + 0x0007)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_67_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_67_setup_regs:
  mov     x1, 0x67
  ret

cl_set_printer_67_effects:
  _strb   0x67, P_POSN_X
  _str    (printer_buffer + 0x0006), PR_CC
  ret

cl_set_printer_67_effects_regs:
  adr     x2, (printer_buffer + 0x0006)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_68_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_68_setup_regs:
  mov     x1, 0x68
  ret

cl_set_printer_68_effects:
  _strb   0x68, P_POSN_X
  _str    (printer_buffer + 0x0005), PR_CC
  ret

cl_set_printer_68_effects_regs:
  adr     x2, (printer_buffer + 0x0005)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_69_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_69_setup_regs:
  mov     x1, 0x69
  ret

cl_set_printer_69_effects:
  _strb   0x69, P_POSN_X
  _str    (printer_buffer + 0x0004), PR_CC
  ret

cl_set_printer_69_effects_regs:
  adr     x2, (printer_buffer + 0x0004)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_6a_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_6a_setup_regs:
  mov     x1, 0x6a
  ret

cl_set_printer_6a_effects:
  _strb   0x6a, P_POSN_X
  _str    (printer_buffer + 0x0003), PR_CC
  ret

cl_set_printer_6a_effects_regs:
  adr     x2, (printer_buffer + 0x0003)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_6b_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_6b_setup_regs:
  mov     x1, 0x6b
  ret

cl_set_printer_6b_effects:
  _strb   0x6b, P_POSN_X
  _str    (printer_buffer + 0x0002), PR_CC
  ret

cl_set_printer_6b_effects_regs:
  adr     x2, (printer_buffer + 0x0002)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_6c_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_6c_setup_regs:
  mov     x1, 0x6c
  ret

cl_set_printer_6c_effects:
  _strb   0x6c, P_POSN_X
  _str    (printer_buffer + 0x0001), PR_CC
  ret

cl_set_printer_6c_effects_regs:
  adr     x2, (printer_buffer + 0x0001)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


cl_set_printer_6d_setup:
  _setbit 1, FLAGS
  ret

cl_set_printer_6d_setup_regs:
  mov     x1, 0x6d
  ret

cl_set_printer_6d_effects:
  _strb   0x6d, P_POSN_X
  _str    (printer_buffer + 0x0000), PR_CC
  ret

cl_set_printer_6d_effects_regs:
  adr     x2, (printer_buffer + 0x0000)
  ldrb    w3, [x28, FLAGS-sysvars]
  ret
