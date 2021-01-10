# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.


.text
.align 2


# This test calls po_search with a custom search table to retrieve the 5th item.


po_search_1_setup_regs:
  mov x3, #0x3                            // x3 = 3
  adr x4, po_search_1_table               // x4 = po_search_1_table
  ret


po_search_1_effects_regs:
  adr x4, po_search_1_telephone           // x4 = po_search_1_telephone
  mov x5, 't'                             // x5 = 't'
  mov x6, #0                              // x6 = 0
  ret


po_search_1_table:
  .asciz "hello"
  .asciz "dog"
  .asciz "cat"
  .asciz "banana"


po_search_1_telephone:
  .asciz "telephone"
  .asciz "supper"


.align 2


# This test calls po_search using the ROM token table to retrieve the 24th token.


po_search_2_setup_regs:
  mov x3, #0x22                           // x3 = 22
  adr x4, tkn_table                       // x4 = tkn_table
  ret


po_search_2_effects_regs:
  adr x4, less_equal                      // x4 = po_search_1_telephone
  mov x5, #0                              // x5 = 0
  mov x6, #0                              // x6 = 0
  ret
