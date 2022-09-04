.text
.align 2
# On entry:
# On exit:
reset_indentation:                       // L35BC
  mov     w0, #0x0501
  strh    w0, [x28, FD6A-sysvars]
  ret
