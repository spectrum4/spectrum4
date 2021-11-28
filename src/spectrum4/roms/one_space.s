.text
.align 2
# -----------------------
# Just one space required
# -----------------------
# This routine is called once only to create a single space
# in workspace by ADD-CHAR. It is slightly quicker than using a RST 30H.
# There are several instances in the calculator where the sequence
# ld bc, 1; rst $30 could be replaced by a call to this routine but it
# only gives a saving of one byte each time.
one_space:                               // L1652
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO
  bl      make_room
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
