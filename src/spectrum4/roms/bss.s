# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.bss

bss_start:

.align 4                                          // Make sure sysvars at least start at a reasonable boundary (16 byte)
                                                  // to aid caching, simplify copying memory block, etc.

sysvars:
.align 0
COL:             .space 1                         // L5B63: Current column from 1 to WIDTH. Set to 0 by NEW command.
WIDTH:           .space 1                         // L5B64: Paper column width. Default value of 80.
TVPARS:          .space 1                         // L5B65: Number of inline parameters expected by RS232 (e.g. 2 for AT).
RASP:            .space 1                         // L5C38: Length of warning buzz.
PIP:             .space 1                         // L5C39: Length of keyboard click.
FLAGS:           .space 1                         // L5C3B: Flags to control the BASIC system:
                                                  //   Bit 0: 1=Suppress leading space.
                                                  //   Bit 1: 1=Using printer, 0=Using screen.
                                                  //   Bit 2: 1=Print in L-Mode, 0=Print in K-Mode.
                                                  //   Bit 3: 1=L-Mode, 0=K-Mode.
                                                  //   Bit 4: 1=128K Mode, 0=48K Mode. [Always 0 on 48K Spectrum].
                                                  //   Bit 5: 1=New key press code available in LAST_K.
                                                  //   Bit 6: 1=Numeric variable, 0=String variable.
                                                  //   Bit 7: 1=Line execution, 0=Syntax checking.
FLAGS2:          .space 1                         // L5C6A: Flags:
                                                  //   Bit 0  : 1=Screen requires clearing.
                                                  //   Bit 1  : 1=Printer buffer contains data.
                                                  //   Bit 2  : 1=In quotes.
                                                  //   Bit 3  : 1=CAPS LOCK on.
                                                  //   Bit 4  : 1=Using channel 'K'.
                                                  //   Bit 5-7: Not used (always 0).
FLAGS3:          .space 1                         // L5B66: Flags: [Name clashes with the ZX Interface 1 system variable at $5CB6]
                                                  //   Bit 0: 1=BASIC/Calculator mode, 0=Editor/Menu mode.
                                                  //   Bit 1: 1=Auto-run loaded BASIC program. [Set but never tested by the ROM]
                                                  //   Bit 2: 1=Editing RAM disk catalogue.
                                                  //   Bit 3: 1=Using RAM disk commands, 0=Using cassette commands.
                                                  //   Bit 4: 1=Indicate LOAD.
                                                  //   Bit 5: 1=Indicate SAVE.
                                                  //   Bit 6; 1=Indicate MERGE.
                                                  //   Bit 7: 1=Indicate VERIFY.
TV_FLAG:         .space 1                         // L5C3C: Flags associated with the TV:
                                                  //   Bit 0  : 1=Using lower editing area, 0=Using main screen.
                                                  //   Bit 1-2: Not used (always 0).
                                                  //   Bit 3  : 1=Mode might have changed.
                                                  //   Bit 4  : 1=Automatic listing in main screen, 0=Ordinary listing in main screen.
                                                  //   Bit 5  : 1=Lower screen requires clearing after a key press.
                                                  //   Bit 6  : 1=Tape Loader option selected (set but never tested). [Always 0 on 48K Spectrum]
                                                  //   Bit 7  : Not used (always 0).
BORDCR:          .space 1                         // L5C48: Border colour multiplied by 8; also contains the attributes normally used for the lower half.
ERR_NR:          .space 1                         // L5C3A: 1 less than the report code. Starts off at 255 (for -1).
DF_SZ:           .space 1                         // L5C6B: The number of lines (including one blank line) in the lower part of the screen. (1-60)
SCR_CT:          .space 1                         // L5C8C: Counts scrolls - it is always 1 more than the number of scrolls that will be done before
                                                  // stopping with 'scroll?'.
