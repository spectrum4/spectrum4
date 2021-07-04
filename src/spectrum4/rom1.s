# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

################################################################################################
# These routines are a translation of the original Z80 ROM 1 routines on the 128K Spectrum.
#
# The translation has been performed using Paul Farrow's 128K ROM 1 disassembly as principal reference:
#   * http://www.fruitcake.plus.com/Sinclair/Spectrum128/ROMDisassembly/Files/Disassemblies/Spectrum128_ROM1.zip
# which in turn is based on Geoff Wearmouth's 48K ROM disassembly (almost identical to 128K ROM 1):
#   * https://web.archive.org/web/20150618024638/http://www.wearmouth.demon.co.uk/zx82.htm
# together with Dr Ian Logan and Dr Frank O'Hara's original 48K ROM disassembly from January 1983:
#   * https://archive.org/details/CompleteSpectrumROMDisassemblyThe/mode/2up
# and Richard Dymond's additions:
#   * https://skoolkit.ca/disassemblies/rom/hex/maps/all.html
#
# In addition, using the fantastic Retro Virtual Machine v2.0 BETA-1 r7 from Juan Carlos Gonzalez Amestoy:
#   * http://www.retrovirtualmachine.org/en/downloads
# it has been possible to run the ROM routines through a debugger, to validate assumptions
# about the behaviour and fine-tine the descriptions.
#
# Note, the original routines have also been intentionally adapted to take advantage of the improved
# hardware of the Raspberry Pi 3B, such as more memory and higher screen resolution. Please see
# the top level README.md document for more information.
################################################################################################


.text
.align 2


# -------------------
# THE 'ERROR' RESTART
# -------------------
#
# On entry:
#   w0 = error number (8 bits)
# On exit:
#   [X_PTR] = [CH_ADD]
#   [ERR_NO] = w0
#   stack pointer = [ERR_SP]
#   ....
#   x9 = [CH_ADD]
error_1:                                 // L0008
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x9, [x28, CH_ADD-sysvars]               // x9 = character address from CH_ADD.
  str     x9, [x28, X_PTR-sysvars]                // Copy it to the error pointer X_PTR.
  strb    w0, [x28, ERR_NR-sysvars]               // Store error number in ERR_NR.
  ldr     x9, [x28, ERR_SP-sysvars]               // ERR_SP points to an error handler on the
  mov     sp, x9                                  // machine stack. There may be a hierarchy
                                                  // of routines.
                                                  // to MAIN-4 initially at base.
                                                  // or REPORT-G on line entry.
                                                  // or  ED-ERROR when editing.
                                                  // or   ED-FULL during ed-enter.
                                                  // or  IN-VAR-1 during runtime input etc.
  // TODO - a lot to implement here, skipping for now as I haven't understood
  // how the stack swapping works yet.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# Print character in lower 8 bits of w0 to current channel.
# Calls function pointer at [[CURCHL]].
#
# On entry:
#   w0 = char to print (lower 8 bits)
#   x28 = sysvars
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x1 = [[CURCHL]]
#   ... any changes that routine at [[CURCHL]] made ...
print_w0:                                // L0010
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x1, [x28, CURCHL-sysvars]               // x1 = [CURCHL]
  ldr     x1, [x1]                                // x1 = [[CURCHL]]
  blr     x1                                      // bl [[CURCHL]]
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ------------------
# THE 'TOKEN TABLES'
# ------------------
# The tokenized characters 165 (RND) to 255 (COPY) are expanded using this
# table. The first token '?' is a step-over token.

tkn_table:                               // L0095
  .asciz    "?"                                   // Step over marker
tkn_rnd:
  .asciz    "RND"                                 // 165 = 0xa5   (0 = 0x00)
  .asciz    "INKEY$"                              // 166 = 0xa6   (1 = 0x01)
  .asciz    "PI"                                  // 167 = 0xa7   (2 = 0x02)
  .asciz    "FN"                                  // 168 = 0xa8   (3 = 0x03)
  .asciz    "POINT"                               // 169 = 0xa9   (4 = 0x04)
  .asciz    "SCREEN$"                             // 170 = 0xaa   (5 = 0x05)
  .asciz    "ATTR"                                // 171 = 0xab   (6 = 0x06)
  .asciz    "AT"                                  // 172 = 0xac   (7 = 0x07)
  .asciz    "TAB"                                 // 173 = 0xad   (8 = 0x08)
  .asciz    "VAL$"                                // 174 = 0xae   (9 = 0x09)
  .asciz    "CODE"                                // 175 = 0xaf  (10 = 0x0a)
  .asciz    "VAL"                                 // 176 = 0xb0  (11 = 0x0b)
  .asciz    "LEN"                                 // 177 = 0xb1  (12 = 0x0c)
  .asciz    "SIN"                                 // 178 = 0xb2  (13 = 0x0d)
  .asciz    "COS"                                 // 179 = 0xb3  (14 = 0x0e)
  .asciz    "TAN"                                 // 180 = 0xb4  (15 = 0x0f)
  .asciz    "ASN"                                 // 181 = 0xb5  (16 = 0x10)
  .asciz    "ACS"                                 // 182 = 0xb6  (17 = 0x11)
  .asciz    "ATN"                                 // 183 = 0xb7  (18 = 0x12)
  .asciz    "LN"                                  // 184 = 0xb8  (19 = 0x13)
  .asciz    "EXP"                                 // 185 = 0xb9  (20 = 0x14)
  .asciz    "INT"                                 // 186 = 0xba  (21 = 0x15)
  .asciz    "SQR"                                 // 187 = 0xbb  (22 = 0x16)
  .asciz    "SGN"                                 // 188 = 0xbc  (23 = 0x17)
  .asciz    "ABS"                                 // 189 = 0xbd  (24 = 0x18)
  .asciz    "PEEK"                                // 190 = 0xbe  (25 = 0x19)
  .asciz    "IN"                                  // 191 = 0xbf  (26 = 0x1a)
  .asciz    "USR"                                 // 192 = 0xc0  (27 = 0x1b)
  .asciz    "STR$"                                // 193 = 0xc1  (28 = 0x1c)
  .asciz    "CHR$"                                // 194 = 0xc2  (29 = 0x1d)
  .asciz    "NOT"                                 // 195 = 0xc3  (30 = 0x1e)
  .asciz    "BIN"                                 // 196 = 0xc4  (31 = 0x1f)
tkn_or:
  .asciz    "OR"                                  // 197 = 0xc5  (32 = 0x20)
tkn_and:
  .asciz    "AND"                                 // 198 = 0xc6  (33 = 0x21)
tkn_less_equal:
  .asciz    "<="                                  // 199 = 0xc7  (34 = 0x22)
  .asciz    ">="                                  // 200 = 0xc8  (35 = 0x23)
  .asciz    "<>"                                  // 201 = 0xc9  (36 = 0x24)
  .asciz    "LINE"                                // 202 = 0xca  (37 = 0x25)
  .asciz    "THEN"                                // 203 = 0xcb  (38 = 0x26)
  .asciz    "TO"                                  // 204 = 0xcc  (39 = 0x27)
  .asciz    "STEP"                                // 205 = 0xcd  (40 = 0x28)
  .asciz    "DEF FN"                              // 206 = 0xce  (41 = 0x29)
  .asciz    "CAT"                                 // 207 = 0xcf  (42 = 0x2a)
  .asciz    "FORMAT"                              // 208 = 0xd0  (43 = 0x2b)
  .asciz    "MOVE"                                // 209 = 0xd1  (44 = 0x2c)
  .asciz    "ERASE"                               // 210 = 0xd2  (45 = 0x2d)
  .asciz    "OPEN #"                              // 211 = 0xd3  (46 = 0x2e)
  .asciz    "CLOSE #"                             // 212 = 0xd4  (47 = 0x2f)
  .asciz    "MERGE"                               // 213 = 0xd5  (48 = 0x30)
  .asciz    "VERIFY"                              // 214 = 0xd6  (49 = 0x31)
  .asciz    "BEEP"                                // 215 = 0xd7  (50 = 0x32)
  .asciz    "CIRCLE"                              // 216 = 0xd8  (51 = 0x33)
  .asciz    "INK"                                 // 217 = 0xd9  (52 = 0x34)
  .asciz    "PAPER"                               // 218 = 0xda  (53 = 0x35)
  .asciz    "FLASH"                               // 219 = 0xdb  (54 = 0x36)
  .asciz    "BRIGHT"                              // 220 = 0xdc  (55 = 0x37)
  .asciz    "INVERSE"                             // 221 = 0xdd  (56 = 0x38)
  .asciz    "OVER"                                // 222 = 0xde  (57 = 0x39)
  .asciz    "OUT"                                 // 223 = 0xdf  (58 = 0x3a)
  .asciz    "LPRINT"                              // 224 = 0xe0  (59 = 0x3b)
  .asciz    "LLIST"                               // 225 = 0xe1  (60 = 0x3c)
  .asciz    "STOP"                                // 226 = 0xe2  (61 = 0x3d)
  .asciz    "READ"                                // 227 = 0xe3  (62 = 0x3e)
  .asciz    "DATA"                                // 228 = 0xe4  (63 = 0x3f)
  .asciz    "RESTORE"                             // 229 = 0xe5  (64 = 0x40)
  .asciz    "NEW"                                 // 230 = 0xe6  (65 = 0x41)
  .asciz    "BORDER"                              // 231 = 0xe7  (66 = 0x42)
  .asciz    "CONTINUE"                            // 232 = 0xe8  (67 = 0x43)
  .asciz    "DIM"                                 // 233 = 0xe9  (68 = 0x44)
  .asciz    "REM"                                 // 234 = 0xea  (69 = 0x45)
  .asciz    "FOR"                                 // 235 = 0xeb  (70 = 0x46)
  .asciz    "GO TO"                               // 236 = 0xec  (71 = 0x47)
  .asciz    "GO SUB"                              // 237 = 0xed  (72 = 0x48)
  .asciz    "INPUT"                               // 238 = 0xee  (73 = 0x49)
  .asciz    "LOAD"                                // 239 = 0xef  (74 = 0x4a)
  .asciz    "LIST"                                // 240 = 0xf0  (75 = 0x4b)
  .asciz    "LET"                                 // 241 = 0xf1  (76 = 0x4c)
  .asciz    "PAUSE"                               // 242 = 0xf2  (77 = 0x4d)
  .asciz    "NEXT"                                // 243 = 0xf3  (78 = 0x4e)
  .asciz    "POKE"                                // 244 = 0xf4  (79 = 0x4f)
  .asciz    "PRINT"                               // 245 = 0xf5  (80 = 0x50)
  .asciz    "PLOT"                                // 246 = 0xf6  (81 = 0x51)
  .asciz    "RUN"                                 // 247 = 0xf7  (82 = 0x52)
  .asciz    "SAVE"                                // 248 = 0xf8  (83 = 0x53)
  .asciz    "RANDOMIZE"                           // 249 = 0xf9  (84 = 0x54)
  .asciz    "IF"                                  // 250 = 0xfa  (85 = 0x55)
  .asciz    "CLS"                                 // 251 = 0xfb  (86 = 0x56)
  .asciz    "DRAW"                                // 252 = 0xfc  (87 = 0x57)
  .asciz    "CLEAR"                               // 253 = 0xfd  (88 = 0x58)
  .asciz    "RETURN"                              // 254 = 0xfe  (89 = 0x59)
tkn_copy:
  .asciz    "COPY"                                // 255 = 0xff  (90 = 0x5a)

.align 2

