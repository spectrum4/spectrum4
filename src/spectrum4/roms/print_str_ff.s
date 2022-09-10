.text
.align 2

# On entry:
#   x4 = address of string in memory
# On exit:
#   x0
#   ....
print_str_ff:                            // L3733
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
1:
  ldrb    w0, [x4], #1
  cmp     w0, #0xff
  b.eq    2f                                      // char 0xff => end of string, so exit loop
  stp     x7, x4, [sp, #-16]!
  bl      print_w0
  ldp     x7, x4, [sp], #0x10
  b       1b
2:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
