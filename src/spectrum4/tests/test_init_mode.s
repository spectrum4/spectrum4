# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "init_cursor.s"
  .include "mode_l.s"
  .include "print_w0.s"
  .include "reset_cursor.s"
  .include "reset_indentation.s"
  .include "reset_main_screen.s"
.endif

.text
.align 2


init_mode_1_setup:
  _strb   0x00, FLAGS
  _strb   0x00, FLAGS3
  _strb   0x00, TV_FLAG
  ret

init_mode_1_effects:
  _strb   0x82, EC0D
  _strb   0x14, EC15
  _strb   0x00, F6EE
  _strb   0x00, F6EF
  _strb   0x00, F6F0
  _strb   0x04, F6F1
  _strb   0x10, F6F2
  _strb   0x14, F6F3
  _strh   0x0000, FC9A
  _strb   0x01, FD6A
  _strb   0x05, FD6B
  _strb   0x00, FD6C
  _strb   0x00, FD6D
  _strb   0x14, FD6E
  _strb   0x00, FD6F
  _strb   0x00, FD70
  _strb   0x00, FD71
  _strb   0x0F, FD72
  _strb   0x00, FD73
  _strb   0x00, FLAGS3
  _strb   0x02, REPPER
  _strb   0x0C, FLAGS
  _strb   0x00, TV_FLAG
  _strb   0x00, MODE
  _strh   0x0000, E_PPC
  ret

init_mode_1_effects_regs:
  mov     w0, 0x02
  mov     w1, 0x0c
  mov     w2, 0x82
  mov     w3, 0x00
  ret


init_mode_2_setup:
  _strb   0xff, FLAGS
  _strb   0xff, FLAGS3
  _strb   0xff, TV_FLAG
  ret

init_mode_2_effects:
  _strb   0x82, EC0D
  _strb   0x14, EC15
  _strb   0x00, F6EE
  _strb   0x00, F6EF
  _strb   0x00, F6F0
  _strb   0x04, F6F1
  _strb   0x10, F6F2
  _strb   0x14, F6F3
  _strh   0x0000, FC9A
  _strb   0x01, FD6A
  _strb   0x05, FD6B
  _strb   0x00, FD6C
  _strb   0x00, FD6D
  _strb   0x14, FD6E
  _strb   0x00, FD6F
  _strb   0x00, FD70
  _strb   0x00, FD71
  _strb   0x0F, FD72
  _strb   0x00, FD73
  _strb   0xFE, FLAGS3
  _strb   0x02, REPPER
  _strb   0xFF, FLAGS
  _strb   0xFE, TV_FLAG
  _strb   0x00, MODE
  _strh   0x0000, E_PPC
  ret

init_mode_2_effects_regs:
  mov     w0, 0x02
  mov     w1, 0xff
  mov     w2, 0x82
  mov     w3, 0xfe
  ret