# Default print routine for channels S/K, to print a single byte.
#
# On entry:
#   w0 = char (1 byte)
# On exit:
#   Depends on function in ctlchrtab
print_out:                               // L09F4
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  mov     x19, x0                                 // Stash x0.
  bl      po_fetch                                // Fetch x0, x1, x2 (print coordinates and address)
  mov     x3, x19                                 // x3 = char to print
  cmp     x3, #0x20                               // Is character a space or higher (directly printable)?
  b.hs    1f                                      // If so, to 1: to print char.
  cmp     x3, #0x06                               // Is character in range 0 - 5?
  b.lo    2f                                      // If so, to 2: to print '?'.
  cmp     x3, #0x18                               // Is character in range 24 - 31?
  b.hs    2f                                      // If so, to 2: to print '?'.
  adr     x4, ctlchrtab-(6*8)                     // x4 = theorectical address of control character table char 0
  add     x4, x4, x3, lsl #3                      // x4 = address of control character routine for char passed in w0
  blr     x4                                      // Call control character routine.
  b       3f                                      // Return from routine.
1:
  // Printable character.
  bl      po_able                                 // Print printable character.
  b       3f                                      // Return from routine.
2:
  // Unassigned control character.
  bl      po_quest                                // Print question mark.
3:
  // Exit routine.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


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


# -------------------
# Cursor left routine
# -------------------
# For screen:
#   If in leftmost column:
#     If on first line:
#       No change
#     Otherwise:
#       To rightmost column of previous line
#   Otherwise:
#     Backspace a char
# For ZX printer:
#   If in leftmost column:
#     No change
#   Otherwise:
#     Backspace a char
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x08 (chr 8)
#
# On exit:
#   If upper screen in use:
#     [S_POSN_Y]
#     [S_POSN_X]
#     [DF_CC]
#   If lower screen in use:
#     [S_POSN_Y_L]
#     [S_POSN_X_L]
#     [ECHO_E_Y]
#     [ECHO_E_X]
#     [DF_CC_L]
#   If printer in use:
#     [P_POSN_X]
#     [PR_CC]
po_back:                                 // L0A23
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w1, w1, #1                              // Move left one column.
  cmp     w1, #110                                // Were we already in leftmost column?
  b.ne    1f                                      // If not, no further changes needed, so skip forward to 1:
                                                  // to update saved cursor position and exit.
  // Started in leftmost column, column number now invalid.
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 2f                              // If printer in use, exit without applying any updates.
  // Started in leftmost column of screen (either channel K or S).
  add     w0, w0, #1                              // Move up one screen line.
  mov     w1, #2                                  // w1 = rightmost column position
  cmp     w0, #61                                 // Were we already on first line of upper/lower screen?
  b.eq    2f                                      // If so, exit without applying any updates.
1:
  // Store updated cursor position.
  bl      cl_set
2:
  // Exit routine.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# --------------------
# Cursor right routine
# --------------------
# This implementation could probably be optimised, and it is questionable
# whether the attributes file should really be updated.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x09 (chr 9)
po_right:                                // L0A3D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  ldrb    w19, [x28, P_FLAG-sysvars]              // Stash current [P_FLAG] in x19 so we can temporarily change it.
  mov     x4, #1                                  // w4 = 1 => 'OVER 1' in [P_FLAG]
  strb    w4, [x28, P_FLAG-sysvars]               // Temporarily set [P_FLAG] to 'OVER 1'
  mov     x0, ' '                                 // x0 = space character (' ')
  bl      po_able                                 // Print it, which updates cursor position and attributes file
                                                  // entry, without altering display file (unless space character
                                                  // has been modified).
  strb    w19, [x28, P_FLAG-sysvars]              // Restore stashed [P_FLAG].
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -----------------------
# Perform carriage return
# -----------------------
# A carriage return is 'printed' to screen or printer buffer.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x0d (chr 13)
po_enter:                                // L0A4F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  mov     w19, w0                                 // Stash argument w0.
  mov     w20, w1                                 // Stash argument w1.
  mov     w21, w2                                 // Stash argument w2.
  mov     w22, w3                                 // Stash argument w3.
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 1f                              // If printer in use, jump forward to 1:.
  mov     w1, #109                                // The leftmost column position.
  // TODO preserve registers that following routine corrupts
  bl      po_scr                                  // Routine po_scr handles any scrolling required.
  sub     w0, w0, #1                              // Down one screen line.
  bl      cl_set                                  // Save new position in system variables.
  b       2f                                      // Exit routine.
1:
  // Flush printer buffer and reset print position.
  bl      copy_buff
2:
  // Exit routine.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -----------
# Print comma
# -----------
# The comma control character. The 108 column screen has six 18 character
# tabstops. The routine is only reached via the control character table.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x06 (chr 6)
po_comma:                                // L0A5F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w1, w1, #16                             // w1 = 125 - column (125 to 18 on screen, 17 for trailing)
  mov     w3, #0xe38f                             // w3 = 58255
  umull   x4, w1, w3                              // x4 = w1 * 58255
  lsr     x4, x4, #20                             // x4 = w1 * 58255 / 1048576 = w1/18
  mov     w5, #18
  mov     x3, #126
  umsubl  x4, w5, w4, x3                          // x4 = x3 - w4*w5 = 126-18*((125-col)/18)
  bl      po_fill                                 // Print spaces until x pos (126-18*(125-col)/18)%108)
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -------------------
# Print question mark
# -------------------
# This routine prints a question mark which is used to print an unassigned
# control character in range 0 to 31.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = unassigned char (0/1/2/3/4/5/7/10/11/12/14/15/24/25/26/27/28/29/30/31)
po_quest:                                // L0A69
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w3, #0x3f                               // Char '?'.
  bl      po_able                                 // Print it.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# --------------------------------
# Control characters with operands
# --------------------------------
# Certain control characters are followed by 1 or 2 operands.
# The entry points from control character table are po_1_oper and po_2_oper.
# The routines alter the output address of the current channel so that
# subsequent RST 10 instructions take the appropriate action
# before finally resetting the output address back to PRINT-OUT.


# On entry:
#   w0 = first byte of 2 byte control code
# On exit:
#   [TVDATA+1] = first byte of 2 byte control code
#   [[CURCHL]] = po_cont
#   x4 = po_cont
#   x5 = [CURCHL]
po_tv_2:                                 // L0A6D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, po_cont                             // po_cont will be next output routine
  strb    w0, [x28, TVDATA+1-sysvars]             // store first operand in TVDATA high byte
  bl      po_change                               // Set current channel output routine to po_cont
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# This initial entry point deals with two operands - AT (0x16) or TAB (0x17).
#
# On entry:
#   w3 = control char (0x16/0x17)
#
# On exit:
#   [TVDATA] = w3[0-7]
#   [[CURCHL]] = po_tv_2
po_2_oper:                               // L0A75
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, po_tv_2
  bl      po_tv_1                                 // Store control character in TVDATA low byte and set
                                                  // current channel output routine to po_tv_2.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# This initial entry point deals with one operand INK to OVER.
#
# On entry:
#   w3 = control char (0x10/0x11/0x12/0x13/0x14/0x15)
#
# On exit:
#   [TVDATA] = w3[0-7]
#   [[CURCHL]] = po_cont
po_1_oper:                               // L0A7A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, po_cont
  bl      po_tv_1                                 // Store control character in TVDATA low byte and set
                                                  // current channel output routine to po_cont.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# Called with the single operand for single byte parameter control codes, or
# second operand for two byte parameter control codes.
#
# Stores control char in [TVDATA] low byte, and updates current channel output
# routine to address passed in in x4.
#
# On entry:
#   w3 = control char (16/17/18/19/20/21/22/23)
#   x4 = function pointer for handling 1 or 2 control chars (po_cont or po_tv_2)
# On exit:
#   [TVDATA] = w3[0-7]
#   [[CURCHL]] = x4
#   x5 = [CURCHL]
po_tv_1:                                 // L0A7D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  strb    w3, [x28, TVDATA-sysvars]               // Store control code character in TVDATA low byte
  bl      po_change                               // Set current channel output routine to passed in output routine.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -------------------------------------
# Update Current Channel Output Routine
# -------------------------------------
#
# On entry:
#   x4 = function pointer for handling 1 or 2 control chars (po_cont or po_tv_2)
# On exit:
#   [[CURCHL]] = x4
#   x5 = [CURCHL]
po_change:                               // L0A80
  ldr     x5, [x28, CURCHL-sysvars]               // x5 = [CURCHL]
  str     x4, [x5]                                // Set current channel output routine
  ret


# On entry:
#   w0 = first byte of 1 byte control code or second byte of 2 byte control code
po_cont:                                 // L0A87
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, print_out
  bl      po_change                               // Set current channel output routine to print_out.
  ldrb    w5, [x28, TVDATA-sysvars]               // w5[0-7] = control char
                                                  // w5[8-15] = first byte of 2 byte control code, if 2 byte
  lsr     w6, w5, #8                              // w6 = first byte of 2 byte control code, if 2 byte
  and     w5, w5, #0xff                           // w5 = control char
  cmp     w5, 0x16                                // control code INK to OVER (1 operand)?
  b.lo    to_co_temp_5                            // If so, jump forward to ........
  b.ne    po_tab                                  // If control char > 0x16 (=> 0x17 = TAB) jump forward to ..........
  // Control char = AT (0x16)
  mov     w1, #107                                // w1 = 107 (max allowed x coordinate)
  subs    w1, w1, w0                              // w1 = (107-column)
  b.lo    to_report_bb                            // Jump forward to to_report_bb if column > 107
  add     w1, w1, #2                              // w1 = (109-column)
  ldrb    w3, [x28, FLAGS-sysvars]                // w3 = [FLAGS]
  tbnz    w3, #1, po_at_set                       // If printer in use, jump forward to ...........
  mov     w4, #58
  subs    w4, w4, w6                              // w4 =(58-row)
  b.lo    to_report_bb                            // Jump forward to .......... if row > 58
  // TODO?


po_at_set:                               // L0ABF
  // TODO?


po_tab:                                  // L0AC2
  // TODO?
  // Control char = TAB (0x17)


to_report_bb:
  bl      report_bb
  b       to_end                                  // Exit routine.


to_co_temp_5:
  // Control char with one operand: between INK (0x10) and OVER (0x15)
  bl      co_temp_5
  b       to_end


to_end:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -------------------------
# Print spaces up to column
# -------------------------
# Keep printing a space character until cursor x position = (w4%108). If at
# least one space is printed, set system flag to suppress leading spaces.
#
# On entry:
#   w1 = (109 - column), or 1 for end-of-line
#   w4 = new x character position plus arbitrary multiple of 108 (0-65535)
po_fill:                                 // L0AC3
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w6, w4, w1                              // w6 = newx + 109 - oldx
  sub     w6, w6, #1                              // w6 = 108 + newx - oldx
  mov     w2, #0x00010000
  movk    w2, #0x00002f69                         // w2 = 77673
  umull   x3, w6, w2                              // x3 = (108 + newx - oldx) * 77673
  lsr     x3, x3, #23                             // x3 = (108 + newx - oldx) * 77673 / 8388608
                                                  //    = (108 + newx - oldx) / 108
  mov     w5, #108
  umsubl  x2, w5, w3, x6                          // x2 = x6 - w5*w3 = (108 + newx - oldx) % 108
                                                  //    = (newx - oldx) % 108
                                                  //    = number of spaces to print
  cbz     x2, 3f                                  // Exit if no spaces to print.
  ldrb    w6, [x28, FLAGS-sysvars]                // w6 = [FLAGS]
  orr     w6, w6, #0x1                            // Set bit 0 (signal suppress leading space)
  strb    w6, [x28, FLAGS-sysvars]                // [FLAGS] = w6
  // Loop to print chr$ 128 (w19+1) times.
  2:
    mov     x0, ' '                               // x0 = space character (' ')
    bl      print_w0                              // Print it.
    subs    w2, w2, #1                            // Decrement counter.
    b.ne    2b                                    // Repeat while counter != 0
3:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ----------------------
# Printable character(s)
# ----------------------
# This routine prints a printable character and then updates the stored cursor
# position.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = char (32-255)
po_able:                                 // L0AD9
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO preserve registers that following routine corrupts
  bl      po_any                                  // Print printable character.
  bl      po_store                                // Update stored cursor position.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -------------------------------------
# Store line, column, and pixel address
# -------------------------------------
# This routine updates the system variables associated with either
# the main screen, the lower screen/input buffer or the zx printer.
#
# If printer in use:
#   On entry:
#     Bit 1 of FLAGS set
#     w1 = value to store in P_POSN_X (109 - actual printer column)
#     x2 = value to store in PR_CC (address in printer buffer)
#     x28 = sysvars
#   On exit:
#     [P_POSN_X] set to printer position
#     [PR_CC] set to printer buffer address
#     w3 = [FLAGS]
#
# If upper screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     w0 = value to store in S_POSN_Y (60 - actual upper screen row)
#     w1 = value to store in S_POSN_X (109 - actual upper screen column)
#     x2 = value to store in DF_CC (address of upper screen cursor in display file)
#     x28 = sysvars
#   On exit:
#     [S_POSN_{X,Y}] set to upper screen position
#     [DF_CC] set to display file address of upper screen position
#     w3 = [TV_FLAG]
#
# If lower screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     w0 = value to store in S_POSN_Y_L and ECHO_E_Y (120 - [DF_SZ] - actual lower screen row)
#     w1 = value to store in S_POSN_X_L and ECHO_E_X (109 - actual lower screen column)
#     x2 = value to store in DF_CC_L (address of lower screen cursor in display file)
#     x28 = sysvars
#   On exit:
#     [S_POSN_{X,Y}_L] set to lower screen position
#     [ECHO_E_{X,Y}] set to lower screen position
#     [DF_CC_L] set to display file address of lower screen position
#     w3 = [TV_FLAG]
po_store:                                // L0ADC
  ldrb    w3, [x28, FLAGS-sysvars]                // w3 = [FLAGS]
  tbnz    w3, #1, 2f                              // If printer in use, jump forward to 2:.
  ldrb    w3, [x28, TV_FLAG-sysvars]              // w3 = [TV_FLAG]
  tbnz    w3, #0, 1f                              // If lower screen in use, jump forward to 1:.
  // Upper screen in use; store channel 'S' cursor position.
  strb    w0, [x28, S_POSN_Y-sysvars]             // Store upper screen row.
  strb    w1, [x28, S_POSN_X-sysvars]             // Store upper screen column.
  str     x2, [x28, DF_CC-sysvars]                // Store upper screen display file address.
  b       3f                                      // Exit routine.
1:
  // Lower screen in use; store channel 'K' cursor position.
  strb    w0, [x28, S_POSN_Y_L-sysvars]           // Store lower screen row.
  strb    w1, [x28, S_POSN_X_L-sysvars]           // Store lower screen column.
  strb    w0, [x28, ECHO_E_Y-sysvars]             // Store input buffer row.
  strb    w1, [x28, ECHO_E_X-sysvars]             // Store input buffer column.
  str     x2, [x28, DF_CC_L-sysvars]              // Store lower screen display file address.
  b       3f                                      // Exit routine.
2:
  // Printer in use; store channel 'P' cursor position.
  strb    w1, [x28, P_POSN_X-sysvars]             // Store printer column.
  str     x2, [x28, PR_CC-sysvars]                // Store printer buffer address.
3:
  // Exit routine
  ret


# -------------------------
# Fetch position parameters
# -------------------------
# This routine fetches the line/column and display file address
# of the upper or lower screen or, if the printer is in use,
# the column position and absolute memory address.
#
# If printer in use:
#   On entry:
#     Bit 1 of FLAGS set
#     [P_POSN_X] set to printer position
#     [PR_CC] set to printer buffer address
#     x28 = sysvars
#   On exit:
#     w0 = [FLAGS]
#     w1 = [P_POSN_X] (109 - actual printer column)
#     x2 = [PR_CC] (address in printer buffer)
#
# If upper screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     [S_POSN_{X,Y}] set to upper screen position
#     [DF_CC] set to display file address of upper screen position
#     x28 = sysvars
#   On exit:
#     w0 = [S_POSN_Y] (60 - actual upper screen row)
#     w1 = [S_POSN_X] (109 - actual upper screen column)
#     x2 = [DF_CC] (address of upper screen cursor in display file)
#
# If lower screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     [S_POSN_{X,Y}_L] set to lower screen position
#     [DF_CC_L] set to display file address of lower screen position
#     x28 = sysvars
#   On exit:
#     w0 = [S_POSN_Y_L] (120 - [DF_SZ] - actual lower screen row)
#     w1 = [S_POSN_X_L] (109 - actual lower screen column)
#     x2 = [DF_CC_L] (address of lower screen cursor in display file)
po_fetch:                                // L0B03
  ldrb    w0, [x28, FLAGS-sysvars]                // w0 = [FLAGS]
  tbnz    w0, #1, 2f                              // If printer in use, jump forward to 2:.
  ldrb    w0, [x28, TV_FLAG-sysvars]              // w0 = [TV_FLAG]
  tbnz    w0, #0, 1f                              // If lower screen in use, jump forward to 1:.
  // Upper screen in use; fetch channel 'S' cursor position.
  ldrb    w0, [x28, S_POSN_Y-sysvars]             // Fetch upper screen row.
  ldrb    w1, [x28, S_POSN_X-sysvars]             // Fetch upper screen column.
  ldr     x2, [x28, DF_CC]                        // Fetch upper screen display file address.
  b       3f                                      // Exit routine.
1:
  // Lower screen in use; fetch channel 'K' cursor position.
  ldrb    w0, [x28, S_POSN_Y_L-sysvars]           // Fetch lower screen row.
  ldrb    w1, [x28, S_POSN_X_L-sysvars]           // Fetch lower screen column.
  ldr     x2, [x28, DF_CC_L]                      // Fetch lower screen display file address.
  b       3f                                      // Exit routine.
2:
  // Printer in use; fetch channel 'P' cursor position.
  ldrb    w1, [x28, P_POSN_X-sysvars]             // Fetch printer column.
  ldr     x2, [x28, PR_CC]                        // Fetch printer buffer address.
3:
  // Exit routine.
  ret


# -------------------
# Print any character
# -------------------
# This routine is used to print any character in range 32 - 255.
# It is only called from po_able which then calls po_store.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = char (32-255)
po_any:                                  // L0B24
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  cmp     w3, #0x80                               // Check if printable chars 32-127.
  b.lo    1f                                      // If so, jump forward to 1:.
  cmp     w3, #0x90                               // Test if a UDG or keyword token.
  b.hs    2f                                      // If so, jump forward to 2:.
  // Mosaic character 128-143.
  adr     x6, MEMBOT                              // x6 = temporary location to write bit pattern to
  bl      po_mosaic_half                          // Generate top half (first 8 pixel rows) of mosaic character.
  bl      po_mosaic_half                          // Generate bottom half (last 8 pixel rows) of mosaic character.
  adr     x4, MEMBOT                              // x4 = address of character bit pattern
  // TODO: check registers are set correctly for this call
  bl      pr_all                                  // Print mosaic character 128-143.
  b       3f                                      // Exit routine.
1:
  // Printable char 32-127.
  bl      po_char                                 // Print printable char 32-127.
  b       3f                                      // Exit routine.
2:
  // UDG or keyword token 144-255.
  bl      po_t_udg                                // Print UDG or keyword token 144-255.
3:
  // Exit routine.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# --------------------------------
# Generate half a mosaic character
# --------------------------------
# The 16 2*2 mosaic characters 128-143 are formed from bits 0-3 of the
# character number. For example, char 134 (0b10000110) is:
#
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000  <bit 1> <bit 0>
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111  <bit 3> <bit 2>
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111
#
# This routine generates either the top or bottom half of the character.
# Each half is comprised of 16 bytes (8 pixel rows; 2 bytes per row).
# It shifts w3 two bits right after processing bits 0 and 1, so that it
# can be called twice in succession to generate top half from bits 0/1
# and then the bottom half from bits 2/3.
#
# On entry:
#   w3 = LHS in bit 1, RHS in bit 0
#   x6 = address to write bit pattern to
# On exit:
#   [x6] = 16 byte pattern
#   w3 = input w3 shifted right two bits
#   x4 = last 8 bytes of bit pattern (same as first 8 bytes)
#   x5 = last 8 bytes of bit pattern with character right hand side bits cleared.
#   x6 += 16
#   NZCV =
#     if entry w3 bit 1 set:
#       0b0000
#     if entry w3 bit 1 clear:
#       0b0100
po_mosaic_half:                          // L0B3E
  mov     x4, 0x00ff00ff00ff00ff                  // Pattern for first 4 pixel rows if bit 0 set.
  tst     w3, #1                                  // Is bit 0 of w3 set?
  csel    x4, x4, xzr, ne                         // If so, use prepared bit 0 pattern, otherwise clear bits.
  mov     x5, 0xff00ff00ff00ff00                  // Pattern for first 4 pixel rows if bit 1 set.
  tst     w3, #2                                  // Is bit 1 of w3 set?
  csel    x5, x5, xzr, ne                         // If so, use prepared bit 1 pattern, otherwise clear bits.
  orr     x4, x4, x5                              // Merge results for bit 0 and bit 1.
  str     x4, [x6], #8                            // Write first four rows.
  str     x4, [x6], #8                            // Write second four rows (same as first four rows).
  lsr     w3, w3, #2                              // Shift w3 two bits, so next call will consider bits 2/3
                                                  // for lower half of mosaic character instead of bits 0/1
                                                  // for upper half of mosaic character.
  ret


