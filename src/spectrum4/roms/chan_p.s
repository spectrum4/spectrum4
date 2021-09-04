.text
.align 2
# --------------
# Channel P flag
# --------------
# Flag setting routine for printer channel ('P' channel).
#
# On entry:
# On exit:
#   [FLAGS] : sets bit 1 => Printer in use
#   w0 = new [FLAGS]
#   <no other changes>
chan_p:                                  // L164D
  ldrb    w0, [x28, FLAGS-sysvars]
  orr     w0, w0, #2                              // Set bit 1 of FLAGS - signal printer in use.
  strb    w0, [x28, FLAGS-sysvars]
  ret
