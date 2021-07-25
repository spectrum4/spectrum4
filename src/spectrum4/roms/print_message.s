.text
.align 2
# Print zero byte delimited string stored at memory location x0 to current channel.
# On entry:
#   x0 = address of zero byte delimited string
print_message:                           // L057D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  mov     x19, x0
  b       2f
1:
  mov     w0, w1
  bl      print_w0
2:
  ldrb    w1, [x19], #1
  cbnz    w1, 1b
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