# Print tokens and user defined graphics (chars 0x90-0xff).
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = char (144-255)
po_t_udg:                                // L0B52
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      print_token_udg_patch
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# Print UDG (chars 0x90-0xa4).
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = (char-165) (-21 to -1)
rejoin_po_t_udg:                         // L0B56
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w3, w3, #21                             // w3 now in range 0 to 20
  ldr     x4, [x28, UDG-sysvars]                  // x4 = [UDG]
  bl      po_char_2
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# This routine is used to print ASCII characters  32d - 127d.
#
# Bit 0 of [FLAGS] updated to 1 if w3=' ' (=> no leading space), otherwise 0 (=>
# leading space).
#
# On entry:
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = char (32-127)
#   [CHARS] = font table address of theoretical char 0
#   [FLAGS] bit 1 (printer in use or not)
#   [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
#   if printer not in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
#     [TV_FLAGS] bit 0 (lower screen in use or not)
#     [DF_SZ]
#     [ATTR_T]
#     [MASK_T]
# On exit:
#   [FLAGS] bit 0 == 1 if w3==' ' else 0
#   If printer in use:
#     printer buffer updated (and potentially flushed)
#   Else:
#     display file and attributes file updated
#     x0 = 60 - new line offset into section
#     x1 = 109 - new column, or 1 for end-of-line
#     x2 += 1 (correct new cursor memory location, unless at first char of screen third)
#     Plus po_attr register changes (excluding x3/x24):
#       x5
#       x6
#       x7
#       x8
#       x9 = mbreq
#       x10
#       x11
#       x12
#       x13
#       x14
#       x15
#       x16
#       x17
#       x18
#       NZCV
#     If was at end-of-line before printing (entry x1 == 1):
#       cl_set register updates:
#         x4 = y offset into screen third of updated position (not entry position)
#       If lower screen:
#         [S_POSN_X_L] = 109 (start of line)
#         [S_POSN_Y_L] = x0-1 (line below)
#         [ECHO_E_X] = 109 (start of line)
#         [ECHO_E_Y] = x0-1 (line below)
#         [DF_CC_L] set to display file address for [S_POSN_{X,Y}_L]
#       If upper screen:
#         [S_POSN_X] = 109 (start of line)
#         [S_POSN_Y] = x0-1 (line below)
#         [DF_CC] set to display file address for [S_POSN_{X,Y}]
#     Else:
#       x4 = address of 32 byte character bit pattern
po_char:                                 // L0B65
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x4, [x28, CHARS-sysvars]                // x4 = [CHARS]
  bl      po_char_2
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


po_char_2:                               // L0B6A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w5, [x28, FLAGS-sysvars]                // w5 = [FLAGS]
  and     w5, w5, 0xfe                            // Clear bit 0 (=> allow leading space)
  cmp     w3, #0x20                               // Space character?
  b.ne    1f                                      // If not, jump forward to 1:.
  orr     w5, w5, 0x1                             // Set bit 0 (=> suppress leading space)
1:
  strb    w5, [x28, FLAGS-sysvars]                // Update [FLAGS] with bit 0 clear iff char is a space.
  add     x4, x4, x3, lsl #5                      // x4 = first byte of bit pattern of char
  bl      pr_all
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -----------------------------------------
# Render character bitmap to screen/printer
# -----------------------------------------
# This entry point entered from above to paint ASCII and UDGs
# to screen/printer but also from earlier to paint mosaic characters.
#
# On entry:
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   x4 = address of 32 byte character bit pattern
#   [FLAGS] bit 1 (printer in use or not)
#   [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
#   if printer not in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
#     [TV_FLAGS] bit 0 (lower screen in use or not)
#     [DF_SZ]
#     [ATTR_T]
#     [MASK_T]
# On exit:
#   If printer in use:
#     printer buffer updated (and potentially flushed)
#   Else:
#     display file and attributes file updated
#     x0 = 60 - new line offset into section
#     x1 = 109 - new column, or 1 for end-of-line
#     x2 += 1 (correct new cursor memory location, unless at first char of screen third)
#     Plus po_attr register changes (excluding x24):
#       x3
#       x5
#       x6
#       x7
#       x8
#       x9 = mbreq
#       x10
#       x11
#       x12
#       x13
#       x14
#       x15
#       x16
#       x17
#       x18
#       NZCV
#     If was at end-of-line before printing (entry x1 == 1):
#       cl_set register updates:
#         x4 = y offset into screen third of updated position (not entry position)
#       If lower screen:
#         [S_POSN_X_L] = 109 (start of line)
#         [S_POSN_Y_L] = x0-1 (line below)
#         [ECHO_E_X] = 109 (start of line)
#         [ECHO_E_Y] = x0-1 (line below)
#         [DF_CC_L] set to display file address for [S_POSN_{X,Y}_L]
#       If upper screen:
#         [S_POSN_X] = 109 (start of line)
#         [S_POSN_Y] = x0-1 (line below)
#         [DF_CC] set to display file address for [S_POSN_{X,Y}]
pr_all:                                  // L0B7F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!                   // Backup x23 / x24 on stack.
  ldrb    w20, [x28, FLAGS-sysvars]               // w20 = [FLAGS]
  mov     x21, x2                                 // x21 = address in display file / printer buffer
  mov     x22, x4                                 // x22 = address of 32 byte character bit pattern
  cmp     w1, #1                                  // Trailing position at end of line?
  b.ne    1f                                      // If not trailing, jump ahead to 1:.
  // Trailing at end of line.
  sub     w0, w0, #1                              // Move down a line.
  mov     w1, #109                                // Move cursor to leftmost position.
  tbz     w20, #1, 1f                             // If printer not in use, jump ahead to 1:.
  // Printer in use.
  // TODO preserve registers that following routine corrupts
  bl      copy_buff                               // Flush printer buffer and reset print position.
1:
  cmp     w1, #109                                // Leftmost column?
  b.ne    2f                                      // If not, jump ahead to 2:.
  // Leftmost column.

  // updates x2
  // corrupts x3, x4, x5, x6
  bl      po_scr                                  // Consider scrolling
