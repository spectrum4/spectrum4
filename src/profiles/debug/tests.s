# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# Generated from the files in the /test directory.

# This file is auto-generated by all.sh. DO NOT EDIT!


.include "test_poke_address.s"
.include "test_display_sysvar.s"
.include "test_cl_addr.s"
.include "test_po_attr.s"
.include "test_po_change.s"
.include "test_po_search.s"


.text
.align 3
all_tests:
  .quad 9                                 // total number of tests
  .quad test_poke_address
  .quad test_display_sysvar
  .quad test_cl_addr
  .quad test_po_attr
  .quad test_po_change
  .quad test_po_search


.align 3
test_poke_address:
  .quad 3
  .quad poke_address
  .quad poke_address_1
  .quad poke_address_2
  .quad poke_address_3


.align 3
poke_address_1:
  .quad poke_address_1_setup
  .quad poke_address_1_setup_regs
  .quad poke_address_1_effects
  .quad poke_address_1_effects_regs
  .asciz "poke_address_1"


.align 3
poke_address_2:
  .quad poke_address_2_setup
  .quad poke_address_2_setup_regs
  .quad poke_address_2_effects
  .quad poke_address_2_effects_regs
  .asciz "poke_address_2"


.align 3
poke_address_3:
  .quad poke_address_3_setup
  .quad poke_address_3_setup_regs
  .quad poke_address_3_effects
  .quad poke_address_3_effects_regs
  .asciz "poke_address_3"


.align 3
test_display_sysvar:
  .quad 1
  .quad display_sysvar
  .quad display_sysvar_1


.align 3
display_sysvar_1:
  .quad display_sysvar_1_setup
  .quad display_sysvar_1_setup_regs
  .quad display_sysvar_1_effects
  .quad display_sysvar_1_effects_regs
  .asciz "display_sysvar_1"


.align 3
test_cl_addr:
  .quad 1                                 // number of cl_addr tests
  .quad cl_addr
  .quad cl_addr_1


.align 3
cl_addr_1:
  .quad 0
  .quad cl_addr_1_setup_regs
  .quad 0
  .quad cl_addr_1_effects_regs
  .asciz "cl_addr_1"


.align 3
test_po_attr:
  .quad 1                                 // number of po_attr tests
  .quad po_attr
  .quad po_attr_1


.align 3
po_attr_1:
  .quad po_attr_1_setup
  .quad po_attr_1_setup_regs
  .quad po_attr_1_effects
  .quad po_attr_1_effects_regs
  .asciz "po_attr_1"


.align 3
test_po_change:
  .quad 1                                 // number of po_change tests
  .quad po_change
  .quad po_change_1


.align 3
po_change_1:
  .quad po_change_1_setup
  .quad po_change_1_setup_regs
  .quad po_change_1_effects
  .quad po_change_1_effects_regs
  .asciz "po_change_1"


.align 3
test_po_search:
  .quad 2                                 // number of po_search tests
  .quad po_search
  .quad po_search_1
  .quad po_search_2


.align 3
po_search_1:
  .quad 0
  .quad po_search_1_setup_regs
  .quad 0
  .quad po_search_1_effects_regs
  .asciz "po_search_1"


.align 3
po_search_2:
  .quad 0
  .quad po_search_2_setup_regs
  .quad 0
  .quad po_search_2_effects_regs
  .asciz "po_search_2"
