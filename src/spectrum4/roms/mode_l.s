.text
.align 2
# On entry:
# On exit:
mode_l:                                  // L365E
  strb    wzr, [x28, MODE-sysvars]                // Select 'L' mode.
  mov     w0, #0x2
  strb    w0, [x28, REPPER-sysvars]               // Reset repeat key duration.
mode_l_2:
  ldrb    w1, [x28, FLAGS-sysvars]
  orr     w1, w1, #0x0c
  strb    w1, [x28, FLAGS-sysvars]
  ret
