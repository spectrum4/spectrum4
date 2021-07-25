# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# po_search_1 calls po_search with a custom search table to retrieve the 5th item.

po_search_1_setup_regs:
  ld      a, 3
  ld      de, po_search_1_table
  ret

po_search_1_effects_regs:
  ld      de, po_search_1_telephone
  ldf     C_FLAG | N_FLAG | X5_FLAG | S_FLAG
                                          ; 0x03 SUB 0x20 = 0x3e = 0b11100011
  ret                                     ;                            5 3

po_search_1_table:
  .ascii "hell"
  .byte 'o'+$80
  .ascii "do"
  .byte 'g'+$80
  .ascii "ca"
  .byte 't'+$80
  .ascii "banan"
  .byte 'a'+$80
po_search_1_telephone:
  .ascii "telephon"
  .byte 'e'+$80
  .ascii "suppe"
  .byte 'r'+$80


# po_search_2 tests case A >= 0x20 && first char < 'A'

po_search_2_setup_regs:
  ld      a, 0x22
  ld      de, tkn_table
  ret

po_search_2_effects_regs:
  ld      a, '<' - 'A'
  ld      de, tkn_less_equal
  ldf     C_FLAG | N_FLAG | X3_FLAG | X5_FLAG | S_FLAG
                                          ; '<' SUB 'A' = 0x3c SUB 0x41 = 0xfb = 0b11111011
  ret                                     ;                                          5 3


# po_search_3 tests case A >= 0x20 and first char > 'A'

po_search_3_setup_regs:
  ld      a, 0x20
  ld      de, tkn_table
  ret

po_search_3_effects_regs:
  ld      a, 'O' - 'A'
  ld      de, tkn_or
  ldf     N_FLAG | X3_FLAG                ; 'O' SUB 'A' = 0x4f SUB 0x41 = 0x0e = 0b00001110
  ret                                     ;                                          5 3


# po_search_4 tests retrieving very last entry in table

po_search_4_setup_regs:
  ld      a, 0x5a
  ld      de, tkn_table
  ret

po_search_4_effects_regs:
  ld      a, 'C' - 'A'
  ld      de, tkn_copy
  ldf     N_FLAG                          ; 'C' SUB 'A' = 0x43 SUB 0x41 = 0x02 = 0b00000010
  ret                                     ;                                          5 3


# po_search_5 tests retreiving first entry (excluding step-over token, of course)

po_search_5_setup_regs:
  ld      a, 0x0
  ld      de, tkn_table
  ret

po_search_5_effects_regs:
  ld      de, tkn_rnd
  ldf     C_FLAG | N_FLAG | X5_FLAG | S_FLAG
                                          ; 0x00 SUB 0x20 = 0xe0 = 0b11100000
  ret                                     ;                            5 3


# po_search_6 tests case A >= 0x20 and first char == 'A'

po_search_6_setup_regs:
  ld      a, 0x21
  ld      de, tkn_table
  ret

po_search_6_effects_regs:
  ld      a, 'A' - 'A'
  ld      de, tkn_and
  ldf     N_FLAG | Z_FLAG                 ; 'A' SUB 'A' = 0x00 = 0b00000000
  ret                                     ;                          5 3