P_POSN_X:        .space 1                         // L5C7F: 109-column number of printer position.
ECHO_E_X:        .space 1                         // L5C82: 109-column number (in lower half) of end of input buffer.
ECHO_E_Y:        .space 1                         // L5C83: 60-line number (in lower half) of end of input buffer.
S_POSN_X:        .space 1                         // L5C88: 109-column number for PRINT position.
S_POSN_Y:        .space 1                         // L5C89: 60-line number for PRINT position.
S_POSN_X_L:      .space 1                         // L5C8A: Like S_POSN_X for lower part.
S_POSN_Y_L:      .space 1                         // L5C8B: Like S_POSN_Y for lower part.
P_FLAG:          .space 1                         // L5C91: Flags:
                                                  //   Bit 0: Temporary 1=OVER 1, 0=OVER 0.
                                                  //   Bit 1: Permanent 1=OVER 1, 0=OVER 0.
                                                  //   Bit 2: Temporary 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 3: Permanent 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 4: Temporary 1=Using INK 9.
                                                  //   Bit 5: Permanent 1=Using INK 9.
                                                  //   Bit 6: Temporary 1=Using PAPER 9.
                                                  //   Bit 7: Permanent 1=Using PAPER 9.
BREG:            .space 1                         // L5C67: Calculator's B register.
ATTR_P:          .space 1                         // L5C8D: Permanent current colours, etc, as set up by colour statements.
MASK_P:          .space 1                         // L5C8E: Used for transparent colours, etc. Any bit that is 1 takes value from current attribute value, 0 from ATTR_P/T.
ATTR_T:          .space 1                         // L5C8F: Temporary current colours (as set up by colour items).
MASK_T:          .space 1                         // L5C90: Like MASK_P, but temporary.
MODE:            .space 1                         // L5C41: Specifies cursor type:
                                                  //   $00='L' or 'C'.
                                                  //   $01='E'.
                                                  //   $02='G'.
                                                  //   $04='K'.

# --------------------------
# Editor Workspace Variables
# --------------------------
# These occupy addresses $EC00-$FFFF in physical RAM bank 7, and form a workspace used by 128 BASIC Editor.
#
EC00:            .space 3                         // Byte 0: Flags used when inserting a line into the BASIC program (first 4 bits are mutually exclusive).
                                                  //   Bit 0: 1=First row of the BASIC line off top of screen.
                                                  //   Bit 1: 1=On first row of the BASIC line.
                                                  //   Bit 2: 1=Using lower screen and only first row of the BASIC line visible.
                                                  //   Bit 3: 1=At the end of the last row of the BASIC line.
                                                  //   Bit 4: Not used (always 0).
                                                  //   Bit 5: Not used (always 0).
                                                  //   Bit 6: Not used (always 0).
                                                  //   Bit 7: 1=Column with cursor not yet found.
                                                  // Byte 1: Column number of current position within the BASIC line being inserted. Used when fetching characters.
                                                  // Byte 2: Row number of current position within the BASIC line is being inserted. Used when fetching characters.
EC03:            .space 3                         // Byte 0: Flags used upon an error when inserting a line into the BASIC program (first 4 bits are mutually exclusive).
                                                  //   Bit 0: 1=First row of the BASIC line off top of screen.
                                                  //   Bit 1: 1=On first row of the BASIC line.
                                                  //   Bit 2: 1=Using lower screen and only first row of the BASIC line visible.
                                                  //   Bit 3: 1=At the end of the last row of the BASIC line.
                                                  //   Bit 4: Not used (always 0).
                                                  //   Bit 5: Not used (always 0).
                                                  //   Bit 6: Not used (always 0).
                                                  //   Bit 7: 1=Column with cursor not yet found.
                                                  // Byte 1: Start column number where BASIC line is being entered. Always holds 0.
                                                  // Byte 2: Start row number where BASIC line is being entered.
EC0C:            .space 1                         // Current menu index.
EC0D:            .space 1                         // Flags used by 128 BASIC Editor:
                                                  //   Bit 0: 1=Screen Line Edit Buffer (including Below-Screen Line Edit Buffer) is full.
                                                  //   Bit 1: 1=Menu is displayed.
                                                  //   Bit 2: 1=Using RAM disk.
                                                  //   Bit 3: 1=Current line has been altered.
                                                  //   Bit 4: 1=Return to calculator, 0=Return to main menu.
                                                  //   Bit 5: 1=Do not process the BASIC line (used by the Calculator).
                                                  //   Bit 6: 1=Editing area is the lower screen, 0=Editing area is the main screen.
                                                  //   Bit 7: 1=Waiting for key press, 0=Got key press.
EC0E:            .space 1                         // Mode:
                                                  //   $00 = Edit Menu mode.
                                                  //   $04 = Calculator mode.
                                                  //   $07 = Tape Loader mode. [Effectively not used as overwritten by $FF]
                                                  //   $FF = Tape Loader mode.
