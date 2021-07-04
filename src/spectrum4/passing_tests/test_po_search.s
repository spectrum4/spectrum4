# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# po_search_1 calls po_search with a custom search table to retrieve the 5th item.

.align 2
po_search_1_setup_regs:
  mov     x3, #0x3
  adr     x4, test_message_table
  ret

po_search_1_effects_regs:
  mov     x0, #0                                  // x0 = first char of result if w3 >= 0x20; otherwise 0
  adr     x4, test_message_telephone              // x4 = address of result
  mov     x6, #0                                  // x6 = 0
  nzcv    #0b1000                                 // since w3 < 0x20
  ret


# po_search_2 tests case w3 >= 0x20 && first char < 'A'

.align 2
po_search_2_setup_regs:
  mov     x3, #0x22
  adr     x4, tkn_table
  ret

po_search_2_effects_regs:
  mov     x0, '<'                                 // x0 = first char of result if w3 >= 0x20; otherwise 0
  adr     x4, tkn_less_equal                      // x4 = address of result
  mov     x6, #0                                  // x6 = 0
  nzcv    #0b1000                                 // since w3 >= 0x20 && first char < 'A'
  ret


# po_search_3 tests case w3 >= 0x20 and first char > 'A'

.align 2
po_search_3_setup_regs:
  mov     x3, #0x20
  adr     x4, tkn_table
  ret

po_search_3_effects_regs:
  mov     x0, 'O'                                 // x0 = first char of result if w3 >= 0x20; otherwise 0
  adr     x4, tkn_or                              // x4 = address of result
  mov     x6, #0                                  // x6 = 0
  nzcv    #0b0010                                 // since w3 >= 0x20 and first char > 'A'
  ret


# po_search_4 tests retrieving very last entry in table

.align 2
po_search_4_setup_regs:
  mov     x3, #0x5a
  adr     x4, tkn_table
  ret

po_search_4_effects_regs:
  mov     x0, 'C'                                 // x0 = first char of result if w3 >= 0x20; otherwise 0
  adr     x4, tkn_copy                            // x4 = address of result
  mov     x6, #0                                  // x6 = 0
  nzcv    #0b0010                                 // since w3 >= 0x20 and first char > 'A'
  ret


# po_search_5 tests retreiving first entry (excluding step-over token, of course)

.align 2
po_search_5_setup_regs:
  mov     x3, #0x0
  adr     x4, tkn_table
  ret

po_search_5_effects_regs:
  mov     x0, #0                                  // x0 = first char of result if w3 >= 0x20; otherwise 0
  adr     x4, tkn_rnd                             // x4 = address of result
  mov     x6, #0                                  // x6 = 0
  nzcv    #0b1000                                 // since w3 < 0x20
  ret


# po_search_6 tests case w3 >= 0x20 and first char == 'A'

.align 2
po_search_6_setup_regs:
  mov     x3, #0x21
  adr     x4, tkn_table
  ret

po_search_6_effects_regs:
  mov     x0, 'A'                                 // x0 = first char of result if w3 >= 0x20; otherwise 0
  adr     x4, tkn_and                             // x4 = address of result
  mov     x6, #0                                  // x6 = 0
  nzcv    #0b0110                                 // since w3 >= 0x20 and first char == 'A'
  ret
