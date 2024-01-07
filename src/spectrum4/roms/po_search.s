# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ------------
# Table search
# ------------
# This subroutine looks up the address of the (w3+2)'th zero-terminated byte
# sequence (message) starting at address x4. If entry w3 < 0x20, or first char
# of message < 'A', carry will be clear (and negative will be set). Otherwise
# carry will be set (and negative will be clear).
#
# On entry:
#   w3 = index:
#          first message cannot be returned
#          0 for second message
#          1 for third message
#          ...
#   x4 = address of message table
# On exit:
#   x0 = if w3 < 0x20:
#          0
#        else:
#          first char of result
#   x4 = address of found message
#   w6 = 0
#   NZCV = if w3 < 0x20:
#            0b1000
#          else if first char == 'A':
#            0b0110
#          else if first char < 'A':
#            0b1000
#          else: (first char > 'A')
#            0b0010
po_search:                               // L0C41
  add     w6, w3, #1                              // Adjust for initial step-over token.
1:
  ldrb    w0, [x4], #1                            // w0 = [w4++]
  cbnz    w0, 1b                                  // Jump back to 1: if not zero
  subs    w6, w6, #1                              // Reduce index counter
  b.ne    1b                                      // Jump back to 1: if index not zero.
  cmp     w3, 0x20                                // Is entry index < 32?
  b.lo    2f                                      // If yes, return with carry clear.
  ldrb    w0, [x4]                                // Otherwise, inspect first char of message.
  cmp     w0, 'A'                                 // If first char < 'A' carry clear; otherwise set.
2:
  ret