EC0F:            .space 1                         // Main screen colours used by the 128 BASIC Editor - alternate ATTR_P.
EC10:            .space 1                         // Main screen colours used by the 128 BASIC Editor - alternate MASK_P.
EC11:            .space 1                         // Temporary screen colours used by the 128 BASIC Editor - alternate ATTR_T.
EC12:            .space 1                         // Temporary screen colours used by the 128 BASIC Editor - alternate MASK_T.
EC13:            .space 1                         // Temporary store for P_FLAG:
                                                  //   Bit 0: 1=OVER 1, 0=OVER 0.
                                                  //   Bit 1: Not used (always 0).
                                                  //   Bit 2: 1=INVERSE 1, INVERSE 0.
                                                  //   Bit 3: Not used (always 0).
                                                  //   Bit 4: 1=Using INK 9.
                                                  //   Bit 5: Not used (always 0).
                                                  //   Bit 6: 1=Using PAPER 9.
                                                  //   Bit 7: Not used (always 0).
EC14:            .space 1                         // Not used.
EC15:            .space 1                         // Holds the number of editing lines: 20 for the main screen, 1 for the lower screen.

# $EC16  735   Screen Line Edit Buffer. This represents the text on screen that can be edited. It holds 21 rows,
#              with each row consisting of 32 characters followed by 3 data bytes. Areas of white
#              space that do not contain any editable characters (e.g. the indent that starts subsequent
#              rows of a BASIC line) contain the value $00.
#                Data Byte 0:
#                  Bit 0: 1=The first row of the BASIC line.
#                  Bit 1: 1=Spans onto next row.
#                  Bit 2: Not used (always 0).
#                  Bit 3: 1=The last row of the BASIC line.
#                  Bit 4: 1=Associated line number stored.
#                  Bit 5: Not used (always 0).
#                  Bit 6: Not used (always 0).
#                  Bit 7: Not used (always 0).
#                Data Bytes 1-2: Line number of corresponding BASIC line (stored for the first row of the BASIC line only, holds $0000).
# $EEF5    1   Flags used when listing the BASIC program:
#                Bit 0   : 0=Not on the current line, 1=On the current line.
#                Bit 1   : 0=Previously found the current line, 1=Not yet found the current line.
#                Bit 2   : 0=Enable display file updates, 1=Disable display file updates.
#                Bits 3-7: Not used (always 0).
# $EEF6    1   Store for temporarily saving the value of TV_FLAG.
# $EEF7    1   Store for temporarily saving the value of COORDS.
# $EEF9    1   Store for temporarily saving the value of P_POSN_X.
# $EEFA    2   Store for temporarily saving the value of PR_CC.
# $EEFC    1   Store for temporarily saving the value of ECHO_E_X.
# $EEFD    1   Store for temporarily saving the value of ECHO_E_Y.
# $EEFE    2   Store for temporarily saving the value of DF_CC.

# something not quite right here - we need two bytes for DF_CC_L, but the comments claim that S_POSN_X is stored at $EF01
# $EF00    2   Store for temporarily saving the value of DF_CC_L.

