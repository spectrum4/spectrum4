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
  // TODO
  ret
