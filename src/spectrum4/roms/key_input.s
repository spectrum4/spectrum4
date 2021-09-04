.text
.align 2
# ---------------------
# Handle keyboard input
# ---------------------
# This is the service routine for the input stream of the keyboard
# channel 'K'.
key_input:                               // L10A8
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