# $EF01    1   Store for temporarily saving the value of S_POSN_X.
# $EF02    1   Store for temporarily saving the value of S_POSN_Y.
# $EF03    1   Store for temporarily saving the value of S_POSN_X_L.
# $EF04    1   Store for temporarily saving the value of S_POSN_Y_L.
# $EF05    1   Store for temporarily saving the value of SCR_CT.
# $EF06    1   Store for temporarily saving the value of ATTR_P.
# $EF07    1   Store for temporarily saving the value of MASK_P.
# $EF08    1   Store for temporarily saving the value of ATTR_T.
# $EF09 1512   Used to store screen area (12 rows of 14 columns) where menu will be shown.
#              The rows are stored one after the other, with each row consisting of the following:
#                - 8 lines of 14 display file bytes.
#                - 14 attribute file bytes.
# $F4F1-$F6E9  Not used. 505 bytes.
# $F6F4    1   Flags used when deleting:
#                Bit 0   : 1=Deleting on last row of the BASIC line, 0=Deleting on row other than the last row of the BASIC line.
#                Bits 1-7: Not used (always 0).
# $F6F5    1   Number of rows held in the Below-Screen Line Edit Buffer.
# $F6F6    2   Intended to point to the next location to access within the Below-Screen Line Edit Buffer, but incorrectly initialised to $0000 by the routine at $30D6 (ROM 0) and then never used.
# $F6F8  735   Below-Screen Line Edit Buffer. Holds the remainder of a BASIC line that has overflowed off the bottom of the Screen Line Edit Buffer. It can hold 21 rows, with each row
#              consisting of 32 characters followed by 3 data bytes. Areas of white space that do not contain any editable characters (e.g. the indent that starts subsequent rows of a BASIC line)
#              contain the value $00.
#                Data Byte 0:
#                  Bit 0: 1=The first row of the BASIC line.
#                  Bit 1: 1=Spans onto next row.
#                  Bit 2: Not used (always 0).
#                  Bit 3: 1=The last row of the BASIC line.
#                  Bit 4: 1=Associated line number stored.
#                  Bit 5: Not used (always 0).
#                  Bit 6: Not used (always 0).
#                  Bit 7: Not used (always 0).
#                Data Bytes 1-2: Line number of corresponding BASIC line (stored for the first row of the BASIC line only, holds $0000).
# $F9D7    2   Line number of the BASIC line in the program area being edited (or $0000 for no line).
# $F9DB    1   Number of rows held in the Above-Screen Line Edit Buffer.
# $F9DC    2   Points to the next location to access within the Above-Screen Line Edit Buffer.
# $F9DE  700   Above-Screen Line Edit Buffer. Holds the rows of a BASIC line that has overflowed off the top of the Screen Line Edit Buffer.
#              It can hold 20 rows, with each row consisting of 32 characters followed by 3 data bytes. Areas of white space that do not
#              contain any editable characters (e.g. the indent that starts subsequent rows of a BASIC line) contain the value $00.
#                Data Byte 0:
#                  Bit 0: 1=The first row of the BASIC line.
#                  Bit 1: 1=Spans onto next row.
#                  Bit 2: Not used (always 0).
#                  Bit 3: 1=The last row of the BASIC line.
#                  Bit 4: 1=Associated line number stored.
#                  Bit 5: Not used (always 0).
#                  Bit 6: Not used (always 0).
#                  Bit 7: Not used (always 0).
#                Data Bytes 1-2: Line number of corresponding BASIC line (stored for the first row of the BASIC line only, holds $0000).
# $FC9E    1   $00=Print a leading space when constructing keyword.
# $FC9F    2   Address of the next character to fetch within the BASIC line in the program area, or $0000 for no next character.
# $FCA1    2   Address of the next character to fetch from the Keyword Construction Buffer, or $0000 for no next character.
# $FCA3   11   Keyword Construction Buffer. Holds either a line number or keyword string representation.
# $FCAE-$FCFC  Construct a BASIC Line routine.                       <<< RAM routine - See end of file for description >>>
# $FCFD-$FD2D  Copy String Into Keyword Construction Buffer routine. <<< RAM routine - See end of file for description >>>
# $FD2E-$FD69  Identify Character Code of Token String routine.      <<< RAM routine - See end of file for description >>>
# $FD74    9   The Keyword Conversion Buffer holding text to examine to see if it is a keyword.
# $FD7D    2   Address of next available location within the Keyword Conversion Buffer.
# $FD7F    2   Address of the space character between words in the Keyword Conversion Buffer.
# $FD81    1   Keyword Conversion Buffer flags, used when tokenizing a BASIC line:
#                Bit 0   : 1=Buffer contains characters.
#                Bit 1   : 1=Indicates within quotes.
#                Bit 2   : 1=Indicates within a REM.
#                Bits 3-7: Not used (always reset to 0).
# $FD82    2   Address of the position to insert the next character within the BASIC line workspace. The BASIC line
#              is created at the spare space pointed to by E_LINE.
# $FD84    1   BASIC line insertion flags, used when inserting a characters into the BASIC line workspace:
#                Bit 0   : 1=The last character was a token.
#                Bit 1   : 1=The last character was a space.
#                Bits 2-7: Not used (always 0).
# $FD85    2   Count of the number of characters in the typed BASIC line being inserted.
# $FD87    2   Count of the number of characters in the tokenized version of the BASIC line being inserted.
# $FD89    1   Holds '<' or '>' if this was the previously examined character during tokenization of a BASIC line, else $00.
# $FD8A    1   Locate Error Marker flag, holding $01 is a syntax error was detected on the BASIC line being inserted and the equivalent position within
#              the typed BASIC line needs to be found with, else it holds $00 when tokenizing a BASIC line.
# $FD8B    2   Stores the stack pointer for restoration upon an insertion error into the BASIC line workspace.
# $FD8C-$FF23  Not used. 408 bytes.
# $FF24    2   Never used. An attempt is made to set it to $EC00. This is a remnant from the Spanish 128, which stored the address of the Screen Buffer here.
#              The value is written to RAM bank 0 instead of RAM bank 7, and the value never subsequently accessed.
# $FF26    2   Not used.
# $FF28-$FF60  Not used. On the Spanish 128 this memory holds a routine that copies a character into the display file. The code to copy to routine into RAM,
#              and the routine itself are present in ROM 0 but are never executed. <<< RAM routine - See end of file for description >>>
# $FF61-$FFFF  Not used. 159 bytes.




