# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
# -----------------------
# Control character table
# -----------------------
# For control characters in the range 6 - 23 the following table
# is indexed to provide an offset to the handling routine that
# follows the table.
.align 3
ctlchrtab:                               // L0A11
  .quad po_comma                                  // chr 0x06
  .quad po_quest                                  // chr 0x07
  .quad po_back                                   // chr 0x08
  .quad po_right                                  // chr 0x09
  .quad po_quest                                  // chr 0x0a
  .quad po_quest                                  // chr 0x0b
  .quad po_quest                                  // chr 0x0c
  .quad po_enter                                  // chr 0x0d
  .quad po_quest                                  // chr 0x0e
  .quad po_quest                                  // chr 0x0f
  .quad po_1_oper                                 // chr 0x10 -> INK
  .quad po_1_oper                                 // chr 0x11 -> PAPER
  .quad po_1_oper                                 // chr 0x12 -> FLASH
  .quad po_1_oper                                 // chr 0x13 -> BRIGHT
  .quad po_1_oper                                 // chr 0x14 -> INVERSE
  .quad po_1_oper                                 // chr 0x15 -> OVER
  .quad po_2_oper                                 // chr 0x16 -> AT
  .quad po_2_oper                                 // chr 0x17 -> TAB (strangely TAB parameter is a two byte integer)
