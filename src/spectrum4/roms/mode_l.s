.text
.align 2
# On entry:
# On exit:
mode_l:                                  // L365E
  strb    wzr, [x28, MODE-sysvars]                // Select 'L' mode ([MODE] = 0).
  mov     w0, #0x2
  strb    w0, [x28, REPPER-sysvars]               // Reset repeat key duration to 2.
mode_l_2:                                // L3668
  ldrb    w1, [x28, FLAGS-sysvars]
  orr     w1, w1, #0x0c
  strb    w1, [x28, FLAGS-sysvars]                // Set bits 2 and 3 of FLAGS (L-Mode and Print in L-Mode).

  ldrb    w2, [x28, EC0D-sysvars]
  ldrb    w3, [x28, FLAGS3-sysvars]
  bfxil   w3, w2, #4, #1                          // Replace bit 0 of FLAGS3 with bit 4 from EC0D (Editor/Menu or BASIC/Caluclator mode).
  strb    w3, [x28, FLAGS3-sysvars]
  ret