.align 1

# Editor workspace variables
FC9A:            .space 2                         // The line number at the top of the screen, or $0000 for the first line.

REPDEL:          .space 1                         // L5C09: Place REPDEL in .align 1 section since REPDEL+REPPER is read/written together as a halfword.
                                                  // Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
REPPER:          .space 1                         // L5C0A: Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
E_PPC:           .space 1                         // L5C49: Number of current line (with program cursor) (low).
E_PPC_hi:        .space 1                         // L5C4A: Number of current line (with program cursor) (high).
BAUD:            .space 2                         // L5B5F: Baud rate timing constant for RS232 socket. Default value of 11. [Name clash with ZX Interface 1 system variable at 0x5CC3]
SERFL:           .space 2                         // L5B61: Byte 0: Second character received flag:
                                                  //           Bit 0   : 1=Character in buffer.
                                                  //           Bits 1-7: Not used (always hold 0).
                                                  //        Byte 1: Received Character.
RNFIRST:         .space 2                         // L5B94: Starting line number when renumbering. Default value of 10.
RNSTEP:          .space 2                         // L5B96: Step size when renumbering. Default value of 10.
STRMS:           .space 2*19                      // L5C10: Address offsets of 19 channels attached to streams.
TVDATA:          .space 2                         // L5C0E: Stores bytes of colour, AT and TAB controls going to TV.
EC06:            .space 2                         // Count of the number of editable characters in the BASIC line up to the cursor within the Screen Line Edit Buffer.
EC08:            .space 2                         // Version of E_PPC used by BASIC Editor to hold last line number entered.
# F6F2/F6F3 accessed together
F6F2:            .space 1                         // Edit area info - Bottom row threshold for scrolling down.
F6F3:            .space 1                         // Edit area info - Number of rows in the editing area.
# FD6A/FD6B accessed together
FD6A:            .space 1                         // Flags used when shifting BASIC lines within edit buffer rows [Redundant]:
                                                  //   Bit 0  : 1=Set to 1 but never reset or tested. Possibly intended to indicate the start of a new BASIC line and hence whether indentation required.
                                                  //   Bit 1-7: Not used (always 0).
FD6B:            .space 1                         // The number of characters to indent subsequent rows of a BASIC line by.

.align 2
# F6EE/F6EF/F6F0/F6F1 accessed together
F6EE:            .space 1                         // Cursor position info - Current row number.
F6EF:            .space 1                         // Cursor position info - Current column number.
F6F0:            .space 1                         // Cursor position info - Preferred column number. Holds the last user selected column position. The Editor will attempt to
                                                  // place the cursor on this column when the user moves up or down to a new line.
F6F1:            .space 1                         // Edit area info - Top row threshold for scrolling up.
COORDS_X:        .space 2                         // L5C7D: X-coordinate of last point plotted.
COORDS_Y:        .space 2                         // L5C7E: Y-coordinate of last point plotted.

.align 3

# All 8 bytes updated together in one str instruction, so align 3 here
FD6C:            .space 1                         // Cursor settings (indexed by IX+$00) - initialised to $00, but never used.
FD6D:            .space 1                         // Cursor settings (indexed by IX+$01) - number of rows above the editing area.
FD6E:            .space 1                         // Cursor settings (indexed by IX+$02) - initialised to $00 (when using lower screen) or $14 (when using main screen), but never subsequently used.
FD6F:            .space 1                         // Cursor settings (indexed by IX+$03) - initialised to $00, but never subsequently used.
FD70:            .space 1                         // Cursor settings (indexed by IX+$04) - initialised to $00, but never subsequently used.
FD71:            .space 1                         // Cursor settings (indexed by IX+$05) - initialised to $00, but never subsequently used.
FD72:            .space 1                         // Cursor settings (indexed by IX+$06) - attribute colour.
FD73:            .space 1                         // Cursor settings (indexed by IX+$07) - screen attribute where cursor is displayed.