2:
  stp     x0, x1, [sp, #-16]!                     // Backup x0 / x1 on stack.
  str     x2, [sp, #-16]!                         // Backup x2 on stack.
  ldrb    w6, [x28, P_FLAG-sysvars]               // w6 = [P_FLAG]
  tst     w6, #1                                  // Test (temporary) OVER status (bit 0).
  csetm   w7, ne                                  // w7 = -1 if (temporary) OVER 1 in [P_FLAG]
                                                  //       0 if (temporary) OVER 0 in [P_FLAG]
  tst     w6, #4                                  // Test (temporary) INVERSE status (bit 2).
  csetm   w24, ne                                 // w24 = -1 if (temporary) INVERSE 1 in [P_FLAG]
                                                  //        0 if (temporary) INVERSE 0 in [P_FLAG]
  bfi     x24, x7, #32, #32                       // Move w7 (OVER mask) into upper 32 bits of x24
  mov     w19, #16                                // 16 pixel rows to update
  tbz     w20, #1, 3f                             // If printer not in use, jump ahead to 3:.
  ldrb    w10, [x28, FLAGS2-sysvars]              // w9 = [FLAGS2]
  orr     w10, w10, #0x2                          // w9 = [FLAGS2] with bit 1 set
  strb    w10, [x28, FLAGS2-sysvars]              // Update [FLAGS2] to have bit 1 set (signal printer buffer has been used).
  3:
    ldrh    w11, [x21]                            // w11 = current screen bit pattern
    and     x11, x11, x24, lsr #32                // Consider OVER.
    ldrh    w10, [x22], #2                        // w10 = character pixel line bit pattern at [x22]; bump x22
    eor     w11, w11, w10                         // Apply character bit pattern.
    eor     w23, w11, w24                         // Consider INVERSE.
    mov     x0, x21                               // Display file address to update for lefthandside byte
    bfxil   w1, w23, #0, #8                       // w23 has 16 bytes of bit pattern, left side is bits 0-7
  // disturbs x0, x3, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18
    bl      poke_address                          // Update LHS byte
    add     x0, x21, #1                           // RHS target address
    bfxil   w1, w23, #8, #8                       // Next 8 bits of pattern for RHS
  // disturbs x0, x3, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18
    bl      poke_address                          // Update RHS byte
    tbnz    w20, #1, 4f                           // If printer in use, jump ahead to 6:.
  // Printer not in use.
    add     x21, x21, 0x0870                      // 20*216 = 0x10e0 is too big to add in one step, so do it in two steps.
    add     x21, x21, 0x0870                      // Gives next pixel line down.
    b       5f
  // Printer in use
  4:
    add     x21, x21, #0xd8                       // x21 = current printer buffer location + 216

  //////////////////////////////////////////////////////////////////////////
  //
  // TODO: Probably this whole block is not needed, since buffer is probably
  // always flushed at start of new line.
  //
  //
    cmp     x21, printer_buffer_end               // Is x21 now past end of printer buffer?
    b.lo    5f                                    // If not, jump ahead to 5:.
  // Overshot printer buffer
    sub     x21, x21, #0xd80                      // Correct printer buffer position
  //
  //
  //////////////////////////////////////////////////////////////////////////

  5:
    sub     w19, w19, #1                          // Decrement pixel row loop counter
    cbnz    w19, 3b                               // Repeat until all 16 pixel rows complete
  tbnz    w20, #1, 6f                             // If printer in use, jump ahead to 7:.
// Printer not in use
  ldr     x0, [sp]                                // x0 = original display file address
  bl      po_attr                                 // Call routine po_attr to update corresponding colour attribute.
6:
  ldr     x2, [sp], #0x10                         // Restore screen/printer position.
  ldp     x0, x1, [sp], #0x10                     // Restore line/column.
  sub     w1, w1, #1                              // Move column to the right.
  add     x2, x2, #1                              // Increase screen/printer position
                                                  // Note: at end of screen thirds this will be the wrong address,
                                                  // but cl_set presumably fixes it, before subsequent pr_all call.
                                                  // Instead of calling cl_set everywhere, probably the above
                                                  // could have been fixed to handle screen third endings.
  ldp     x23, x24, [sp], #0x10                   // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# -------------
# Set attribute
# -------------
# Update the attribute entry in the attributes file for a corresponding display
# file address, based on attribute characteristics stored in system variables
# ATTR_T, MASK_T, P_FLAG.
#
# TODO: this section is no longer accurate since it now calls poke_address.
# First document poke_address, and then correct this section.
#
# On entry:
#   x0 = address in display file
# On exit:
#   x0 = [P_FLAG]
# #   x1 = [ATTR_T] | ([MASK_T] << 8)
#   x3 = ??
#   x5 = ??
#   x6 = ??
#   x7 = ??
#   x8 = ??
#   x9 = mbreq
# #   x10 = x attribute coordinate (0-107)
# #   x11 = display file offset
#   x12 = 108
# #   x13 = multiplication constant for dividing by 216
# #   x14 = display file offset / 216
# #   x15 = multiplication constant for dividing by 5
# #   x16 = attribute_file address offset
# #   x17 = [0-7] attribute value applied / [8-15] [MASK_T]
#   x18 = 5 * screen third (0x0 / 0x5 / 0xa)
#   x24 = attributes_file
#
# TODO: We shouldn't need to convert a display file address to an attributes file
#       address; instead we should just pass the attributes file address into the
#       routine.
po_attr:                                 // L0BDB
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x9, display_file                        // x9 = start display file address
  adr     x24, attributes_file                    // x24 = start attributes file address
  sub     x11, x0, x9                             // x11 = display file offset
  // attribute address = attributes_file + ((x11/2) % 108) + 108 * (((x11/216) % 20) + 20 * (x11/(216*20*16)))
  mov     x13, #0x0000684c00000000
  movk    x13, #0x012f, lsl #48                   // x13 = 0x012f684c00000000 = 85401593570131968
  umulh   x14, x13, x11                           // x14 = (85401593570131968 * x11) / 18446744073709551616 = int(x11/216)
  mov     x15, #0xcccd000000000000                // x15 = 14757451553962983424
  umulh   x16, x15, x14                           // x16 = 14757451553962983424 * int(x11/216) / 2^64 = (4/5) * int(x11/216)
  lsr     x16, x16, #4                            // x16 = int(int(x11/216)/20)
  add     x16, x16, x16, lsl #2                   // x16 = 5 * int(int(x11/216)/20)
  sub     x16, x14, x16, lsl #2                   // x16 = int(x11/216) - 20 * int(int(x11/216)/20) = (x11/216)%20
  mov     x17, #0x0000f2ba00000000                // x17 = 266880677838848
  umulh   x18, x17, x11                           // x18 = 266880677838848 * x11 / 2^64 = int(x11/(216*20*16))
  add     x18, x18, x18, lsl #2                   // x18 = 5*int(x11/(216*20*16))
  mov     x12, #0x6c                              // x12 = 108
  lsr     x10, x11, #1                            // x10 = int(x11/2)
  msub    x10, x12, x14, x10                      // x10 = int(x11/2)-108*int((x11/2)/108)=(x11/2)%108
  add     x16, x16, x18, lsl #2                   // x16 = (x11/216)%20+20*int(x11/(216*20*16))
  madd    x16, x16, x12, x10                      // x16 = 108*(((x11/216)%20+20*int(x11/(216*20*16))) + (x11/2)%108
                                                  //     = attribute address offset from attributes_file (x24)
  ldrb    w17, [x24, x16]                         // w17 = attribute data
  ldrh    w1, [x28, ATTR_T-sysvars]               // w1[0-7] = [ATTR_T]
                                                  // w1[8-15] = [MASK_T]
  eor     w17, w17, w1                            // w17[0-7] = attribute data EOR [ATTR_T]
                                                  // w17[8-15] = [MASK_T]
  and     w17, w17, w1, lsr #8                    // w17 = attribute data EOR [ATTR_T] AND [MASK_T] (bits 8-31 clear)
  eor     w17, w17, w1                            // w17[0-7] = attribute data EOR [ATTR_T] AND [MASK_T] EOR [ATTR_T]
                                                  // w17[0-8] = [MASK_T]
                                                  // So lower 8 bits of w17 are taken from current screen values when
                                                  // MASK_T bit is 1, and taken from ATTR_T when MASK_T bit is 0.
  ldrb    w0, [x28, P_FLAG-sysvars]               // w0 = [P_FLAG]
                                                  //   Bit 0: Temporary 1=OVER 1, 0=OVER 0.
                                                  //   Bit 1: Permanent 1=OVER 1, 0=OVER 0.
                                                  //   Bit 2: Temporary 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 3: Permanent 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 4: Temporary 1=Using INK 9.
                                                  //   Bit 5: Permanent 1=Using INK 9.
                                                  //   Bit 6: Temporary 1=Using PAPER 9.
                                                  //   Bit 7: Permanent 1=Using PAPER 9.
  tbz     w0, #6, 1f                              // Jump forward to 1: if not PAPER 9.
// PAPER 9
  and     w17, w17, #~0b00111000                  // PAPER = black
  tbnz    w17, #2, 1f                             // If INK is 4/5/6/7 (green/cyan/yellow/white), jump ahead to 1:.
// INK is 0/1/2/3 (black/blue/red/magenta)
  eor     w17, w17, #0b00111000                   // PAPER = white (orr instruction also ok here)
1:
  tbz     w0, #4, 2f                              // Jump forward to 2: if not INK 9.
// INK 9
  and     w17, w17, #~0b00000111                  // INK = black
  tbnz    w17, #5, 2f                             // If PAPER is 4/5/6/7 (green/cyan/yellow/white), jump ahead to 2:.
// PAPER is 0/1/2/3 (black/blue/red/magenta)
  eor     w17, w17, #0b00000111                   // INK = white (orr instruction also ok here)
2:
  strb    w17, [x24, x16]
  add     x0, x24, x16
  mov     w1, w17
  bl      poke_address                            // Update attribute file entry
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ----------------
# Message printing
# ----------------
# This entry point is used to print tape, boot-up, scroll? and error messages.
# No leading and no trailing spaces used.
#
# On entry:
#   w3 = token table index (address of step over token)
#   x4 = address of message stored in RAM to print
po_msg:                                  // L0C0A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w5, #0                                  // Index first entry in table.
  bl      po_table                                // Could just call po_table_1 here (and only need part of it).
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# -----------------------------------------------------------------------------
# Print BASIC keyword (chars 0xa5-0xff) with possible leading/trailing space(s)
# -----------------------------------------------------------------------------
#
# No leading space for:
#   "RND" | "INKEY$" | "PI" | "FN" | "POINT" | "SCREEN$" | "ATTR" | "AT" | "TAB" | "VAL$" | "CODE"
#   | "VAL" | "LEN" | "SIN" | "COS" | "TAN" | "ASN" | "ACS" | "ATN" | "LN" | "EXP" | "INT" | "SQR"
#   | "SGN" | "ABS" | "PEEK" | "IN" | "USR" | "STR$" | "CHR$" | "NOT" | "BIN" | "<=" | ">=" | "<>"
#
# For all other keywords:
#   Leading space only if bit 0 of FLAGS is clear
#
# Trailing space for all keywords (regardless of bit 0 of FLAGS) except for:
#   "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #"
#
# On entry:
#   w3 = token table index (char-165) (0 to 90)
#   x28 = sysvars
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x0 =
#     for keywords  "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #":
#       0x0
#     else:
#       ' '
#   x1 = [[CURCHL]]
#   x4 = first address after zero termination byte of BASIC keyword in token table
#   x5 = x3
#   x6 = last char of keyword (not including the trailing zero byte)
#   NZCV =
#     for keywords  "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #":
#       0b1000
#     for "FN":
#       0b0110
#     else:
#       0b0010
po_tokens:                               // L0C10
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, tkn_table                           // Address of table with BASIC keywords
  mov     w5, w3                                  // Tokens use the token table index to determine trailing space
  bl      po_table
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------
# Find message in table, print it, with possible leading/trailing space(s)
# ------------------------------------------------------------------------
#
# The original Spectrum ROM 1 routine received the token number in register A,
# and popped a value off the stack to check whether trailing spaces should be
# printed. This number on the stack was also the token number when called from
# PO-TABLE routine, but had the explicit value of 4 when called from the
# TOKEN/UDG routine at L3BC3 (to include a trailing space) and 0 when called from
# PO-MSG routine (to not include a trailing space). Since the value on the stack
# was therefore not always the same as the value in register A, this ported
# routine takes two different input values in w3 and w5. w3 represents the value
# in Z80 register A, and w5 represents the value that was popped off the stack.
#
# Prints leading space if bit 0 of FLAGS clear and w3 >= 32 and first char >= 'A'.
# Prints trailing space if w5 >= 0x03 and (last char >= 'A' or last char == '$').
#
# On entry:
#   w3 = message table index
#   x4 = address of message table
#   w5 = trailing space indicator:
#     w5 < 03 => suppress trailing space
#     w5 >= 03 => don't suppress trailing space
#   x28 = sysvars
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x0 =
#     if w5 >= 3 and (last char >= 'A' or last char == '$')
#       ' '
#     else:
#       0x0
#   x1 = [[CURCHL]]
#   x4 = first address after found zero-byte terminated message
#   x6 = last char of keyword (not including the trailing zero byte)
#   NZCV =
#     if w5 > 3 and (last char >= 'A' or last char == '$'):
#       0b0010
#     for w5 == 0x03 and (last char >= 'A' or last char == '$'):
#       0b0110
#     else:
#       0b1000
po_table:                                // L0C14
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      po_search                               // Routine po_search will set carry for all messages and
                                                  // function words.
  bl      po_table_1
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------
# Print message and possibly a leading/trailing space(s)
# ------------------------------------------------------
#
# Prints leading space if bit 0 of FLAGS clear and carry flag set.
# Prints trailing space if w5 >= 0x03 and (last char >= 'A' or last char == '$').
#
# On entry:
#   x4 = address of zero-terminated string to print
#   w5 = trailing space indicator:
#     w5 < 0x03 => no trailing space
#     w5 >= 0x03 => trailing space if last char >= 'A' or last char == '$'
#   x28 = sysvars
#   bit 0 of FLAGS clear and carry flag set if leading space required
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x0 =
#     if w5 >= 3 and (last char >= 'A' or last char == '$')
#       ' '
#     else:
#       0x0
#   x1 = [[CURCHL]]
#   x4 = first address after zero-terminated string
#   x6 = last char of keyword (not including the trailing zero byte)
#   NZCV =
#     if w5 > 3 and (last char >= 'A' or last char == '$'):
#       0b0010
#     for w5 == 0x03 and (last char >= 'A' or last char == '$'):
#       0b0110
#     else:
#       0b1000
po_table_1:                              // L0C17
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  b.lo    1f                                      // If carry is clear, jump forward to 1:.
  ldrb    w6, [x28, FLAGS-sysvars]                // w6 = [FLAGS]
  tbnz    w6, #0, 1f                              // If suppress space, jump forward to 1:.
  mov     w0, ' '                                 // x0 = space character (' ')
  bl      print_w0                                // Print it
  1:
    ldrb    w0, [x4], #1                          // Fetch ASCII char from token table entry into w0.
    cbz     w0, 2f                                // If 0, end of string; exit loop; jump forward to 2:.
    mov     w6, w0                                // Stash "previous" char in w6.
    bl      print_w0                              // Print it, preserving registers.
    b       1b                                    // Repeat loop
2:
  cmp       w6, '$'                               // Was last character '$'?
  b.eq      3f                                    // If so, jump forward to 3: to consider trailing space.
  cmp       w6, 'A'                               // Was it < 'A' i.e. '#', '>', '=' from tokens or ' ', '.'
                                                  // (from tape) or '?' from scroll?
  b.lo      4f                                    // No trailing space, so exit routine.
3:
  cmp       w5, #0x03                             // Test against RND, INKEY$ and PI which have no parameters
                                                  // and therefore no trailing space.
  b.lo      4f                                    // If one of them, no trailing space, so jump forward to 4:.
  mov       w0, ' '                               // Otherwise print a trailing space (' ').
  bl        print_w0
4:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# Nothing needed, since on Spectrum 128, PO-SAVE just calls RST 10H (print_w0),
# but preserves DE, which would otherwise be corrupted. We have far more
# registers available in aarch64, so no wrapper needed.
# po_save:                         // L0C3B


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


# ---------------
# Test for scroll
# ---------------
# This test routine is called when printing carriage return, when considering
# PRINT AT and from the general PRINT ALL characters routine to test if
# scrolling is required, prompting the user if necessary.
#
#
# If printer in use:
#   On entry:
#     Bit 1 of FLAGS set
#   On exit:
#     w4 = [FLAGS]
#
# If upper screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     [DF_SZ] set to number of lines for lower screen
#     w0 = 60 - actual screen row (60 = top line, 59 = second line, etc)
#     w1 = (109 - actual column) or 0x01 for past end of line but no carriage return
#   On exit:
#     If w0 > [DF_SZ]:
#       [S_POSN_Y] = x0
#       [S_POSN_X] = x1
#       [DF_CC] = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#       x2 = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#       w3 = [TV_FLAG]
#       w4 = (60-x0)%20
#       w5 = 216
#       w6 = 0x10e00
#       NZCV = 0b0010
#     If w0 == [DF_SZ]:
#       TODO (scrolling occurs)
#     If w0 < [DF_SZ]:
#       TODO (out of screen)
#
# If lower screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     [DF_SZ] set to number of lines for lower screen
#     w0 = 120 - [DF_SZ] - actual screen row (60 = top line of lower screen, 59 = second line of lower screen, etc)
#     w1 = (109 - actual column) or 0x01 for past end of line but no carriage return
#   On exit:
#     If 1 > w0 > 60-[DF_SZ]:
#       [S_POSN_Y_L] = x0
#       [S_POSN_X_L] = x1
#       [ECHO_E_Y] = x0
#       [ECHO_E_X] = x1
#       [DF_CC_L] = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#       x2 = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#       w3 = [TV_FLAG]
#       w4 = (120-x0-[DF_SZ])%20
#       w5 = 216
#       w6 = 0x10e00
#       If w0 == 61-[DF_SZ]:
#         NZCV = 0b0110
#       Else:
#         NZCV = 0b0010
#     If w0 == 60-[DF_SZ]:
#       TODO (scrolling occurs)
#     If w0 < 2:
#       TODO (out of screen)
#     If w0 < 60-[DF_SZ]:
#       TODO (out of screen)
po_scr:                                  // L0C55
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 9f                              // If printer in use, jump forward to 9:.
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w4, [x28, TV_FLAG-sysvars]              // w4 = [TV_FLAG]
  ldrb    w2, [x28, DF_SZ-sysvars]                // w2 = [DF_SZ].
  tbnz    w4, #0, po_scr_4                        // If lower screen in use, jump forward to po_scr_4.
  cmp     w0, w2                                  // 60 - line offset < DF_SZ?
  b.lo    report_5                                // w0 < [DF_SZ] => Out of screen (number of lines of upper screen < line offset).
  b.ne    8f                                      // No need to scroll - call cl_set and return.
// w0 == w2
  tbz     w1, #4, po_scr_2                        // Test TV_FLAG: if not an automatic listing, jump ahead to po_scr_2.
// TODO - test code below
// Automatic program listing
  ldrb    w7, [x28, BREG-sysvars]                 // w7 = [BREG] (scroll line count)
  subs    w7, w7, #1                              // Decrement scroll line count.
  b.eq    po_scr_3                                // If scroll count now 0, need to prompt user - so jump ahead to po_scr_3.
  mov     x0, #0                                  // Prepare stream number (0) (why not -3 like below?)
  bl      chan_open                               // Open stream 0 (Keyboard/Lower screen, unless modified).
  ldr     x8, [x28, LIST_SP-sysvars]              // x8 = LIST stack pointer (separate stack pointer for program listing)
  mov     sp, x8                                  // Update stack pointer.
  and     w1, w1, #~0x10                          // Signal automatic program listing complete (since end of screen reached).
  strb    w1, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w1
  b       8f                                      // Exit routine.
po_scr_2:
// TODO - test code below
  ldrb    w9, [x28, SCR_CT-sysvars]               // w9 = [SCR_CT]
  subs    w9, w9, #1                              // Decrement SCR_CT.
  b.ne    po_scr_3                                // Jump forward to po_scr_3 to scroll display if result not zero.
// Now produce "scroll?" prompt
  mov     w9, #60
  sub     w9, w9, w0                              // w9 = line offset into section
  strb    w9, [x28, SCR_CT-sysvars]               // [SCR_CT] = w9
  ldrh    w9, [x28, ATTR_T-sysvars]               // w9[0-7] = [ATTR_T]
                                                  // w9[8-15] = [MASK_T]
  ldrb    w10, [x28, P_FLAG-sysvars]              // w10 = [P_FLAG]
  mov     x0, #-3                                 // Select system stream -3 (system channel K).
  bl      chan_open                               // Open it.
  adr     x4, scroll_message                      // Message table.
  mov     x3, #0                                  // First string in table.
  bl      po_msg                                  // Print it.
  ldrb    w9, [x28, TV_FLAG-sysvars]              // w9[0-7] = [TV_FLAG]
  orr     w9, w9, #0x20                           // Set bit 5 - signal clear lower screen.
  strb    w9, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w9[0-7]
  ldrb    w9, [x28, FLAGS-sysvars]                // w9[0-7] = [FLAGS]
  orr     w9, w9, #0x08                           // Set bit 3 - signal 'L' mode.
  and     w9, w9, #~0x20                          // Clear bit 5 - signal no new key.
  strb    w9, [x28, FLAGS-sysvars]                // [FLAGS] = w9[0-7]
// TODO
po_scr_3:
// TODO
po_scr_4:
  cmp     w0, #0x02
  b.lo    report_5                                // w0 < 2 => Out of screen
  add     w4, w0, w2                              // w4 = w0 + [DF_SZ]
  subs    w4, w4, #61                             // w4 = w0 + [DF_SZ] - 61
  b.hs    8f                                      // w0 > 60 - [DF_SZ] => No need to scroll - call cl_set and return.
// TODO


8:
  bl      cl_set                                  // in Spectrum 128K, this was pushed on stack at start of po_scr
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
9:
  ret


report_5:                                // L0C86
// TODO


scroll_message:                          // L0CF8
  .asciz    "?"                                   // Step over marker
  .asciz    "scroll?"

.align 3

# ----------------------
# Temporary colour items
# ----------------------
# This subroutine copies the permanent colour items to the temporary ones.
#
# On entry:
# On exit:
#
#   If Channel K (bit 0 of TV_FLAG is set):
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : temp bits set to zero
#     w0 = new [P_FLAG]
#     w1 = [BORDCR]
#
#   If Channel S (bit 0 of TV_FLAG is clear):
#     [ATTR_T] = [ATTR_P]
#     [MASK_T] = [MASK_P]
#     [P_FLAG] : perm copied to temp bits
#     w0 = new [P_FLAG]
#     w1 = ([MASK_P] << 8) | [ATTR_P]
#     w2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
temps:                                   // L0D4D
  ldrb    w0, [x28, P_FLAG-sysvars]               // w0 = [P_FLAG]
  and     w0, w0, 0xaaaaaaaa                      // w0 = [P_FLAG] with temp bits cleared, perm bits unaltered
  ldrb    w1, [x28, TV_FLAG-sysvars]              // w1 = [TV_FLAG]
  tbnz    w1, #0, 1f                              // If lower screen in use, jump forward to 1:.
  // Upper screen in use.
  ldrh    w1, [x28, ATTR_P-sysvars]               // w1[0-7] = [ATTR_P]
                                                  // w1[8-15] = [MASK_P]
  lsr     w2, w0, #1                              // w2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
  orr     w0, w2, w0                              // w0 = [P_FLAG] with temp bits copied from perm bits; perm bits unaltered
  b       2f                                      // Jump ahead to 2:.
1:
  // Lower screen in use.
  ldrb    w1, [x28, BORDCR-sysvars]               // w1[0-7] = [BORDCR]
                                                  // w1[8-15] = 0
2:
  strh    w1, [x28, ATTR_T-sysvars]               // [ATTR_T] = w1[0-7] =
                                                  //    if upper screen: [ATTR_P]
                                                  //    if lower screen: [BORDCR]
                                                  // [MASK_T] = w1[8-15] =
                                                  //    if upper screen: [MASK_P]
                                                  //    if lower screen: 0
  strb    w0, [x28, P_FLAG-sysvars]               // [P_FLAG] =
                                                  //    if upper screen: perm flags unaltered, temp flags copied from perm
                                                  //    if lower screen: perm flags unaltered, temp flags cleared
  ret


# ------------------
# Handle CLS command
# ------------------
# clears the display.
# if it's difficult to write it should be difficult to read.
cls:                                     // L0D6B
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      cl_all
  bl      cls_lower
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


// TODO: check this routine uses correct registers in subroutine calls and that subroutines don't corrupt needed registers
cls_lower:                               // L0D6E
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  ldrb    w9, [x28, TV_FLAG-sysvars]              // w9[0-7] = [TV_FLAG]
  and     w9, w9, #~0x20                          // Clear bit 5 - signal do not clear lower screen.
  orr     w9, w9, #0x01                           // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w9[0-7]
  bl      temps                                   // Routine temps picks up temporary colours.
  ldrb    w0, [x28, DF_SZ-sysvars]                // Fetch lower screen DF_SZ.
  bl      cl_line                                 // Routine CL-LINE clears lower part and sets permanent attributes.
  adr     x0, attributes_file_end                 // x0 = address of first byte after attributes file
  sub     x19, x0, 108*2                          // x19 = attribute address leftmost cell, second line up (first byte after last cell to clear)
  ldrb    w2, [x28, DF_SZ-sysvars]                // Fetch lower screen DF_SZ.
  mov     w3, #108
  umsubl  x20, w2, w3, x0                         // x20 = first attribute cell to clear
  ldrb    w21, [x28, ATTR_P-sysvars]              // Fetch permanent attribute from ATTR_P.
1:                                                // Set attributes file values to [ATTR_P] for lowest [DF_SZ] lines except bottom two lines.
  cmp     x19, x20
  b.ls    2f                                      // Exit loop if x19 <= x20 (unsigned)
  sub     x19, x19, #1
  mov     x0, x19
  mov     w1, w21
  bl      poke_address
  b       1b
2:
  mov     w5, 2
  strb    w5, [x28, DF_SZ-sysvars]                // Set the lower screen size to two rows.
  bl      cl_chan
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# Reset the system channel input and output addresses.
#
# On entry:
# On exit:
#     [CURCHL] = address in CHANS block of channel K
#     [FLAGS] : clears bit 1 and bit 5 => Printer not in use and no new key
#     [FLAGS2] : sets bit 4 => Channel K in use
#     [TV_FLAG] : sets bit 0 => Lower screen in use
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : temp bits cleared
#     [[CURCHL]] = print_out    (Channel K output routine)
#     [[CURCHL]+8] = key_input  (Channel K input routine)
#     [S_POSN_Y_L] = 59
#     [S_POSN_X_L] = 109
#     [ECHO_E_Y] = 59
#     [ECHO_E_X] = 109
#     [DF_CC_L] = display_file + ((61-[DF_SZ])/20)*216*16*20 + 216*(61-[DF_SZ])%20)
#     x0 = 59
#     x1 = 109
#     x2 = display_file + ((61-[DF_SZ])/20)*216*16*20 + 216*(61-[DF_SZ])%20)
#     w3 = [TV_FLAG]
#     w4 = (61-[DF_SZ])%20
#     w5 = 216
#     w6 = 0x10e00
#     w9 = [FLAGS2]
#     x10 = 'K'
#     NZCV = 0b0110
cl_chan:                                 // L0D94
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     x0, #-3                                 // Stream -3 (-> channel K)
  bl      chan_open                               // Open channel K.
  ldr     x0, [x28, CURCHL-sysvars]               // x0 = [CURCHL]
  adr     x1, print_out
  str     x1, [x0], #8                            // Reset output routine to print_out for channel K.
  adr     x1, key_input
  str     x1, [x0], #8                            // Reset input routine to key_input for channel K.
  mov     x0, 59                                  // screen row (120-[DF_SZ]-59)=screen row 59 for channel K.
  mov     x1, 109                                 // reversed column = 109 => column = 0 (109-column)
  bl      cl_set                                  // Save new position in system variables.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# ---------------------------
# Clearing whole display area
# ---------------------------
# This subroutine called from CLS, AUTO-LIST and MAIN-3
# clears 24 lines of the display and resets the relevant system variables
# and system channels.
cl_all:                                  // L0DAF
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  str     wzr, [x28, COORDS-sysvars]              // set COORDS to 0,0.
  ldrb    w9, [x28, FLAGS2-sysvars]               // w9 = [FLAGS2]
  and     w9, w9, #0xfe                           // w9 = [FLAGS2] with bit 0 clear
  strb    w9, [x28, FLAGS2-sysvars]               // Update [FLAGS2] to have bit 0 clear (signal main screen is clear).
  bl      cl_chan
  mov     x0, #-2                                 // Select system channel 'S'.
  bl      chan_open                               // Routine chan_open opens it.
  bl      temps                                   // Routine temps picks up permanent values.
  mov     x0, #60                                 // There are 60 lines.
  bl      cl_line                                 // Routine cl_line clears all 60 lines.
  ldr     x0, [x28, CURCHL-sysvars]               // x0 = [CURCHL] (channel 'S')
  adr     x1, print_out
  str     x1, [x0], #8                            // Reset output routine to print_out for channel S.
  mov     w0, 1
  strb    w0, [x28, SCR_CT-sysvars]               // Reset SCR_CT (scroll count) to default of 1.
  mov     x0, 60                                  // reversed row = 60 => row = 0 (row = 60 - reversed row)
  mov     x1, 109                                 // reversed column = 109 => column = 0 (column = 109 - reversed column)
  bl      cl_set                                  // Save new position in system variables.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# ---------------------------
# Set line and column numbers
# ---------------------------
# Calculate the character output address for screens or printer based on the
# line/column for screens for current K/S/P channel.
#
# On entry:
#
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     for K: x0 = 120 - [DF_SZ] - actual screen row (x0 range: 1 -> 60)
#     for S: x0 = 60 - actual screen row (x0 range: 1 -> 60)
#     for P: x0 not used since printer buffer is a single line, so no Y coordinate
#   w1 = 109 - actual column
#     from 109 (leftmost column) to 2 (rightmost column) or 1 indicates entire
#     line printed, but no explicit carriage return (so lines needn't be
#     scrolled, and backspace still possible on printer).
#
# On exit:
#
#   If upper screen in use (bit 1 of FLAGS clear and bit 0 of TV_FLAG clear):
#     [S_POSN_Y] = x0
#     [S_POSN_X] = x1
#     [DF_CC] = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#     x2 = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#     w3 = [TV_FLAG]
#     w4 = (60-x0)%20
#     w5 = 216
#     w6 = 0x10e00
#
#   If lower screen in use (bit 1 of FLAGS clear and bit 0 of TV_FLAG set):
#     [S_POSN_Y_L] = x0
#     [S_POSN_X_L] = x1
#     [ECHO_E_Y] = x0
#     [ECHO_E_X] = x1
#     [DF_CC_L] = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#     x2 = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#     w3 = [TV_FLAG]
#     w4 = (120-x0-[DF_SZ])%20
#     w5 = 216
#     w6 = 0x10e00
#
#   If printer in use (bit 1 of FLAGS set):
#     [P_POSN_X] = x1
#     [PR_CC] = printer_buffer + 109 - x1
#     x2 = printer_buffer + 109 - x1
#     w3 = [FLAGS]
cl_set:                                  // L0DD9
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w3, [x28, FLAGS-sysvars]
  tbnz    w3, #1, 2f                              // If printer is in use, jump to 2:.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  mov     x19, x0                                 // Stash x0
  mov     x20, x1                                 // Stash x1
  ldrb    w4, [x28, TV_FLAG-sysvars]
  tbz     w4, #0, 1f                              // If upper screen in use, jump to 1:.
                                                  // Lower screen in use.
  ldrb    w5, [x28, DF_SZ-sysvars]
  add     w0, w0, w5
  sub     w0, w0, #60                             // w0 = 60 - actual row number
1:
  bl      cl_addr                                 // x2 = address of top left pixel of row
  mov     x1, x20                                 // Restore stashed x1.
  mov     x0, x19                                 // Restore stashed x0.
  add     x2, x2, #218                            // x2 = address of top left pixel of row + 218
  sub     x2, x2, x1, lsl #1                      // x2 = address of top left pixel of row + 218 - 2 * (109 - screen column)
                                                  //    = address of top left pixel of char
  ldp     x19, x20, [sp], #16                     // Restore old x19, x20.
  b       3f
2:
  adr     x2, printer_buffer+109
  sub     x2, x2, x1                              // x2 = address inside printer buffer to write char
3:
  bl      po_store
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# ---------------------------
# Clear text lines of display
# ---------------------------
# This subroutine, called from cl_all, cls_lower and auto_list and above,
# clears text lines at bottom of display.
#
# On entry:
#   x0 = number of lines to be cleared (1-60)
# On exit:
#   x0/x1/x2/x3/x4/x5/x6 corrupted
#   plus whatever poke_address also corrupts
cl_line:                                 // L0E44
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!                   // Backup x23 / x24 on stack.
  stp     x25, x26, [sp, #-16]!                   // Backup x25 / x26 on stack.
  mov     x19, x0                                 // x19 = number of lines to be cleared (1-60)
  bl      cl_addr                                 // Routine CL-ADDR gets top address.
                                                  //   x0 = number of lines to be cleared (1-60)
                                                  //   x1 = start line number to clear
                                                  //   x2 = address of top left pixel of line to clear inside display file
                                                  //   x3 = first screen third to clear (0-2)
                                                  //   x4 = start char line inside first screen third to clear (0-19)
  mov     x5, #216
  mov     x6, #0x10e0
  umsubl  x19, w4, w5, x6                         // x19 = number of lines in top screen third * 216 = byte count for one pixel row across first screen third
  umull   x20, w0, w5                             // x20 = 216 * line count
  mov     x22, x3                                 // x22 = top screen section (0/1/2)
#
  // counters
  mov     x26, x2                                 // x26 = address of first pixel in first section of current pixel row
  mov     w23, #16                                // x23 = number of remaining pixel lines to clear (0-15)
2:
  mov     x21, x26                                // x21 = address of next byte to clear
  mov     x24, x19                                // x24 = number of remaining bytes to clear in current loop
  mov     x25, x22                                // x25 = current screen section (0-2)
3:
  mov     x0, x21
  mov     x1, #0
  bl      poke_address
  add     x21, x21, #1
  subs    x24, x24, #1                            // Reduce byte counter.
  b.ne    3b                                      // Repeat until all rows are cleared.
  add     x21, x21, #0x00f, lsl #12               // x21 += 216*15*20 (=0xfd20) to reach same pixel row in first char line of next
  add     x21, x21, #0xd20                        // screen third.
  mov     x24, #4320                              // x24 = 20 lines * 216 bytes = 4320 bytes
  add     x25, x25, #1                            // x22 = next screen third to update
  cmp     x25, #3
  b.ne    3b                                      // Repeat if more sections to update
  add     x26, x26, #0x001, lsl #12               // Next row pixel address = previous base address + 216 bytes * 20 rows
  add     x26, x26, #0x0e0                        // = previous base address + 4320 bytes = previous + 0x10e0 bytes
  subs    w23, w23, #1                            // Decrease text line pixel counter.
  b.ne    2b                                      // Repeat if not all screen lines of text have been cleared.
  adr     x21, attributes_file_end                // x21 = first byte after end of attributes file.
  sub     x22, x21, x20, lsr #1                   // x22 = start address in attributes file to clear
  ldrb    w19, [x28, TV_FLAG-sysvars]             // w19[0-7] = [TV_FLAG]
  tbz     w19, #0, 4f                             // If bit 0 is clear, lower screen is in use; jump ahead to 4:.
  ldrb    w20, [x28, BORDCR-sysvars]
  b       5f
4:
  ldrb    w20, [x28, ATTR_P-sysvars]
5:
  mov     x0, x22
  mov     w1, w20
  bl      poke_address
  add     x22, x22, #1
  cmp     x22, x21
  b.lo    5b                                      // Repeat iff x22 < x21
  ldp     x25, x26, [sp], #0x10                   // Restore old x25, x26.
  ldp     x23, x24, [sp], #0x10                   // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# -------------------------------
# Handle display with line number
# -------------------------------
# This subroutine is called from four places to calculate the address
# of the start of a screen character line.
#
# On entry:
#   x0 = 60 - screen line
# On exit:
#   x1 = screen line
#   x2 = address of top left pixel of line to clear inside display file
#   x3 = screen line / 20
#   x4 = screen line % 20
#   x5 = 216
#   x6 = 69120 (0x10e00)
cl_addr:                                 // L0E9B
  mov     x1, #60
  sub     x1, x1, x0
  adr     x2, display_file
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                              // x3 = 0x0xcccccccccccccccd
  umulh   x3, x3, x1                              // x3 = 14757395258967641293 * x1 / 2^64 = int(0.8*x1)
  lsr     x3, x3, #4                              // x3 = int(x1/20)
  add     x4, x3, x3, lsl #2                      // x4 = 5 * int(x1/20)
  sub     x4, x1, x4, lsl #2                      // x4 = x1 - 20 * int(x1/20) = x1%20
  mov     x5, #216
  umaddl  x2, w4, w5, x2                          // x2 = display_file + (x1%20)*216
  mov     x6, 0x00010000
  movk    x6, 0xe00
  umaddl  x2, w6, w3, x2                          // x2 = display_file + (x1%20)*216 + (x1/20)*69120
  ret


# ------------------------------
# Pass printer buffer to printer
# ------------------------------
# This routine is used to copy 16 pixel lines from the printer buffer
# to the printer.
copy_buff:                               // L0ECD
  // TODO
  ret


# ------------------------
# Add code to current line
# ------------------------
# this is the branch used to add normal non-control characters
# with ED-LOOP as the stacked return address.
# it is also the OUTPUT service routine for system channel 'R'.
add_char:                                // L0F81
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w9, [x28, MODE-sysvars]                 // w9 = [MODE].
  and     w9, w9, #~0x01                          // w9 = [MODE] with bit 0 clear.
  strb    w9, [x28, MODE-sysvars]                 // Update [MODE] to have bit 0 clear (Mode 'L').
  ldr     x5, [x28, K_CUR-sysvars]                // fetch address of keyboard cursor from K_CUR
  bl      one_space
  bl      add_ch_1
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


add_ch_1:
  // TODO
  ret

# ---------------------
# Handle keyboard input
# ---------------------
# This is the service routine for the input stream of the keyboard
# channel 'K'.
key_input:                               // L10A8
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ------------
# Open channel
# ------------
# This subroutine opens channel 'K', 'S', 'R', 'P' or a custom user channel. This
# is either called directly, or in response to a user's request, for example,
# when '#' is encountered with output - PRINT/LIST/... or with input -
# INPUT/INKEY$/... It is entered with a system stream -3 to -1, or a user stream
# 0 to 15.
#
# On entry:
#   x0 = stream number in range [-3,15]
#
# On exit:
#   If Channel K:
#     [CURCHL] = address in CHANS block of Channel K
#     [FLAGS] : clears bit 1 and bit 5 => Printer not in use and no new key
#     [FLAGS2] : sets bit 4 => Channel K in use
#     [TV_FLAG] : sets bit 0 => Lower screen in use
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : temp bits cleared
#     x0 = [P_FLAG]
#     x1 = [BORDCR]
#     x2 = chan_k
#     w9 = [FLAGS2]
#     x10 = 'K'
#     NZCV = 0b0110
#
#   If Channel S:
#     [CURCHL] = address in CHANS block of Channel S
#     [FLAGS] : clears bit 1 => Printer not in use
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     [TV_FLAG] : clears bit 0 => Lower screen not in use
#     [ATTR_T] = [ATTR_P]
#     [MASK_T] = [MASK_P]
#     [P_FLAG] : perm bits copied to temp bits
#     x0 = [P_FLAG]
#     x1 = ([MASK_P] << 8) | [ATTR_P]
#     x2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
#     x9 = 0x01
#     x10 = 'S'
#     NZCV = 0b0110
#
#   If Channel P:
#     [CURCHL] = address in CHANS block of Channel P
#     [FLAGS] : sets bit 1 => Printer in use
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     w0 = [FLAGS]
#     x1 = chn_cd_lu + 0x28
#     x2 = chan_p
#     x9 = 0x00
#     x10 = 'P'
#     NZCV = 0b0110
#
#   If Channel R / custom user channel:
#     [CURCHL] = address in CHANS block of Channel R / custom user channel
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     x0 = 'R'
#     x1 = 0x00
#     x9 = 0x00
#     x10 = 'P' (last key in chn-cd-lu table)
#     NZCV = 0b0010 (cmp 'R', 'P')
chan_open:                               // L1601
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     x9, x28, x0, lsl #1                     // x9 = sysvars + stream number * 2
  ldrh    w10, [x9, STRMS-sysvars+6]              // w10 = [stream number * 2 + STRMS + 6] = CHANS offset + 1
  cbnz    w10, 1f                                 // Non-zero indicates channel open, in which case continue
  mov     x0, 0x17                                // Error Report: Invalid stream
// TODO: check if this should be `b` instead of `bl` followed by `b 2f`.
//   bl      error_1
  b       2f
1:
  ldr     x9, [x28, CHANS-sysvars]                // x9 = [CHANS]
  add     x10, x10, x9                            // w10 = [CHANS] + CHANS offset + 1
  sub     x0, x10, #1                             // x0 = address of channel data in CHANS
  bl      chan_flag
2:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# -----------------
# Set channel flags
# -----------------
# This subroutine is used from ED-EDIT, str$ and read-in to reset the
# current channel when it has been temporarily altered.
#
# On entry:
#
#   x0 = address of channel information inside CHANS
#
# On exit:
#
#   K Channel:
#     [CURCHL] = x0
#     [FLAGS] : clears bit 1 and bit 5
#     [FLAGS2] : sets bit 4
#     [TV_FLAG] : sets bit 0
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : clears temp bits
#     w0 = new [P_FLAG]
#     w1 = [BORDCR]
#     x2 = chan_k
#     w9 = [FLAGS2]
#     x10 = 'K'
#     NZCV = 0b0110
#
#   S Channel:
#     [CURCHL] = x0
#     [FLAGS] : clears bit 1 => Printer not in use
#     [FLAGS2] : clears bit 4
#     [TV_FLAG] : clears bit 0 => Main screen in use
#     [ATTR_T] = [ATTR_P]
#     [MASK_T] = [MASK_P]
#     [P_FLAG] : Copies perm bits to temp bits
#     w0 = new [P_FLAG]
#     w1 = ([MASK_P] << 8) | [ATTR_P]
#     x2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
#     w9 = 1
#     x10 = 'S'
#     NZCV = 0b0110
#
#   P Channel:
#     [CURCHL] = x0
#     [FLAGS] : sets bit 1 => Printer in use
#     [FLAGS2] : clears bit 4
#     w0 = new [P_FLAG]
#     x1 = chn_cd_lu + 0x28
#     x2 = chan_p
#     x9 = 0
#     x10 = 'P'
#
#   R Channel / custom user channel:
#     [CURCHL] = x0
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     x0 = 'R'
#     x1 = 0x00
#     x9 = 0x00
#     x10 = 'P' (last key in chn-cd-lu table)
#     NZCV = 0b0010 (cmp 'R', 'P')
chan_flag:                               // L1615
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  str     x0, [x28, CURCHL-sysvars]               // [CURCHL] = CHANS record address
  ldrb    w9, [x28, FLAGS2-sysvars]               // w9 = [FLAGS2].
  and     w9, w9, #~0x10                          // w9 = [FLAGS2] with bit 4 clear.
  strb    w9, [x28, FLAGS2-sysvars]               // Update [FLAGS2] to have bit 4 clear (signal K channel not in use).
  ldr     x0, [x0, 16]                            // w0 = channel letter (stored at CHANS record address + 16)
  adr     x1, chn_cd_lu                           // x1 = address of flag setting routine lookup table
  bl      indexer                                 // look up flag setting routine
  cbz     x1, 1f                                  // If not found then there is no routine (channel 'R' or custom user channel) to call.
  blr     x2                                      // Call flag setting routine.
1:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# --------------------------
# Channel code look-up table
# --------------------------
# This table is used to find one of the three flag setting routines. A zero
# end-marker is required as channel 'R' is not present.
.align 3
chn_cd_lu:                               // L162D
  .quad 0x0000000000000003                        // 3 records
  .byte 'K',0,0,0,0,0,0,0                         // 0x4B - Channel identifier 'K'.
  .quad chan_k
  .byte 'S',0,0,0,0,0,0,0                         // 0x53 - Channel identifier 'S'.
  .quad chan_s
  .byte 'P',0,0,0,0,0,0,0                         // 0x50 - Channel identifier 'P'.
  .quad chan_p


# --------------
# Channel K flag
# --------------
# Flag setting routine for lower screen/keyboard channel ('K' channel).
#
# On entry:
# On exit:
#   [TV_FLAG] : set bit 0
#   [FLAGS] : clear bit 1 and bit 5
#   [FLAGS2] : set bit 4
#   [ATTR_T] = [BORDCR]
#   [MASK_T] = 0
#   [P_FLAG] : temp (even) bits set to zero
#   w0 = new [P_FLAG]
#   w1 = [BORDCR]
#   w9 = [FLAGS2]
chan_k:                                  // L1634
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w9, [x28, TV_FLAG-sysvars]              // w9[0-7] = [TV_FLAG]
  orr     w9, w9, #0x00000001                     // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w9[0-7]
  ldrb    w9, [x28, FLAGS-sysvars]                // w9[0-7] = [FLAGS]
  and     w9, w9, #0xdddddddd                     // Clear bit 1 (printer not in use) and bit 5 (no new key).
                                                  // See https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64
                                                  // for choice of #0xdddddddd
  strb    w9, [x28, FLAGS-sysvars]                // [FLAGS] = w9[0-7]
  ldrb    w9, [x28, FLAGS2-sysvars]               // w9[0-7] = [FLAGS2]
  orr     w9, w9, #0x00000010                     // Set bit 4 of FLAGS2 - signal K channel in use.
  strb    w9, [x28, FLAGS2-sysvars]               // [FLAGS2] = w9[0-7]
  bl      temps                                   // Set temporary attributes.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# --------------
# Channel S flag
# --------------
# Flag setting routine for upper screen channel ('S' channel).
#
# On entry:
# On exit:
#   [TV_FLAG] - clears bit 0 to signal main screen in use.
#   [FLAGS] - clears bit 1 to signal printer not in use.
#   [ATTR_T] = [ATTR_P]
#   [MASK_T] = [MASK_P]
#   [P_FLAG] = perm copied to temp bits
#   w0 = new [P_FLAG]
#   w1 = ([MASK_P] << 8) | [ATTR_P]
#   w2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
chan_s:                                  // L1642
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, #~0x01                          // Clear bit 0 - signal main screen in use.
  strb    w0, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w0[0-7]
  ldrb    w0, [x28, FLAGS-sysvars]
  and     w0, w0, #0xfffffffd                     // Clear bit 1 - signal printer not in use.
  strb    w0, [x28, FLAGS-sysvars]                // [FLAGS] = w0[0-7]
  bl      temps
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


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

# -----------------------
# Just one space required
# -----------------------
# This routine is called once only to create a single space
# in workspace by ADD-CHAR. It is slightly quicker than using a RST 30H.
# There are several instances in the calculator where the sequence
# ld bc, 1; rst $30 could be replaced by a call to this routine but it
# only gives a saving of one byte each time.
one_space:
  // TODO
  ret


# --------------------------
# The Table INDEXING routine
# --------------------------
# Routine indexer searches an in-memory key/value store for x0.
#
# Keys and values are double words (64 bit values). Each record contains a single
# key and a single value. Keys and values may have unrestricted 64 bit values.
#
# The structure of the key/value store is:
#
#   uint64: number of records
#   [
#     uint64: key
#     uint64: value
#   ] * number of records
#
# Therefore the size of the store is [ 2*(number of records)+1 ] * 8 bytes (since
# 64 bits require 8 bytes of storage).
#
# * The key/value store must be 8 byte aligned in memory.
# * Records may be stored in an arbitrary order; however if a duplicate key exists,
#   the record with the lowest address in memory will take precendence.
# * Callers should check for non-zero x1 before using x2.
#
# On entry:
#   x0 = 64 bit key to search for
#   x1 = address of key/value store (8 byte aligned)
#
# On exit:
#   x0 unchanged
#   x1 = address of 64 bit key if found, otherwise 0
#   x2 = 64 bit value for key if found, otherwise unchanged
#   x9 = number of records after found key
#  x10 = x0 if found, otherwise value of last key in table
#  NZCV = result of `cmp x0, x10` (0b0110 if key found)
indexer:                                 // L16DC
  ldr     x9, [x1], #-8                           // x9 = number of records
                                                  // x1 = lookup table address - 8 = address of first record - 16
1:
  cbz     x9, 2f                                  // If all records have been exhausted, jump forward to 2:.
  ldr     x10, [x1, #16]!                         // Load key at x1+16 into x10, and proactively increase x1 by 16 for the next iteration.
  sub     x9, x9, 1                               // x9 = number of remaining records to check (which is now one less)
  cmp     x0, x10                                 // Check if key matches wanted key.
  b.ne    1b                                      // If not, loop back to 1:.
  ldr     x2, [x1, #8]                            // Key matches, set x2 to the value stored in x1 + 8, and leave x1 as it is.
  b       3f                                      // Jump forward to 3:.
2:
  mov     x1, 0                                   // Set x1 to zero to indicate value wasn't found.
3:
  ret


report_j:                                // L15C4
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


report_bb:                               // L1E9F
  // TODO


co_temp_5:                               // L2211
  // TODO


# Print tokens and user defined graphics (chars 0x90-0xff).
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = char (144-255)
print_token_udg_patch:                   // L3B9F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  cmp     w3, #0xa3                               // Is char 'SPECTRUM' (128K mode) / UDG T (48K mode)?
  b.eq    2f                                      // If so, jump forward to 2:.
  cmp     w3, #0xa4                               // Is char 'PLAY' (128K mode) / UDG U (48K mode)?
  b.eq    2f                                      // If so, jump forward to 2:.
1:
  subs    w3, w3, #0xa5                           // w3 = (char - 165)
  b.pl    3f                                      // If char is token (w3 >= 0) jump forward to 3:.
  // UDG character
  bl      rejoin_po_t_udg                         // Rejoin 48K BASIC routine.
  b       5f                                      // Exit routine.
2:
  // SPECTRUM/PLAY token (128K mode) or T/U UDG (48K mode)

  // TODO: See if we can find an alternative unused register for storing FLAGS
  // in, since we read it multiple times below.

  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbz     w4, #4, 1b                              // If in 48K mode, jump back to 1:.
  // SPECTRUM or PLAY token in 128K mode
  adr     x4, tkn_spectrum                        // x4 = address of "SPECTRUM" string
  adr     x5, tkn_play                            // x5 = address of "PLAY" string
  subs    w3, w3, #0xa3                           // w3 = 0 for "SPECTRUM" or 1 for "PLAY"
  csel    x4, x4, x5, eq                          // x4 = correct address for token string
  mov     w5, #0x04                               // Indicate trailing space required
  // TODO: check if any registers need to be preserved here
  bl      po_table_1                              // Print SPECTRUM or PLAY.
  // TODO: set carry flag??? Why???
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 5f                              // If printer in use, jump forward to 4:.
  // Printer not in use
  b       4f
3:
  bl      po_tokens
4:
  bl      po_fetch
5:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


tkn_spectrum:                            // L3BD2
  .asciz "SPECTRUM"

tkn_play:                                // L3BDA
  .asciz "PLAY"
