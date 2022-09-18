.text

# ----------------------------
# Print "AT w7, w8" characters
# ----------------------------
#
# On entry:
# On exit:
.align 2
print_at:                                // L372B
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w0, #0x16
  bl      print_w0
  mov     w0, w7
  bl      print_w0
  mov     w0, w8
  bl      print_w0
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