SFNEXT:          .space 8                         // L5B83: End of RAM disk catalogue marker. Pointer to first empty catalogue entry.
SFSPACE:         .space 8                         // L5B85: Number of bytes free in RAM disk.
CHARS:           .space 8                         // L5C36: 256 less than address of character set, which starts with ' ' and carries on to '©'.
LIST_SP:         .space 8                         // Address of return address from automatic listing.

next_interrupt:  .space 8

# Pointers to inside the HEAP
VARS:            .space 8                         // L5C4B: Address of variables.
# DEST:          .space 8                         // Address of variable in assignment.
CHANS:           .space 8                         // L5C4F: Address of channel data.
CURCHL:          .space 8                         // L5C51: Address of information currently being used for input and output.
PROG:            .space 8                         // L5C53: Address of BASIC program.
# NXTLIN:        .space 8                         // Address of next line in program.
DATADD:          .space 8                         // L5C57: Address of terminator of last DATA item.
E_LINE:          .space 8                         // L5C59: Address of command being typed in.
# K_CUR:         .space 8                         // Address of cursor.
CH_ADD:          .space 8                         // L5C5D: Address of the next character to be interpreted - the character after the argument of PEEK,
                                                  // or the NEWLINE at the end of a POKE statement.
X_PTR:           .space 8                         // L5C5F: Address of the character after the '?' marker.
WORKSP:          .space 8                         // L5C61: Address of temporary work space.
STKBOT:          .space 8                         // L5C63: Address of bottom of calculator stack.
STKEND:          .space 8                         // L5C65: Address of start of spare space.

# Other pointers
# TARGET:        .space 8                         // L5B58: Address of subroutine to call in ROM 1.
RAMTOP:          .space 8                         // L5CB2: Address of last byte of BASIC system area.
P_RAMT:          .space 8                         // L5CB4: Address of last byte of physical RAM.
UDG:             .space 8                         // L5C7B: Address of first user-defined graphic. Can be changed to save space by having fewer.
ERR_SP:          .space 8                         // L5C3D: Address of item on machine stack to be used as error return.

# Editor
# OLDSP:         .space 8                         // Stores old stack pointer when TSTACK in use.
DF_CC:           .space 8                         // L5C84: Address in display file of PRINT position.
DF_CC_L:         .space 8                         // L5C86: Like DF CC for lower part of screen.
PR_CC:           .space 8                         // L5C80: Full address of next position for LPRINT to print at (in ZX Printer buffer).
K_CUR:           .space 8                         // L5C5B: Address of cursor.
                                                  // Legal values in printer_buffer range. [Not used in 128K mode]

F6EA:            .space 8                         // The jump table address for the current menu.
F6EC:            .space 8                         // The text table address for the current menu.

MEMBOT:          .space 32                        // L5C92: Calculator's memory area - used to store numbers that cannot conveniently be put on the
                                                  // calculator stack.

.align 4
# TSTACK:        .space 0x400
# TSTACK_end:

.align 4                                          // Ensure sysvars_end is at a 16 byte boundary.
sysvars_end:

printer_buffer:  .space 0xd80                     // Printer buffer used by 48K Basic but not by 128K Basic (see docs/printer-buffer.md)
printer_buffer_end:

# Memory regions
display_file:    .space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/8
                                         // L4000
                                                  // One pixel per bit => 8 pixels per byte
display_file_end:

attributes_file: .space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/256
                                         // L5800
                                                  // 16*16 pixels per attribute record => 256 pixles per byte
attributes_file_end:

ram_disk:        .space RAM_DISK_SIZE
heap:            .space HEAP_SIZE

.section .bss.coherent, "aw", %nobits

# 21 is 2MB boundary, which matches granularity of our MMU page tables.
# This is needed since memory attributes are different for this memory region.
.align 21
coherent_start:

.align 12
xhci_start:
scratchpad_bufs: .space 31 * 4096                 // 31 scratchpads × 4 KB

# technically only need .align 4 but since it comes straight after scratchpad_bufs we get .align 12 for free allowing us to use adrp without needing extra add :lo12:
.align 12
dcbaa:           .space 264                       // 33 entries × 8 bytes

.align 4
scratchpad_ptrs: .space 248                       // 31 entries × 8 bytes

.align 4
command_ring:    .space 256                       // 16 TRBs × 16 bytes
xhci_end:

.align 12
coherent_end:
