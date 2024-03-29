# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# ------------------------
# Show Main Menu
# ------------------------
#
# On entry:
# On exit:
main_menu:                               // L259F
  mov     x0, #0x02
  bl      chan_open                               // Printing to main screen
  adr     x19, main_menu_jump_table               // Main menu jump table
  str     x19, [x28, F6EA-sysvars]                // Store as current jump table
  adr     x20, main_menu_text                     // Main menu text
  str     x20, [x28, F6EC-sysvars]                // Store as current menu text
  ldrb    w3, [x28, EC0D-sysvars]                 // Fetch editor flags
  orr     w3, w3, #0x02                           // Indicate 'menu displayed' (bit 1 set)
  and     w3, w3, #0xefefefef                     // Signal return to main menu (bit 4 clear)
  strb    w3, [x28, EC0D-sysvars]                 // Store editor flags
  strb    wzr, [x28, EC0C-sysvars]                // Top menu item selected (menu index=0)
  bl      display_menu                            // Display menu and highlight first item.
  b       wait_key_press                          // Jump ahead to enter the main key waiting and processing loop.

# Main menu jump table
.align 3
main_menu_jump_table:                    // L2744
  .quad 0x05                                      // Number of entries.
  .quad tape_loader                               // Tape Loader option handler.
  .quad basic_128k                                // 128 BASIC option handler.
  .quad calculator                                // Calculator option handler.
  .quad basic_48k                                 // 48 BASIC option handler.
  .quad tape_tester                               // Tape Tester option handler.

# Text for the main 128K menu
.align 0
main_menu_text:                          // L2754
  .asciz "128 +4  "                               // Menu title.
  .asciz "Tape Loader"
  .asciz "+4 BASIC"
  .asciz "Calculator"
  .asciz "48 BASIC"
  .asciz "Tape Tester"
  .asciz ""
