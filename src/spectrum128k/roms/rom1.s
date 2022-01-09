; **************************************
; *** SPECTRUM 128 ROM 1 DISASSEMBLY ***
; **************************************

; The Spectrum ROMs are copyright Amstrad, who have kindly given permission
; to reverse engineer and publish ROM disassemblies.


; =====
; NOTES
; =====

; ------------
; Release Date
; ------------
; 13th December 2011

; ------------------------
; Disassembly Contributors
; ------------------------
; Geoff Wearmouth (gwearmouth-AT-hotmail.com)
; Paul Farrow     (www.fruitcake.plus.com)



; The Sinclair Interface1 ROM written by Dr. Ian Logan calls numerous
; routines in this ROM. Non-standard entry points have a label beginning
; with X.

.global display_file
.global attributes_file

.global ATTR_P
.global ATTR_T
.global BORDCR
.global CHANS
.global CHARS
.global CH_ADD
.global COORDS_X
.global CURCHL
.global DATADD
.global DEFADD
.global DF_CC
.global DF_CC_L
.global DF_SZ
.global ECHO_E_X
.global ECHO_E_Y
.global ERR_NR
.global ERR_SP
.global E_LINE
.global E_PPC
.global FLAGS
.global FLAGS2
.global K_CUR
.global LASTK
.global MASK_P
.global MASK_T
.global MEMBOT
.global MODE
.global NEWPPC
.global NSPPC
.global NXTLIN
.global OSPPC
.global PIP
.global PPC
.global PROG
.global PR_CC
.global P_FLAG
.global P_POSN_X
.global P_RAMT
.global RAMTOP
.global RASP
.global REPDEL
.global REPPER
.global SCR_CT
.global STKBOT
.global STKEND
.global STRMS
.global STRM_00
.global SUBPPC
.global S_POSN_X
.global S_POSN_X_L
.global S_POSN_Y
.global S_POSN_Y_L
.global TVDATA
.global TVDATA_hi
.global TV_FLAG
.global T_ADDR
.global UDG
.global VARS
.global WORKSP
.global X_PTR
.global _start
.global add_char
.global alpha
.global bc_spaces
.global beep
.global beeper
.global border
.global chan_flag
.global chan_k
.global chan_open
.global chan_p
.global chan_s
.global char_set
.global circle
.global cl_addr
.global cl_all
.global cl_attr
.global cl_chan
.global cl_set
.global class_01
.global class_04
.global class_09
.global clear_sp
.global close
.global cls
.global cls_lower
.global co_temp_4
.global comma_sp
.global continue
.global cout
.global d_run
.global dr_3_prms
.global e_line_no
.global each_stmt
.global ed_error
.global error_1
.global expt_1num
.global expt_2num
.global expt_exp
.global f_reorder
.global fetch_num
.global find_int2
.global fp_to_bc
.global get_char
.global go_to
.global hl_mult_de
.global in_item_1
.global indexer
.global init_chan
.global init_strm
.global input_1
.global key_input
.global key_m_cl
.global kp_scan
.global line_addr
.global line_draw
.global line_no
.global list_5
.global look_prog
.global look_vars
.global main_4
.global make_room
.global me_contrl
.global next
.global next_char
.global next_one
.global number
.global numeric
.global open
.global out_code
.global out_num_1
.global pass_by
.global pause
.global pixel_addr
.global plot
.global plot_sub
.global po_any
.global po_attr
.global po_change
.global po_char
.global po_fetch
.global po_mosaic_half
.global po_msg
.global po_save
.global po_scr
.global po_search
.global po_store
.global po_t_udg
.global po_tokens
.global pointers
.global poke
.global pr_all
.global pr_st_end
.global print_2
.global print_a
.global print_fp
.global print_out
.global print_token_udg_patch
.global randomize
.global reclaim_1
.global reclaim_2
.global report_j
.global rest_run
.global restore
.global rpt_mesgs
.global sa_all
.global sa_contrl
.global scanning
.global set_min
.global set_stk
.global set_work
.global stack_bc
.global stack_num
.global stk_fetch
.global stk_var
.global stop
.global str_alter
.global syntax_z
.global sysvars_48k
.global sysvars_48k_end
.global temps
.global test_room
.global test_screen
.global test_zero
.global tkn_and
.global tkn_copy
.global tkn_less_equal
.global tkn_or
.global tkn_rnd
.global tkn_table
.global use_zero
.global val_fet_1



.bss

display_file:       .space 0x1800
attributes_file:    .space 0x0300
PRINTER_BUFFER_48:  .space 0x0100

; =========================
; Standard System Variables
; =========================
; These occupy addresses KSTATE-$5CB5.
;

sysvars_48k:

KSTATE:     .space   4                    ;  IY-$3A   Used in reading the keyboard.
KSTATE_04:  .space   4                    ;  IY-$36   Used in reading the keyboard.
LASTK:      .space   1                    ;  IY-$32   Stores newly pressed key.
REPDEL:     .space   1                    ;  IY-$31   Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
REPPER:     .space   1                    ;  IY-$30   Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
DEFADD:     .space   1                    ;  IY-$2F   Address of arguments of user defined function (if one is being evaluated), otherwise 0 (low).
DEFADD_hi:  .space   1                    ;  IY-$2E   Address of arguments of user defined function (if one is being evaluated), otherwise 0 (high).
K_DATA:     .space   1                    ;  IY-$2D   Stores second byte of colour controls entered from keyboard.
TVDATA:     .space   1                    ;  IY-$2C   Stores bytes of colour, AT and TAB controls going to TV (low).
TVDATA_hi:  .space   1                    ;  IY-$2B   Stores bytes of colour, AT and TAB controls going to TV (high).
STRMS:                                    ;  IY-$2A   Addresses of channels attached to streams.
STRM_FD:    .space   2                    ;  IY-$2A   Stream -3
STRM_FE:    .space   2                    ;  IY-$28   Stream -2
STRM_FF:    .space   2                    ;  IY-$26   Stream -1
STRM_00:    .space   2                    ;  IY-$24   Stream  0
STRM_01:    .space   2                    ;  IY-$22   Stream  1
STRM_02:    .space   2                    ;  IY-$20   Stream  2
STRM_03:    .space   2                    ;  IY-$1E   Stream  3
STRM_04:    .space   2                    ;  IY-$1C   Stream  4
STRM_05:    .space   2                    ;  IY-$1A   Stream  5
STRM_06:    .space   2                    ;  IY-$18   Stream  6
STRM_07:    .space   2                    ;  IY-$16   Stream  7
STRM_08:    .space   2                    ;  IY-$14   Stream  8
STRM_09:    .space   2                    ;  IY-$12   Stream  9
STRM_0a:    .space   2                    ;  IY-$10   Stream 10
STRM_0b:    .space   2                    ;  IY-$0E   Stream 11
STRM_0c:    .space   2                    ;  IY-$0C   Stream 12
STRM_0d:    .space   2                    ;  IY-$0A   Stream 13
STRM_0e:    .space   2                    ;  IY-$08   Stream 14
STRM_0f:    .space   2                    ;  IY-$06   Stream 15
CHARS:      .space   2                    ;  IY-$04   256 less than address of character set, which starts with ' ' and carries on to '(c)'.
RASP:       .space   1                    ;  IY-$02   Length of warning buzz.
PIP:        .space   1                    ;  IY-$01   Length of keyboard click.
C_IY:                                     ;  IY+$00   Frozen (constant) value that IY register retains throughout ROM routines
ERR_NR:     .space   1                    ;  IY+$00   1 less than the report code. Starts off at 255 (for -1) so 'PEEK 23610' gives 255.
FLAGS:      .space   1                    ;  IY+$01   Various flags to control the BASIC system:
                                          ;                 Bit 0: 1=Suppress leading space.
                                          ;                 Bit 1: 1=Using printer, 0=Using screen.
                                          ;                 Bit 2: 1=Print in L-Mode, 0=Print in K-Mode.
                                          ;                 Bit 3: 1=L-Mode, 0=K-Mode.
                                          ;                 Bit 4: 1=128K Mode, 0=48K Mode. [Always 0 on 48K Spectrum]
                                          ;                 Bit 5: 1=New key press code available in LAST_K.
                                          ;                 Bit 6: 1=Numeric variable, 0=String variable.
                                          ;                 Bit 7: 1=Line execution, 0=Syntax checking.
TV_FLAG:    .space   1                    ;  IY+$02   Flags associated with the TV:
                                          ;                 Bit 0  : 1=Using lower editing area, 0=Using main screen.
                                          ;                 Bit 1-2: Not used (always 0).
                                          ;                 Bit 3  : 1=Mode might have changed.
                                          ;                 Bit 4  : 1=Automatic listing in main screen, 0=Ordinary listing in main screen.
                                          ;                 Bit 5  : 1=Lower screen requires clearing after a key press.
                                          ;                 Bit 6  : 1=Tape Loader option selected (set but never tested). [Always 0 on 48K Spectrum]
                                          ;                 Bit 7  : Not used (always 0).
ERR_SP:     .space   2                    ;  IY+$03   Address of item on machine stack to be used as error return.
LISTSP:     .space   2                    ;  IY+$05   Address of return address from automatic listing.
MODE:       .space   1                    ;  IY+$07   Specifies cursor type:
                                          ;                 $00='L' or 'C'.
                                          ;                 $01='E'.
                                          ;                 $02='G'.
                                          ;                 $04='K'.
NEWPPC:     .space   2                    ;  IY+$08   Line to be jumped to.
NSPPC:      .space   1                    ;  IY+$0A   Statement number in line to be jumped to.
PPC:        .space   2                    ;  IY+$0B   Line number of statement currently being executed.
SUBPPC:     .space   1                    ;  IY+$0D   Number within line of statement currently being executed.
BORDCR:     .space   1                    ;  IY+$0E   Border colour multiplied by 8; also contains the attributes normally used for the lower half
                                          ;               of the screen.
E_PPC:      .space   1                    ;  IY+$0F   Number of current line (with program cursor) (low).
E_PPC_hi:   .space   1                    ;  IY+$10   Number of current line (with program cursor) (high).
VARS:       .space   2                    ;  IY+$11   Address of variables.
DEST:       .space   2                    ;  IY+$13   Address of variable in assignment.
CHANS:      .space   2                    ;  IY+$15   Address of channel data.
CURCHL:     .space   2                    ;  IY+$17   Address of information currently being used for input and output.
PROG:       .space   2                    ;  IY+$19   Address of BASIC program.
NXTLIN:     .space   2                    ;  IY+$1B   Address of next line in program.
DATADD:     .space   2                    ;  IY+$1D   Address of terminator of last DATA item.
E_LINE:     .space   2                    ;  IY+$1F   Address of command being typed in.
K_CUR:      .space   1                    ;  IY+$21   Address of cursor (low byte).
K_CUR_hi:   .space   1                    ;  IY+$22   Address of cursor (high byte).
CH_ADD:     .space   2                    ;  IY+$23   Address of the next character to be interpreted - the character after the argument of PEEK,
                                          ;               or the NEWLINE at the end of a POKE statement.
X_PTR:      .space   1                    ;  IY+$25   Address of the character after the '?' marker (low byte).
X_PTR_hi:   .space   1                    ;  IY+$26   Address of the character after the '?' marker (high byte).
WORKSP:     .space   2                    ;  IY+$27   Address of temporary work space.
STKBOT:     .space   2                    ;  IY+$29   Address of bottom of calculator stack.
STKEND:     .space   1                    ;  IY+$2B   Address of start of spare space (low).
STKEND_hi:  .space   1                    ;  IY+$2C   Address of start of spare space (high).
BREG:       .space   1                    ;  IY+$2D   Calculator's B register.
MEM:        .space   2                    ;  IY+$2E   Address of area used for calculator's memory (usually MEMBOT, but not always).
FLAGS2:     .space   1                    ;  IY+$30   Flags:
                                          ;                 Bit 0  : 1=Screen requires clearing.
                                          ;                 Bit 1  : 1=Printer buffer contains data.
                                          ;                 Bit 2  : 1=In quotes.
                                          ;                 Bit 3  : 1=CAPS LOCK on.
                                          ;                 Bit 4  : 1=Using channel 'K'.
                                          ;                 Bit 5-7: Not used (always 0).
DF_SZ:      .space   1                    ;  IY+$31   The number of lines (including one blank line) in the lower part of the screen.
S_TOP:      .space   2                    ;  IY+$32   The number of the top program line in automatic listings.
OLDPPC:     .space   2                    ;  IY+$34   Line number to which CONTINUE jumps.
OSPPC:      .space   1                    ;  IY+$36   Number within line of statement to which CONTINUE jumps.
FLAGX:      .space   1                    ;  IY+$37   Flags:
                                          ;                 Bit 0  : 1=Simple string complete so delete old copy.
                                          ;                 Bit 1  : 1=Indicates new variable, 0=Variable exists.
                                          ;                 Bit 2-4: Not used (always 0).
                                          ;                 Bit 5  : 1=INPUT mode.
                                          ;                 Bit 6  : 1=Numeric variable, 0=String variable. Holds nature of existing variable.
                                          ;                 Bit 7  : 1=Using INPUT LINE.
STRLEN:     .space   2                    ;  IY+$38   Length of string type destination in assignment.
T_ADDR:     .space   2                    ;  IY+$3A   Address of next item in syntax table.
SEED:       .space   2                    ;  IY+$3C   The seed for RND. Set by RANDOMIZE.
FRAMES:     .space   2                    ;  IY+$3E   3 byte (least significant byte first), frame counter incremented every 20ms.
FRAMES_hi:  .space   1                    ;  IY+$40   MSB of FRAMES
UDG:        .space   2                    ;  IY+$41   Address of first user-defined graphic. Can be changed to save space by having fewer
                                          ;               user-defined characters.
COORDS_X:   .space   1                    ;  IY+$43   X-coordinate of last point plotted.
COORDS_Y:   .space   1                    ;  IY+$44   Y-coordinate of last point plotted.
P_POSN_X:   .space   1                    ;  IY+$45   33-column number of printer position.
PR_CC:      .space   2                    ;  IY+$46   Full address of next position for LPRINT to print at (in ZX Printer buffer).
                                          ;               Legal values PRINTER_BUFFER_48 - $5B1F. [Not used in 128K mode]
ECHO_E_X:   .space   1                    ;  IY+$48   33-column number of end of input buffer.
ECHO_E_Y:   .space   1                    ;  IY+$49   24-line number (in lower half) of end of input buffer.
DF_CC:      .space   2                    ;  IY+$4A   Address in display file of PRINT position.
DF_CC_L:    .space   2                    ;  IY+$4C   Like DF CC for lower part of screen.
S_POSN_X:   .space   1                    ;  IY+$4E   33-column number for PRINT position.
S_POSN_Y:   .space   1                    ;  IY+$4F   24-line number for PRINT position.
S_POSN_X_L: .space   1                    ;  IY+$50   Like S_POSN_X for lower part.
S_POSN_Y_L: .space   1                    ;  IY+$51   Like S_POSN_Y for lower part.
SCR_CT:     .space   1                    ;  IY+$52   Counts scrolls - it is always 1 more than the number of scrolls that will be done before
                                          ;               stopping with 'scroll?'.
ATTR_P:     .space   1                    ;  IY+$53   Permanent current colours, etc, as set up by colour statements.
MASK_P:     .space   1                    ;  IY+$54   Used for transparent colours, etc. Any bit that is 1 shows that the corresponding attribute
                                          ;               bit is taken not from ATTR_P, but from what is already on the screen.
ATTR_T:     .space   1                    ;  IY+$55   Temporary current colours (as set up by colour items).
MASK_T:     .space   1                    ;  IY+$56   Like MASK_P, but temporary.
P_FLAG:     .space   1                    ;  IY+$57   Flags:
                                          ;                 Bit 0: (temp) 1=OVER 1, 0=OVER 0.
                                          ;                 Bit 1: (perm) 1=OVER 1, 0=OVER 0.
                                          ;                 Bit 2: (temp) 1=INVERSE 1, 0=INVERSE 0.
                                          ;                 Bit 3: (perm) 1=INVERSE 1, 0=INVERSE 0.
                                          ;                 Bit 4: (temp) 1=Using INK 9.
                                          ;                 Bit 5: (perm) 1=Using INK 9.
                                          ;                 Bit 6: (temp) 1=Using PAPER 9.
                                          ;                 Bit 7: (perm) 1=Using PAPER 9.
MEMBOT:     .space   1                    ;  IY+$58   30 bytes of calculator's memory - used to store numbers that cannot conveniently be put on the
                                          ;               calculator stack.
MEMBOT_01:  .space   1                    ;  IY+$59
MEMBOT_02:  .space   1                    ;  IY+$5A
MEMBOT_03:  .space   1                    ;  IY+$5B
MEMBOT_04:  .space   1                    ;  IY+$5C
MEMBOT_05:  .space   1                    ;  IY+$5D
MEMBOT_06:  .space   1                    ;  IY+$5E
MEMBOT_07:  .space   1                    ;  IY+$5F
MEMBOT_08:  .space   1                    ;  IY+$60
MEMBOT_09:  .space   1                    ;  IY+$61
MEMBOT_0a:  .space   1                    ;  IY+$62
MEMBOT_0b:  .space   1                    ;  IY+$63
MEMBOT_0c:  .space   1                    ;  IY+$64
MEMBOT_0d:  .space   1                    ;  IY+$65
MEMBOT_0e:  .space   1                    ;  IY+$66
MEMBOT_0f:  .space   1                    ;  IY+$67
MEMBOT_10:  .space   1                    ;  IY+$68
MEMBOT_11:  .space   1                    ;  IY+$69
MEMBOT_12:  .space   1                    ;  IY+$6A
MEMBOT_13:  .space   1                    ;  IY+$6B
MEMBOT_14:  .space   1                    ;  IY+$6C
MEMBOT_15:  .space   1                    ;  IY+$6D
MEMBOT_16:  .space   1                    ;  IY+$6E
MEMBOT_17:  .space   1                    ;  IY+$6F
MEMBOT_18:  .space   1                    ;  IY+$70
MEMBOT_19:  .space   1                    ;  IY+$71
MEMBOT_1a:  .space   1                    ;  IY+$72
MEMBOT_1b:  .space   1                    ;  IY+$73
MEMBOT_1c:  .space   1                    ;  IY+$74
MEMBOT_1d:  .space   1                    ;  IY+$75
UNUSED1:    .space   2                    ;  IY+$76   Not used on standard Spectrum. [Used by ZX Interface 1 Edition 2 for printer WIDTH]
RAMTOP:     .space   2                    ;  IY+$78   Address of last byte of BASIC system area.
P_RAMT:     .space   2                    ;  IY+$7A   Address of last byte of physical RAM.

sysvars_48k_end:


.text


_start:


;*****************************************
;** Part 1. RESTART ROUTINES AND TABLES **
;*****************************************

; -----------
; THE 'START'
; -----------
; At switch on, the Z80 chip is in interrupt mode 0.
; This location can also be 'called' to reset the machine.
; Typically with PRINT USR 0.

start:
        DI                                ; disable interrupts.
        XOR     A                         ; signal coming from START.
        LD      DE,$FFFF                  ; top of possible physical RAM.
        JP      start_new                 ; jump forward to common code at START-NEW.

; -------------------
; THE 'ERROR' RESTART
; -------------------
; The error pointer is made to point to the position of the error to enable
; the editor to show the error if it occurred during syntax checking.
; It is used at 37 places in the program.
; An instruction fetch on address error_1 may page in a peripheral ROM
; such as the Sinclair Interface 1 or Disciple Disk Interface.
; This was not however an original design concept and not all errors pass
; through here.

error_1:
        LD      HL,(CH_ADD)               ; fetch the character address from CH_ADD.
        LD      (X_PTR),HL                ; copy it to the error pointer X_PTR.
        JR      error_2                   ; forward to continue at ERROR-2.

; -----------------------------
; THE 'PRINT CHARACTER' RESTART
; -----------------------------
; The A register holds the code of the character that is to be sent to
; the output stream of the current channel.
; The alternate register set is used to output a character in the A register
; so there is no need to preserve any of the current registers (HL,DE,BC).
; This restart is used 21 times.
;
; On entry:
;   A = byte to print
;   [[CURCHL]] = print routine to call with [AF BC' DE' HL'] switched in
;   ... plus any settings that routine at [[CURCHL]] requires ...
; On exit:
;   DE' =
;     if [[CURCHL]] updates its DE (caller's DE'):
;       that value
;     else:
;       [CURCHL]+1
;   HL' preserved, regardless of [[CURCHL]] routine called
;   ... plus other register changes that routine [[CURCHL]] (with [AF BC' DE' HL'] switched in) makes...

print_a:
        JP      print_a_2                 ; jump forward to continue at PRINT-A-2.

; ---

        DEFB    $FF                       ; this byte is used by the SPECTRUM command in
                                          ; ROM 0 to generate an error report "0 OK".

        DEFB    $FF, $FF                  ; four unused locations.
        DEFB    $FF, $FF                  ;

; -------------------------------
; THE 'COLLECT CHARACTER' RESTART
; -------------------------------
; The contents of the location currently addressed by CH_ADD are fetched.
; A return is made if the value represents a character that has
; relevance to the BASIC parser. Otherwise CH_ADD is incremented and the
; tests repeated. CH_ADD will be addressing somewhere -
; 1) in the BASIC program area during line execution.
; 2) in workspace if evaluating, for example, a string expression.
; 3) in the edit buffer if parsing a direct command or a new BASIC line.
; 4) in workspace if accepting input but not that from INPUT LINE.

get_char:
        LD      HL,(CH_ADD)               ; fetch the address from CH_ADD.
        LD      A,(HL)                    ; use it to pick up current character.

test_char:
        CALL    skip_over                 ; routine SKIP-OVER tests if the character
        RET     NC                        ; is relevant. Return if it is so.

; ------------------------------------
; THE 'COLLECT NEXT CHARACTER' RESTART
; ------------------------------------
; As the BASIC commands and expressions are interpreted, this routine is
; called repeatedly to step along the line. It is used 83 times.

next_char:
        CALL    ch_add_plus_1             ; routine CH-ADD+1 fetches the next immediate
                                          ; character.
        JR      test_char                 ; jump back to TEST-CHAR until a valid
                                          ; character is found.

; ---

        DEFB    $FF, $FF, $FF             ; unused

; -----------------------
; THE 'CALCULATE' RESTART
; -----------------------
; This restart enters the Spectrum's internal, floating-point,
; stack-based, FORTH-like language.
; It is further used recursively from within the calculator.
; It is used on 77 occasions.

fp_calc:
        JP      calculate                 ; jump forward to the CALCULATE routine.

; ---

        DEFB    $FF, $FF, $FF             ; spare - note that on the ZX81, space being a
        DEFB    $FF, $FF                  ; little cramped, these same locations were
                                          ; used for the five-byte end-calc literal.

; ------------------------------
; THE 'CREATE BC SPACES' RESTART
; ------------------------------
; This restart is used on only 12 occasions to create BC spaces
; between workspace and the calculator stack.

bc_spaces:
        PUSH    BC                        ; save number of spaces.
        LD      HL,(WORKSP)               ; fetch WORKSP.
        PUSH    HL                        ; save address of workspace.
        JP      reserve                   ; jump forward to continuation code RESERVE.

; --------------------------------
; THE 'MASKABLE INTERRUPT' ROUTINE
; --------------------------------
; This routine increments the Spectrum's three-byte FRAMES counter
; fifty times a second (sixty times a second in the USA ).
; Both this routine and the called KEYBOARD subroutine use
; the IY register to access system variables and flags so a user-written
; program must disable interrupts to make use of the IY register.

mask_int:
        PUSH    AF                        ; save the registers.
        PUSH    HL                        ; but not IY unfortunately.
        LD      HL,(FRAMES)               ; fetch two bytes at FRAMES1.
        INC     HL                        ; increment lowest two bytes of counter.
        LD      (FRAMES),HL               ; place back in FRAMES1.
        LD      A,H                       ; test if the result
        OR      L                         ; was zero.
        JR      NZ,key_int                ; forward to KEY-INT if not.

        INC     (IY+(FRAMES_hi-C_IY))     ; otherwise increment FRAMES3 the third byte.

; now save the rest of the main registers and read and decode the keyboard.

key_int:
        PUSH    BC                        ; save the other
        PUSH    DE                        ; main registers.
        CALL    keys                      ; Spectrum 128 patch: read the keypad and keyboard
                                          ; in the process of reading a key-press.
        POP     DE                        ;
        POP     BC                        ; restore registers.

        POP     HL                        ;
        POP     AF                        ;
        EI                                ; enable interrupts.
        RET                               ; return.

; ---------------------
; THE 'ERROR-2' ROUTINE
; ---------------------
; A continuation of the code at 0008.
; The error code is stored and after clearing down stacks,
; an indirect jump is made to MAIN-4, etc. to handle the error.

error_2:
        POP     HL                        ; drop the return address - the location
                                          ; after the RST 08H instruction.
        LD      L,(HL)                    ; fetch the error code that follows.
                                          ; (nice to see this instruction used.)

; Note. this entry point is used when out of memory at REPORT-4.
; The L register has been loaded with the report code but X-PTR is not
; updated.

error_3:
        LD      (IY+(ERR_NR-C_IY)),L      ; store it in the system variable ERR_NR.
        LD      SP,(ERR_SP)               ; ERR_SP points to an error handler on the
                                          ; machine stack. There may be a hierarchy
                                          ; of routines.
                                          ; to MAIN-4 initially at base.
                                          ; or REPORT-G on line entry.
                                          ; or  ED-ERROR when editing.
                                          ; or   ED-FULL during ed-enter.
                                          ; or  IN-VAR-1 during runtime input etc.

        JP      set_stk                   ; jump to SET-STK to clear the calculator
                                          ; stack and reset MEM to usual place in the
                                          ; systems variables area.
                                          ; and then indirectly to MAIN-4, etc.

; ---

        DEFB    $FF, $FF, $FF             ; unused locations
        DEFB    $FF, $FF, $FF             ; before the fixed-position
        DEFB    $FF                       ; NMI routine.

; ------------------------------------
; THE 'NON-MASKABLE INTERRUPT' ROUTINE
; ------------------------------------
; There is no NMI switch on the standard Spectrum.
; When activated, a location in the system variables is tested
; and if the contents are zero a jump made to that location else
; a return is made. Perhaps a disabled development feature but
; if the logic was reversed, no program would be safe from
; copy-protection and the Spectrum would have had no software base.
; The location NMIADD was later used by Interface 1 for other purposes.
; On later Spectrums, and the Brazilian Spectrum, the logic of this
; routine was reversed.

reset:
        PUSH    AF                        ; save the
        PUSH    HL                        ; registers.
        LD      HL,(UNUSED1)              ; fetch the system variable NMIADD.
        LD      A,H                       ; test address
        OR      L                         ; for zero.
        JR      NZ,no_reset               ; skip to NO-RESET if NOT ZERO

        JP      (HL)                      ; jump to routine ( i.e. start )

no_reset:
        POP     HL                        ; restore the
        POP     AF                        ; registers.
        RETN                              ; return to previous interrupt state.

; ---------------------------
; THE 'CH ADD + 1' SUBROUTINE
; ---------------------------
; This subroutine is called from RST 20H, and three times from elsewhere
; to fetch the next immediate character following the current valid character
; address and update the associated system variable.
; The entry point TEMP-PTR1 is used from the SCANNING routine.
; Both TEMP-PTR1 and TEMP-PTR2 are used by the READ command routine.

ch_add_plus_1:
        LD      HL,(CH_ADD)               ; fetch address from CH_ADD.

temp_ptr1:
        INC     HL                        ; increase the character address by one.

temp_ptr2:
        LD      (CH_ADD),HL               ; update CH_ADD with character address.

        LD      A,(HL)                    ; load character to A from HL.
        RET                               ; and return.

; --------------------------
; THE 'SKIP OVER' SUBROUTINE
; --------------------------
; This subroutine is called once from RST 18H to skip over white-space and
; other characters irrelevant to the parsing of a BASIC line etc. .
; Initially the A register holds the character to be considered
; and HL holds its address which will not be within quoted text
; when a BASIC line is parsed.
; Although the 'tab' and 'at' characters will not appear in a BASIC line,
; they could be present in a string expression, and in other situations.
; Note. although white-space is usually placed in a program to indent loops
; and make it more readable, it can also be used for the opposite effect and
; spaces may appear in variable names although the parser never sees them.
; It is this routine that helps make the variables 'Anum bEr5 3BUS' and
; 'a number 53 bus' appear the same to the parser.

skip_over:
        CP      $21                       ; test if higher than space.
        RET     NC                        ; return with carry clear if so.

        CP      $0D                       ; carriage return ?
        RET     Z                         ; return also with carry clear if so.

                                          ; all other characters have no relevance
                                          ; to the parser and must be returned with
                                          ; carry set.

        CP      $10                       ; test if 0-15d
        RET     C                         ; return, if so, with carry set.

        CP      $18                       ; test if 24-32d
        CCF                               ; complement carry flag.
        RET     C                         ; return with carry set if so.

                                          ; now leaves 16d-23d

        INC     HL                        ; all above have at least one extra character
                                          ; to be stepped over.

        CP      $16                       ; controls 22d ('at') and 23d ('tab') have two.
        JR      C,skips                   ; forward to SKIPS with ink, paper, flash,
                                          ; bright, inverse or over controls.
                                          ; Note. the high byte of tab is for RS232 only.
                                          ; it has no relevance on this machine.

        INC     HL                        ; step over the second character of 'at'/'tab'.

skips:
        SCF                               ; set the carry flag
        LD      (CH_ADD),HL               ; update the CH_ADD system variable.
        RET                               ; return with carry set.


; ------------------
; THE 'TOKEN TABLES'
; ------------------
; The tokenized characters 134d (RND) to 255d (COPY) are expanded using
; this table. The last byte of a token is inverted to denote the end of
; the word. The first is an inverted step-over byte.

tkn_table:
        DEFB    '?'+$80
tkn_rnd:
        DEFM    "RN"
        DEFB    'D'+$80
        DEFM    "INKEY"
        DEFB    '$'+$80
        DEFB    'P','I'+$80
        DEFB    'F','N'+$80
        DEFM    "POIN"
        DEFB    'T'+$80
        DEFM    "SCREEN"
        DEFB    '$'+$80
        DEFM    "ATT"
        DEFB    'R'+$80
        DEFB    'A','T'+$80
        DEFM    "TA"
        DEFB    'B'+$80
        DEFM    "VAL"
        DEFB    '$'+$80
        DEFM    "COD"
        DEFB    'E'+$80
        DEFM    "VA"
        DEFB    'L'+$80
        DEFM    "LE"
        DEFB    'N'+$80
        DEFM    "SI"
        DEFB    'N'+$80
        DEFM    "CO"
        DEFB    'S'+$80
        DEFM    "TA"
        DEFB    'N'+$80
        DEFM    "AS"
        DEFB    'N'+$80
        DEFM    "AC"
        DEFB    'S'+$80
        DEFM    "AT"
        DEFB    'N'+$80
        DEFB    'L','N'+$80
        DEFM    "EX"
        DEFB    'P'+$80
        DEFM    "IN"
        DEFB    'T'+$80
        DEFM    "SQ"
        DEFB    'R'+$80
        DEFM    "SG"
        DEFB    'N'+$80
        DEFM    "AB"
        DEFB    'S'+$80
        DEFM    "PEE"
        DEFB    'K'+$80
        DEFB    'I','N'+$80
        DEFM    "US"
        DEFB    'R'+$80
        DEFM    "STR"
        DEFB    '$'+$80
        DEFM    "CHR"
        DEFB    '$'+$80
        DEFM    "NO"
        DEFB    'T'+$80
        DEFM    "BI"
        DEFB    'N'+$80
tkn_or:
        DEFB    'O','R'+$80
tkn_and:
        DEFM    "AN"
        DEFB    'D'+$80
tkn_less_equal:
        DEFB    $3C,'='+$80               ; <=
        DEFB    $3E,'='+$80               ; >=
        DEFB    $3C,$3E+$80               ; <>
        DEFM    "LIN"
        DEFB    'E'+$80
        DEFM    "THE"
        DEFB    'N'+$80
        DEFB    'T','O'+$80
        DEFM    "STE"
        DEFB    'P'+$80
        DEFM    "DEF F"
        DEFB    'N'+$80
        DEFM    "CA"
        DEFB    'T'+$80
        DEFM    "FORMA"
        DEFB    'T'+$80
        DEFM    "MOV"
        DEFB    'E'+$80
        DEFM    "ERAS"
        DEFB    'E'+$80
        DEFM    "OPEN "
        DEFB    '#'+$80
        DEFM    "CLOSE "
        DEFB    '#'+$80
        DEFM    "MERG"
        DEFB    'E'+$80
        DEFM    "VERIF"
        DEFB    'Y'+$80
        DEFM    "BEE"
        DEFB    'P'+$80
        DEFM    "CIRCL"
        DEFB    'E'+$80
        DEFM    "IN"
        DEFB    'K'+$80
        DEFM    "PAPE"
        DEFB    'R'+$80
        DEFM    "FLAS"
        DEFB    'H'+$80
        DEFM    "BRIGH"
        DEFB    'T'+$80
        DEFM    "INVERS"
        DEFB    'E'+$80
        DEFM    "OVE"
        DEFB    'R'+$80
        DEFM    "OU"
        DEFB    'T'+$80
        DEFM    "LPRIN"
        DEFB    'T'+$80
        DEFM    "LLIS"
        DEFB    'T'+$80
        DEFM    "STO"
        DEFB    'P'+$80
        DEFM    "REA"
        DEFB    'D'+$80
        DEFM    "DAT"
        DEFB    'A'+$80
        DEFM    "RESTOR"
        DEFB    'E'+$80
        DEFM    "NE"
        DEFB    'W'+$80
        DEFM    "BORDE"
        DEFB    'R'+$80
        DEFM    "CONTINU"
        DEFB    'E'+$80
        DEFM    "DI"
        DEFB    'M'+$80
        DEFM    "RE"
        DEFB    'M'+$80
        DEFM    "FO"
        DEFB    'R'+$80
        DEFM    "GO T"
        DEFB    'O'+$80
        DEFM    "GO SU"
        DEFB    'B'+$80
        DEFM    "INPU"
        DEFB    'T'+$80
        DEFM    "LOA"
        DEFB    'D'+$80
        DEFM    "LIS"
        DEFB    'T'+$80
        DEFM    "LE"
        DEFB    'T'+$80
        DEFM    "PAUS"
        DEFB    'E'+$80
        DEFM    "NEX"
        DEFB    'T'+$80
        DEFM    "POK"
        DEFB    'E'+$80
        DEFM    "PRIN"
        DEFB    'T'+$80
        DEFM    "PLO"
        DEFB    'T'+$80
        DEFM    "RU"
        DEFB    'N'+$80
        DEFM    "SAV"
        DEFB    'E'+$80
        DEFM    "RANDOMIZ"
        DEFB    'E'+$80
        DEFB    'I','F'+$80
        DEFM    "CL"
        DEFB    'S'+$80
        DEFM    "DRA"
        DEFB    'W'+$80
        DEFM    "CLEA"
        DEFB    'R'+$80
        DEFM    "RETUR"
        DEFB    'N'+$80
tkn_copy:
        DEFM    "COP"
        DEFB    'Y'+$80

; ----------------
; THE 'KEY' TABLES
; ----------------
; These six look-up tables are used by the keyboard reading routine
; to decode the key values.

; The first table contains the maps for the 39 keys of the standard
; 40-key Spectrum keyboard. The remaining key [SHIFT $27] is read directly.
; The keys consist of the 26 upper-case alphabetic characters, the 10 digit
; keys and the space, ENTER and symbol shift key.
; Unshifted alphabetic keys have $20 added to the value.
; The keywords for the main alphabetic keys are obtained by adding $A5 to
; the values obtained from this table.

main_keys:
        DEFB    $42                       ; B
        DEFB    $48                       ; H
        DEFB    $59                       ; Y
        DEFB    $36                       ; 6
        DEFB    $35                       ; 5
        DEFB    $54                       ; T
        DEFB    $47                       ; G
        DEFB    $56                       ; V
        DEFB    $4E                       ; N
        DEFB    $4A                       ; J
        DEFB    $55                       ; U
        DEFB    $37                       ; 7
        DEFB    $34                       ; 4
        DEFB    $52                       ; R
        DEFB    $46                       ; F
        DEFB    $43                       ; C
        DEFB    $4D                       ; M
        DEFB    $4B                       ; K
        DEFB    $49                       ; I
        DEFB    $38                       ; 8
        DEFB    $33                       ; 3
        DEFB    $45                       ; E
        DEFB    $44                       ; D
        DEFB    $58                       ; X
        DEFB    $0E                       ; SYMBOL SHIFT
        DEFB    $4C                       ; L
        DEFB    $4F                       ; O
        DEFB    $39                       ; 9
        DEFB    $32                       ; 2
        DEFB    $57                       ; W
        DEFB    $53                       ; S
        DEFB    $5A                       ; Z
        DEFB    $20                       ; SPACE
        DEFB    $0D                       ; ENTER
        DEFB    $50                       ; P
        DEFB    $30                       ; 0
        DEFB    $31                       ; 1
        DEFB    $51                       ; Q
        DEFB    $41                       ; A


e_unshift:
;  The 26 unshifted extended mode keys for the alphabetic characters.
;  The green keywords on the original keyboard.
        DEFB    $E3                       ; READ
        DEFB    $C4                       ; BIN
        DEFB    $E0                       ; LPRINT
        DEFB    $E4                       ; DATA
        DEFB    $B4                       ; TAN
        DEFB    $BC                       ; SGN
        DEFB    $BD                       ; ABS
        DEFB    $BB                       ; SQR
        DEFB    $AF                       ; CODE
        DEFB    $B0                       ; VAL
        DEFB    $B1                       ; LEN
        DEFB    $C0                       ; USR
        DEFB    $A7                       ; PI
        DEFB    $A6                       ; INKEY$
        DEFB    $BE                       ; PEEK
        DEFB    $AD                       ; TAB
        DEFB    $B2                       ; SIN
        DEFB    $BA                       ; INT
        DEFB    $E5                       ; RESTORE
        DEFB    $A5                       ; RND
        DEFB    $C2                       ; CHR$
        DEFB    $E1                       ; LLIST
        DEFB    $B3                       ; COS
        DEFB    $B9                       ; EXP
        DEFB    $C1                       ; STR$
        DEFB    $B8                       ; LN


ext_shift:
;  The 26 shifted extended mode keys for the alphabetic characters.
;  The red keywords below keys on the original keyboard.
        DEFB    $7E                       ; ~
        DEFB    $DC                       ; BRIGHT
        DEFB    $DA                       ; PAPER
        DEFB    $5C                       ; \
        DEFB    $B7                       ; ATN
        DEFB    $7B                       ; {
        DEFB    $7D                       ; }
        DEFB    $D8                       ; CIRCLE
        DEFB    $BF                       ; IN
        DEFB    $AE                       ; VAL$
        DEFB    $AA                       ; SCREEN$
        DEFB    $AB                       ; ATTR
        DEFB    $DD                       ; INVERSE
        DEFB    $DE                       ; OVER
        DEFB    $DF                       ; OUT
        DEFB    $7F                       ; (Copyright character)
        DEFB    $B5                       ; ASN
        DEFB    $D6                       ; VERIFY
        DEFB    $7C                       ; |
        DEFB    $D5                       ; MERGE
        DEFB    $5D                       ; ]
        DEFB    $DB                       ; FLASH
        DEFB    $B6                       ; ACS
        DEFB    $D9                       ; INK
        DEFB    $5B                       ; [
        DEFB    $D7                       ; BEEP


ctl_codes:
;  The ten control codes assigned to the top line of digits when the shift
;  key is pressed.
        DEFB    $0C                       ; DELETE
        DEFB    $07                       ; EDIT
        DEFB    $06                       ; CAPS LOCK
        DEFB    $04                       ; TRUE VIDEO
        DEFB    $05                       ; INVERSE VIDEO
        DEFB    $08                       ; CURSOR LEFT
        DEFB    $0A                       ; CURSOR DOWN
        DEFB    $0B                       ; CURSOR UP
        DEFB    $09                       ; CURSOR RIGHT
        DEFB    $0F                       ; GRAPHICS


sym_codes:
;  The 26 red symbols assigned to the alphabetic characters of the keyboard.
;  The ten single-character digit symbols are converted without the aid of
;  a table using subtraction and minor manipulation.
        DEFB    $E2                       ; STOP
        DEFB    $2A                       ; *
        DEFB    $3F                       ; ?
        DEFB    $CD                       ; STEP
        DEFB    $C8                       ; >=
        DEFB    $CC                       ; TO
        DEFB    $CB                       ; THEN
        DEFB    $5E                       ; ^
        DEFB    $AC                       ; AT
        DEFB    $2D                       ; -
        DEFB    $2B                       ; +
        DEFB    $3D                       ; =
        DEFB    $2E                       ; .
        DEFB    $2C                       ; ,
        DEFB    $3B                       ; ;
        DEFB    $22                       ; "
        DEFB    $C7                       ; <=
        DEFB    $3C                       ; <
        DEFB    $C3                       ; NOT
        DEFB    $3E                       ; >
        DEFB    $C5                       ; OR
        DEFB    $2F                       ; /
        DEFB    $C9                       ; <>
        DEFB    $60                       ; pound
        DEFB    $C6                       ; AND
        DEFB    $3A                       ; :

e_digits:
;  The ten keywords assigned to the digits in extended mode.
;  The remaining red keywords below the keys.
        DEFB    $D0                       ; FORMAT
        DEFB    $CE                       ; DEF FN
        DEFB    $A8                       ; FN
        DEFB    $CA                       ; LINE
        DEFB    $D3                       ; OPEN#
        DEFB    $D4                       ; CLOSE#
        DEFB    $D1                       ; MOVE
        DEFB    $D2                       ; ERASE
        DEFB    $A9                       ; POINT
        DEFB    $CF                       ; CAT


;*******************************
;** Part 2. KEYBOARD ROUTINES **
;*******************************

; Using shift keys and a combination of modes the Spectrum 40-key keyboard
; can be mapped to 256 input characters

; ---------------------------------------------------------------------------
;
;         0     1     2     3     4 -Bits-  4     3     2     1     0
; PORT                                                                    PORT
;
; F7FE  [ 1 ] [ 2 ] [ 3 ] [ 4 ] [ 5 ]  |  [ 6 ] [ 7 ] [ 8 ] [ 9 ] [ 0 ]   EFFE
;  ^                                   |                                   v
; FBFE  [ Q ] [ W ] [ E ] [ R ] [ T ]  |  [ Y ] [ U ] [ I ] [ O ] [ P ]   DFFE
;  ^                                   |                                   v
; FDFE  [ A ] [ S ] [ D ] [ F ] [ G ]  |  [ H ] [ J ] [ K ] [ L ] [ ENT ] BFFE
;  ^                                   |                                   v
; FEFE  [SHI] [ Z ] [ X ] [ C ] [ V ]  |  [ B ] [ N ] [ M ] [sym] [ SPC ] 7FFE
;  ^     $27                                                 $18           v
; Start                                                                   End
;        00100111                                            00011000
;
; ---------------------------------------------------------------------------
; The above map may help in reading.
; The neat arrangement of ports means that the B register need only be
; rotated left to work up the left hand side and then down the right
; hand side of the keyboard. When the reset bit drops into the carry
; then all 8 half-rows have been read. Shift is the first key to be
; read. The lower six bits of the shifts are unambiguous.

; -------------------------------
; THE 'KEYBOARD SCANNING' ROUTINE
; -------------------------------
; from keyboard and s-inkey$
; returns 1 or 2 keys in DE, most significant shift first if any
; key values 0-39 else 255

key_scan:
        LD      L,$2F                     ; initial key value
                                          ; valid values are obtained by subtracting
                                          ; eight five times.
        LD      DE,$FFFF                  ; a buffer to receive 2 keys.

        LD      BC,$FEFE                  ; the commencing port address
                                          ; B holds 11111110 initially and is also
                                          ; used to count the 8 half-rows
key_line:
        IN      A,(C)                     ; read the port to A - bits will be reset
                                          ; if a key is pressed else set.
        CPL                               ; complement - pressed key-bits are now set
        AND     $1F                       ; apply 00011111 mask to pick up the
                                          ; relevant set bits.

        JR      Z,key_done                ; forward to KEY-DONE if zero and therefore
                                          ; no keys pressed in row at all.

        LD      H,A                       ; transfer row bits to H
        LD      A,L                       ; load the initial key value to A

key_3keys:
        INC     D                         ; now test the key buffer
        RET     NZ                        ; if we have collected 2 keys already
                                          ; then too many so quit.

key_bits:
        SUB     $08                       ; subtract 8 from the key value
                                          ; cycling through key values (top = $27)
                                          ; e.g. 2F>   27>1F>17>0F>07
                                          ;      2E>   26>1E>16>0E>06
        SRL     H                         ; shift key bits right into carry.
        JR      NC,key_bits               ; back to KEY-BITS if not pressed
                                          ; but if pressed we have a value (0-39d)

        LD      D,E                       ; transfer a possible previous key to D
        LD      E,A                       ; transfer the new key to E
        JR      NZ,key_3keys              ; back to KEY-3KEYS if there were more
                                          ; set bits - H was not yet zero.

key_done:
        DEC     L                         ; cycles 2F>2E>2D>2C>2B>2A>29>28 for
                                          ; each half-row.
        RLC     B                         ; form next port address e.g. FEFE > FDFE
        JR      C,key_line                ; back to KEY-LINE if still more rows to do.

        LD      A,D                       ; now test if D is still FF ?
        INC     A                         ; if it is zero we have at most 1 key
                                          ; range now $01-$28  (1-40d)
        RET     Z                         ; return if one key or no key.

        CP      $28                       ; is it capsshift (was $27) ?
        RET     Z                         ; return if so.

        CP      $19                       ; is it symbol shift (was $18) ?
        RET     Z                         ; return also

        LD      A,E                       ; now test E
        LD      E,D                       ; but first switch
        LD      D,A                       ; the two keys.
        CP      $18                       ; is it symbol shift ?
        RET                               ; return (with zero set if it was).
                                          ; but with symbol shift now in D

; ------------------------------
; Scan keyboard and decode value
; ------------------------------
; from interrupt 50 times a second
;

keyboard:
        CALL    key_scan                  ; routine KEY-SCAN
        RET     NZ                        ; return if invalid combinations

; then decrease the counters within the two key-state maps
; as this could cause one to become free.
; if the keyboard has not been pressed during the last five interrupts
; then both sets will be free.


        LD      HL,KSTATE                 ; point to KSTATE-0

k_st_loop:
        BIT     7,(HL)                    ; is it free ?  ($FF)
        JR      NZ,k_ch_set               ; forward to K-CH-SET if so

        INC     HL                        ; address 5-counter
        DEC     (HL)                      ; decrease counter
        DEC     HL                        ; step back
        JR      NZ,k_ch_set               ; forward to K-CH-SET if not at end of count

        LD      (HL),$FF                  ; else mark it free.

k_ch_set:
        LD      A,L                       ; store low address byte.
        LD      HL,KSTATE_04              ; point to KSTATE-4
                                          ; (ld l, $04)
        CP      L                         ; have 2 been done ?
        JR      NZ,k_st_loop              ; back to K-ST-LOOP to consider this 2nd set

; now the raw key (0-38) is converted to a main key (uppercase).

        CALL    k_test                    ; routine K-TEST to get main key in A
        RET     NC                        ; return if single shift

        LD      HL,KSTATE                 ; point to KSTATE-0
        CP      (HL)                      ; does it match ?
        JR      Z,k_repeat                ; forward to K-REPEAT if so

; if not consider the second key map.

        EX      DE,HL                     ; save kstate-0 in de
        LD      HL,KSTATE_04              ; point to KSTATE-4
        CP      (HL)                      ; does it match ?
        JR      Z,k_repeat                ; forward to K-REPEAT if so

; having excluded a repeating key we can now consider a new key.
; the second set is always examined before the first.

        BIT     7,(HL)                    ; is it free ?
        JR      NZ,k_new                  ; forward to K-NEW if so.

        EX      DE,HL                     ; bring back kstate-0
        BIT     7,(HL)                    ; is it free ?
        RET     Z                         ; return if not.
                                          ; as we have a key but nowhere to put it yet.

; continue or jump to here if one of the buffers was free.

k_new:
        LD      E,A                       ; store key in E
        LD      (HL),A                    ; place in free location
        INC     HL                        ; advance to interrupt counter
        LD      (HL),$05                  ; and initialize to 5
        INC     HL                        ; advance to delay
        LD      A,(REPDEL)                ; pick up system variable REPDEL
        LD      (HL),A                    ; and insert that for first repeat delay.
        INC     HL                        ; advance to last location of state map.

        LD      C,(IY+(MODE-C_IY))        ; pick up MODE  (3 bytes)

        LD      D,(IY+(FLAGS-C_IY))       ; pick up FLAGS (3 bytes)
        PUSH    HL                        ; save state map location
                                          ; Note. could now have used.
                                          ; ld l,$41; ld c,(hl); ld l,$3B; ld d,(hl).
                                          ; six and two threes of course.
        CALL    k_decode                  ; routine K-DECODE
        POP     HL                        ; restore map pointer
        LD      (HL),A                    ; put decoded key in last location of map.

k_end:
        LD      (LASTK),A                 ; update LASTK system variable.
        SET     5,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal new key.
        RET                               ; done

; ---------------------------
; THE 'REPEAT KEY' SUBROUTINE
; ---------------------------
; A possible repeat has been identified. HL addresses the raw (main) key.
; The last location holds the decoded key (from the first context).

k_repeat:
        INC     HL                        ; advance
        LD      (HL),$05                  ; maintain interrupt counter at 5
        INC     HL                        ; advance
        DEC     (HL)                      ; decrease REPDEL value.
        RET     NZ                        ; return if not yet zero.

        LD      A,(REPPER)                ; REPPER
        LD      (HL),A                    ; but for subsequent repeats REPPER will be used.
        INC     HL                        ; advance
                                          ;
        LD      A,(HL)                    ; pick up the key decoded possibly in another
                                          ; context.
        JR      k_end                     ; back to K-END

; --------------
; Test key value
; --------------
; also called from s-inkey$
; begin by testing for a shift with no other.

k_test:
        LD      B,D                       ; load most significant key to B
                                          ; will be $FF if not shift.
        LD      D,$00                     ; and reset D to index into main table
        LD      A,E                       ; load least significant key from E
        CP      $27                       ; is it higher than 39d   i.e. FF
        RET     NC                        ; return with just a shift (in B now)

        CP      $18                       ; is it symbol shift ?
        JR      NZ,k_main                 ; forward to K-MAIN if not

; but we could have just symbol shift and no other

        BIT     7,B                       ; is other key $FF (ie not shift)
        RET     NZ                        ; return with solitary symbol shift


k_main:
        LD      HL,main_keys              ; address: MAIN-KEYS
        ADD     HL,DE                     ; add offset 0-38
        LD      A,(HL)                    ; pick up main key value
        SCF                               ; set carry flag
        RET                               ; return    (B has other key still)

; -----------------
; Keyboard decoding
; -----------------
; also called from s-inkey$

k_decode:
        LD      A,E                       ; pick up the stored main key
        CP      $3A                       ; an arbitrary point between digits and letters
        JR      C,k_digit                 ; forward to K-DIGIT with digits, space, enter.

        DEC     C                         ; decrease MODE ( 0='KLC', 1='E', 2='G')

        JP      M,k_klc_let               ; to K-KLC-LET if was zero

        JR      Z,k_e_let                 ; to K-E-LET if was 1 for extended letters.

; proceed with graphic codes.
; Note. should selectively drop return address if code > 'U' ($55).
; i.e. abort the KEYBOARD call.
; e.g. cp 'V'; jr c addit; pop af; ;;addit etc. (5 bytes of instruction).
; (s-inkey$ never gets into graphics mode.)

addit:
        ADD     A,$4F                     ; add offset to augment 'A' to graphics A say.
        RET                               ; return.
                                          ; Note. ( but [GRAPH] V gives RND, etc ).

; ---

; the jump was to here with extended mode with uppercase A-Z.

k_e_let:
        LD      HL,e_unshift-$41          ; base address of E-UNSHIFT L022c
                                          ; ( $01EB in standard ROM )
        INC     B                         ; test B is it empty i.e. not a shift
        JR      Z,k_look_up               ; forward to K-LOOK-UP if neither shift

        LD      HL,ext_shift-$41          ; Address: main_keys ext_shift-$41 EXT-SHIFT base

k_look_up:
        LD      D,$00                     ; prepare to index
        ADD     HL,DE                     ; add the main key value
        LD      A,(HL)                    ; pick up other mode value
        RET                               ; return

; ---

; the jump was here with mode = 0

k_klc_let:
        LD      HL,sym_codes-$41          ; prepare base of sym-codes
        BIT     0,B                       ; shift=$27 sym-shift=$18
        JR      Z,k_look_up               ; back to K-LOOK-UP with symbol-shift

        BIT     3,D                       ; test FLAGS is it 'K' mode (from OUT-CURS)
        JR      Z,k_tokens                ; skip to K-TOKENS if so

        BIT     3,(IY+(FLAGS2-C_IY))      ; test FLAGS2 - consider CAPS LOCK ?
        RET     NZ                        ; return if so with main code.

        INC     B                         ; is shift being pressed ?
                                          ; result zero if not
        RET     NZ                        ; return if shift pressed.

        ADD     A,$20                     ; else convert the code to lower case.
        RET                               ; return.

; ---

; the jump was here for tokens

k_tokens:
        ADD     A,$A5                     ; add offset to main code so that 'A'
                                          ; becomes 'NEW' etc.
        RET                               ; return

; ---

; the jump was here with digits, space, enter and symbol shift (< $xx)

k_digit:
        CP      $30                       ; is it '0' or higher ?
        RET     C                         ; return with space, enter and symbol-shift

        DEC     C                         ; test MODE (was 0='KLC', 1='E', 2='G')
        JP      M,k_klc_dgt               ; jump to K-KLC-DGT if was 0.

        JR      NZ,k_gra_dgt              ; forward to K-GRA-DGT if mode was 2.

; continue with extended digits 0-9.

        LD      HL,e_digits-$30           ; $0254 - base of E-DIGITS
        BIT     5,B                       ; test - shift=$27 sym-shift=$18
        JR      Z,k_look_up               ; to K-LOOK-UP if sym-shift

        CP      $38                       ; is character '8' ?
        JR      NC,k_8_and_9              ; to K-8-&-9 if greater than '7'

        SUB     $20                       ; reduce to ink range $10-$17
        INC     B                         ; shift ?
        RET     Z                         ; return if not.

        ADD     A,$08                     ; add 8 to give paper range $18 - $1F
        RET                               ; return

; ---

; 89

k_8_and_9:
        SUB     $36                       ; reduce to 02 and 03  bright codes
        INC     B                         ; test if shift pressed.
        RET     Z                         ; return if not.

        ADD     A,$FE                     ; subtract 2 setting carry
        RET                               ; to give 0 and 1    flash codes.

; ---

;  graphics mode with digits

k_gra_dgt:
        LD      HL,ctl_codes-$30          ; $0230 base address of CTL-CODES

        CP      $39                       ; is key '9' ?
        JR      Z,k_look_up               ; back to K-LOOK-UP - changed to $0F, GRAPHICS.

        CP      $30                       ; is key '0' ?
        JR      Z,k_look_up               ; back to K-LOOK-UP - changed to $0C, delete.

; for keys '0' - '7' we assign a mosaic character depending on shift.

        AND     $07                       ; convert character to number. 0 - 7.
        ADD     A,$80                     ; add offset - they start at $80

        INC     B                         ; destructively test for shift
        RET     Z                         ; and return if not pressed.

        XOR     $0F                       ; toggle bits becomes range $88-$8F
        RET                               ; return.

; ---

; now digits in 'KLC' mode

k_klc_dgt:
        INC     B                         ; return with digit codes if neither
        RET     Z                         ; shift key pressed.

        BIT     5,B                       ; test for caps shift.

        LD      HL,ctl_codes-$30          ; prepare base of table CTL-CODES.
        JR      NZ,k_look_up              ; back to K-LOOK-UP if shift pressed.

; must have been symbol shift

        SUB     $10                       ; for ASCII most will now be correct
                                          ; on a standard typewriter.
        CP      $22                       ; but '@' is not - see below.
        JR      Z,k_at_char               ; forward to to K-@-CHAR if so

        CP      $20                       ; '_' is the other one that fails
        RET     NZ                        ; return if not.

        LD      A,$5F                     ; substitute ASCII '_'
        RET                               ; return.

; ---

k_at_char:
        LD      A,$40                     ; substitute ASCII '@'
        RET                               ; return.


; ------------------------------------------------------------------------
; The Spectrum Input character keys. One or two are abbreviated.
; From $00 Flash 0 to $FF COPY. The routine above has decoded all these.

;  | 00 Fl0| 01 Fl1| 02 Br0| 03 Br1| 04 In0| 05 In1| 06 CAP| 07 EDT|
;  | 08 LFT| 09 RIG| 0A DWN| 0B UP | 0C DEL| 0D ENT| 0E SYM| 0F GRA|
;  | 10 Ik0| 11 Ik1| 12 Ik2| 13 Ik3| 14 Ik4| 15 Ik5| 16 Ik6| 17 Ik7|
;  | 18 Pa0| 19 Pa1| 1A Pa2| 1B Pa3| 1C Pa4| 1D Pa5| 1E Pa6| 1F Pa7|
;  | 20 SP | 21  ! | 22  " | 23  # | 24  $ | 25  % | 26  & | 27  ' |
;  | 28  ( | 29  ) | 2A  * | 2B  + | 2C  , | 2D  - | 2E  . | 2F  / |
;  | 30  0 | 31  1 | 32  2 | 33  3 | 34  4 | 35  5 | 36  6 | 37  7 |
;  | 38  8 | 39  9 | 3A  : | 3B  ; | 3C  < | 3D  = | 3E  > | 3F  ? |
;  | 40  @ | 41  A | 42  B | 43  C | 44  D | 45  E | 46  F | 47  G |
;  | 48  H | 49  I | 4A  J | 4B  K | 4C  L | 4D  M | 4E  N | 4F  O |
;  | 50  P | 51  Q | 52  R | 53  S | 54  T | 55  U | 56  V | 57  W |
;  | 58  X | 59  Y | 5A  Z | 5B  [ | 5C  \ | 5D  ] | 5E  ^ | 5F  _ |
;  | 60 ukp| 61  a | 62  b | 63  c | 64  d | 65  e | 66  f | 67  g |
;  | 68  h | 69  i | 6A  j | 6B  k | 6C  l | 6D  m | 6E  n | 6F  o |
;  | 70  p | 71  q | 72  r | 73  s | 74  t | 75  u | 76  v | 77  w |
;  | 78  x | 79  y | 7A  z | 7B  { | 7C  | | 7D  } | 7E  ~ | 7F (c)|
;  | 80 128| 81 129| 82 130| 83 131| 84 132| 85 133| 86 134| 87 135|
;  | 88 136| 89 137| 8A 138| 8B 139| 8C 140| 8D 141| 8E 142| 8F 143|
;  | 90 [A]| 91 [B]| 92 [C]| 93 [D]| 94 [E]| 95 [F]| 96 [G]| 97 [H]|
;  | 98 [I]| 99 [J]| 9A [K]| 9B [L]| 9C [M]| 9D [N]| 9E [O]| 9F [P]|
;  | A0 [Q]| A1 [R]| A2 [S]| A3 [T]| A4 [U]| A5 RND| A6 IK$| A7 PI |
;  | A8 FN | A9 PNT| AA SC$| AB ATT| AC AT | AD TAB| AE VL$| AF COD|
;  | B0 VAL| B1 LEN| B2 SIN| B3 COS| B4 TAN| B5 ASN| B6 ACS| B7 ATN|
;  | B8 LN | B9 EXP| BA INT| BB SQR| BC SGN| BD ABS| BE PEK| BF IN |
;  | C0 USR| C1 ST$| C2 CH$| C3 NOT| C4 BIN| C5 OR | C6 AND| C7 <= |
;  | C8 >= | C9 <> | CA LIN| CB THN| CC TO | CD STP| CE DEF| CF CAT|
;  | D0 FMT| D1 MOV| D2 ERS| D3 OPN| D4 CLO| D5 MRG| D6 VFY| D7 BEP|
;  | D8 CIR| D9 INK| DA PAP| DB FLA| DC BRI| DD INV| DE OVR| DF OUT|
;  | E0 LPR| E1 LLI| E2 STP| E3 REA| E4 DAT| E5 RES| E6 NEW| E7 BDR|
;  | E8 CON| E9 DIM| EA REM| EB FOR| EC GTO| ED GSB| EE INP| EF LOA|
;  | F0 LIS| F1 LET| F2 PAU| F3 NXT| F4 POK| F5 PRI| F6 PLO| F7 RUN|
;  | F8 SAV| F9 RAN| FA IF | FB CLS| FC DRW| FD CLR| FE RET| FF CPY|

; Note that for simplicity, Sinclair have located all the control codes
; below the space character.
; ASCII DEL, $7F, has been made a copyright symbol.
; Also $60, '`', not used in BASIC but used in other languages, has been
; allocated the local currency symbol for the relevant country -
; ukp in most Spectrums.

; ------------------------------------------------------------------------

;**********************************
;** Part 3. LOUDSPEAKER ROUTINES **
;**********************************


; Documented by Alvin Albrecht.


; ------------------------------
; Routine to control loudspeaker
; ------------------------------
; Outputs a square wave of given duration and frequency
; to the loudspeaker.
;   Enter with: DE = #cycles - 1
;               HL = tone period as described next
;
; The tone period is measured in T states and consists of
; three parts: a coarse part (H register), a medium part
; (bits 7..2 of L) and a fine part (bits 1..0 of L) which
; contribute to the waveform timing as follows:
;
;                          coarse    medium       fine
; duration of low  = 118 + 1024*H + 16*(L>>2) + 4*(L&0x3)
; duration of hi   = 118 + 1024*H + 16*(L>>2) + 4*(L&0x3)
; Tp = tone period = 236 + 2048*H + 32*(L>>2) + 8*(L&0x3)
;                  = 236 + 2048*H + 8*L = 236 + 8*HL
;
; As an example, to output five seconds of middle C (261.624 Hz):
;   (a) Tone period = 1/261.624 = 3.822ms
;   (b) Tone period in T-States = 3.822ms*fCPU = 13378
;         where fCPU = clock frequency of the CPU = 3.5 MHz
;   (c) Find H and L for desired tone period:
;         HL = (Tp - 236) / 8 = (13378 - 236) / 8 = 1643 = 0x066B
;   (d) Tone duration in cycles = 5s/3.822ms = 1308 cycles
;         DE = 1308 - 1 = 0x051B
;
; The resulting waveform has a duty ratio of exactly 50%.
;
;
beeper:
        DI                                ; Disable Interrupts so they don't disturb timing
        LD      A,L                       ;
        SRL     L                         ;
        SRL     L                         ; L = medium part of tone period
        CPL                               ;
        AND     $03                       ; A = 3 - fine part of tone period
        LD      C,A                       ;
        LD      B,$00                     ;
        LD      IX,be_ix_plus_3           ; Address: BE-IX+3
        ADD     IX,BC                     ;   IX holds address of entry into the loop
                                          ;   the loop will contain 0-3 NOPs, implementing
                                          ;   the fine part of the tone period.
        LD      A,(BORDCR)                ; BORDCR
        AND     $38                       ; bits 5..3 contain border colour
        RRCA                              ; border colour bits moved to 2..0
        RRCA                              ;   to match border bits on port #FE
        RRCA                              ;
        OR       $08                      ; bit 3 set (tape output bit on port #FE)
                                          ;   for loud sound output
be_ix_plus_3:
        NOP                               ;(4)   ; optionally executed NOPs for small
                                          ;   adjustments to tone period
be_ix_plus_2:
        NOP                               ;(4)   ;

be_ix_plus_1:
        NOP                               ;(4)   ;

be_ix_plus_0:
        INC     B                         ;(4)   ;
        INC     C                         ;(4)   ;

be_handl_lp:
        DEC     C                         ;(4)   ; timing loop for duration of
        JR      NZ,be_handl_lp            ;(12/7);   high or low pulse of waveform

        LD      C,$3F                     ;(7)   ;
        DEC     B                         ;(4)   ;
        JP      NZ,be_handl_lp            ;(10)  ; to BE-H&L-LP

        XOR     $10                       ;(7)   ; toggle output beep bit
        OUT     ($FE),A                   ;(11)  ; output pulse
        LD      B,H                       ;(4)   ; B = coarse part of tone period
        LD      C,A                       ;(4)   ; save port #FE output byte
        BIT     4,A                       ;(8)   ; if new output bit is high, go
        JR      NZ,be_again               ;(12/7);   to BE-AGAIN

        LD      A,D                       ;(4)   ; one cycle of waveform has completed
        OR      E                         ;(4)   ;   (low->low). if cycle countdown = 0
        JR      Z,be_end                  ;(12/7);   go to BE-END

        LD      A,C                       ;(4)   ; restore output byte for port #FE
        LD      C,L                       ;(4)   ; C = medium part of tone period
        DEC     DE                        ;(6)   ; decrement cycle count
        JP      (IX)                      ;(8)   ; do another cycle

be_again:                                 ; halfway through cycle
        LD      C,L                       ;(4)   ; C = medium part of tone period
        INC     C                         ;(4)   ; adds 16 cycles to make duration of high = duration of low
        JP      (IX)                      ;(8)   ; do high pulse of tone

be_end:
        EI                                ; Enable Interrupts
        RET                               ;


; -------------------
; Handle BEEP command
; -------------------
; BASIC interface to BEEPER subroutine.
; Invoked in BASIC with:
;   BEEP dur, pitch
;   where dur   = duration in seconds
;         pitch = # of semitones above/below middle C
;
; Enter with: pitch on top of calculator stack
;             duration next on calculator stack
;
beep:
        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate                  ; duplicate pitch
        DEFB    $27                       ;;int                        ; convert to integer
        DEFB    $C0                       ;;st-mem-0                   ; store integer pitch to memory 0
        DEFB    $03                       ;;subtract                   ; calculate fractional part of pitch = fp_pitch - int_pitch
        DEFB    $34                       ;;stk-data                   ; push constant
        DEFB    $EC                       ;;Exponent: $7C, Bytes: 4    ; constant = 0.05762265
        DEFB    $6C,$98,$1F,$F5           ;;($6C,$98,$1F,$F5)
        DEFB    $04                       ;;multiply                   ; compute:
        DEFB    $A1                       ;;stk-one                    ; 1 + 0.05762265 * fraction_part(pitch)
        DEFB    $0F                       ;;addition
        DEFB    $38                       ;;end-calc                   ; leave on calc stack

        LD      HL,MEMBOT                 ; MEM-0: number stored here is in 16 bit integer format (pitch)
                                          ;   0, 0/FF (pos/neg), LSB, MSB, 0
                                          ;   LSB/MSB is stored in two's complement
                                          ; In the following, the pitch is checked if it is in the range -128<=p<=127
        LD      A,(HL)                    ; First byte must be zero, otherwise
        AND     A                         ;   error in integer conversion
        JR      NZ,report_b               ; to REPORT-B

        INC     HL                        ;
        LD      C,(HL)                    ; C = pos/neg flag = 0/FF
        INC     HL                        ;
        LD      B,(HL)                    ; B = LSB, two's complement
        LD      A,B                       ;
        RLA                               ;
        SBC     A,A                       ; A = 0/FF if B is pos/neg
        CP      C                         ; must be the same as C if the pitch is -128<=p<=127
        JR      NZ,report_b               ; if no, error REPORT-B

        INC     HL                        ; if -128<=p<=127, MSB will be 0/FF if B is pos/neg
        CP      (HL)                      ; verify this
        JR      NZ,report_b               ; if no, error REPORT-B
                                          ; now we know -128<=p<=127
        LD      A,B                       ; A = pitch + 60
        ADD     A,$3C                     ; if -60<=pitch<=67,
        JP      P,be_i_ok                 ;   goto BE-i-OK

        JP      PO,report_b               ; if pitch <= 67 goto REPORT-B
                                          ;   lower bound of pitch set at -60

be_i_ok:                                  ; here, -60<=pitch<=127
                                          ; and A=pitch+60 -> 0<=A<=187

        LD      B,$FA                     ; 6 octaves below middle C

be_octave:                                ; A=# semitones above 5 octaves below middle C
        INC     B                         ; increment octave
        SUB     $0C                       ; 12 semitones = one octave
        JR      NC,be_octave              ; to BE-OCTAVE

        ADD     A,$0C                     ; A = # semitones above C (0-11)
        PUSH    BC                        ; B = octave displacement from middle C, 2's complement: -5<=B<=10
        LD      HL,semi_tone              ; Address: semi-tone
        CALL    loc_mem                   ; routine LOC-MEM
                                          ;   HL = 5*A + semi_tone
        CALL    stack_num                 ; routine STACK-NUM
                                          ;   read FP value (freq) from semitone table (HL) and push onto calc stack

        RST     28H                       ;; FP-CALC
        DEFB    $04                       ;;multiply   mult freq by 1 + 0.0576 * fraction_part(pitch) stacked earlier
                                          ;;             thus taking into account fractional part of pitch.
                                          ;;           the number 0.0576*frequency is the distance in Hz to the next
                                          ;;             note (verify with the frequencies recorded in the semitone
                                          ;;             table below) so that the fraction_part of the pitch does
                                          ;;             indeed represent a fractional distance to the next note.
        DEFB    $38                       ;;end-calc   HL points to first byte of fp num on stack = middle frequency to generate

        POP     AF                        ; A = octave displacement from middle C, 2's complement: -5<=A<=10
        ADD     A,(HL)                    ; increase exponent by A (equivalent to multiplying by 2^A)
        LD      (HL),A                    ;

        RST     28H                       ;; FP-CALC
        DEFB    $C0                       ;;st-mem-0          ; store frequency in memory 0
        DEFB    $02                       ;;delete            ; remove from calc stack
        DEFB    $31                       ;;duplicate         ; duplicate duration (seconds)
        DEFB    $38                       ;;end-calc

        CALL    find_int1                 ; routine FIND-INT1 ; FP duration to A
        CP      $0B                       ; if dur > 10 seconds,
        JR      NC,report_b               ;   goto REPORT-B

        ;;; The following calculation finds the tone period for HL and the cycle count
        ;;; for DE expected in the BEEPER subroutine.  From the example in the BEEPER comments,
        ;;;
        ;;; HL = ((fCPU / f) - 236) / 8 = fCPU/8/f - 236/8 = 437500/f -29.5
        ;;; DE = duration * frequency - 1
        ;;;
        ;;; Note the different constant (30.125) used in the calculation of HL
        ;;; below.  This is probably an error.

        RST     28H                       ;; FP-CALC
        DEFB    $E0                       ;;get-mem-0                 ; push frequency
        DEFB    $04                       ;;multiply                  ; result1: #cycles = duration * frequency
        DEFB    $E0                       ;;get-mem-0                 ; push frequency
        DEFB    $34                       ;;stk-data                  ; push constant
        DEFB    $80                       ;;Exponent $93, Bytes: 3    ; constant = 437500
        DEFB    $43,$55,$9F,$80           ;;($55,$9F,$80,$00)
        DEFB    $01                       ;;exchange                  ; frequency on top
        DEFB    $05                       ;;division                  ; 437500 / frequency
        DEFB    $34                       ;;stk-data                  ; push constant
        DEFB    $35                       ;;Exponent: $85, Bytes: 1   ; constant = 30.125
        DEFB    $71                       ;;($71,$00,$00,$00)
        DEFB    $03                       ;;subtract                  ; result2: tone_period(HL) = 437500 / freq - 30.125
        DEFB    $38                       ;;end-calc

        CALL    find_int2                 ; routine FIND-INT2
        PUSH    BC                        ;   BC = tone_period(HL)
        CALL    find_int2                 ; routine FIND-INT2, BC = #cycles to generate
        POP     HL                        ; HL = tone period
        LD      D,B                       ;
        LD      E,C                       ; DE = #cycles
        LD      A,D                       ;
        OR      E                         ;
        RET     Z                         ; if duration = 0, skip BEEP and avoid 65536 cycle
                                          ;   boondoggle that would occur next
        DEC     DE                        ; DE = #cycles - 1
        JP      beeper                    ; to BEEPER

; ---


report_b:
        RST     08H                       ; ERROR-1
        DEFB    $0A                       ; Error Report: Integer out of range



; ---------------
; Semi-tone table
; ---------------
;
; Holds frequencies corresponding to semitones in middle octave.
; To move n octaves higher or lower, frequencies are multiplied by 2^n.

;                    five byte fp         decimal freq     note (middle)
semi_tone:
        DEFB    $89, $02, $D0, $12, $86   ;  261.625565290         C
        DEFB    $89, $0A, $97, $60, $75   ;  277.182631135         C#
        DEFB    $89, $12, $D5, $17, $1F   ;  293.664768100         D
        DEFB    $89, $1B, $90, $41, $02   ;  311.126983881         D#
        DEFB    $89, $24, $D0, $53, $CA   ;  329.627557039         E
        DEFB    $89, $2E, $9D, $36, $B1   ;  349.228231549         F
        DEFB    $89, $38, $FF, $49, $3E   ;  369.994422674         F#
        DEFB    $89, $43, $FF, $6A, $73   ;  391.995436072         G
        DEFB    $89, $4F, $A7, $00, $54   ;  415.304697513         G#
        DEFB    $89, $5C, $00, $00, $00   ;  440.000000000         A
        DEFB    $89, $69, $14, $F6, $24   ;  466.163761616         A#
        DEFB    $89, $76, $F1, $10, $05   ;  493.883301378         B


;****************************************
;** Part 4. CASSETTE HANDLING ROUTINES **
;****************************************

; These routines begin with the service routines followed by a single
; command entry point.
; The first of these service routines is a curiosity.

; -----------------------
; THE 'ZX81 NAME' ROUTINE
; -----------------------
;   This routine fetches a filename in ZX81 format and is not used by the
;   cassette handling routines in this ROM.

zx81_name:
        CALL    scanning                  ; routine SCANNING to evaluate expression.
        LD      A,(FLAGS)                 ; fetch system variable FLAGS.
        ADD     A,A                       ; test bit 7 - syntax, bit 6 - result type.
        JP      M,report_c                ; to REPORT-C if not string result
                                          ; 'Nonsense in BASIC'.

        POP     HL                        ; drop return address.
        RET     NC                        ; return early if checking syntax.

        PUSH    HL                        ; re-save return address.
        CALL    stk_fetch                 ; routine STK-FETCH fetches string parameters.
        LD      H,D                       ; transfer start of filename
        LD      L,E                       ; to the HL register.
        DEC     C                         ; adjust to point to last character and
        RET     M                         ; return if the null string.
                                          ; or multiple of 256!

        ADD     HL,BC                     ; find last character of the filename.
                                          ; and also clear carry.
        SET     7,(HL)                    ; invert it.
        RET                               ; return.

; =========================================
;
; PORT 254 ($FE)
;
;                      spk mic { border  }
;          ___ ___ ___ ___ ___ ___ ___ ___
; PORT    |   |   |   |   |   |   |   |   |
; 254     |   |   |   |   |   |   |   |   |
; $FE     |___|___|___|___|___|___|___|___|
;           7   6   5   4   3   2   1   0
;

; ----------------------------------
; Save header and program/data bytes
; ----------------------------------
; This routine saves a section of data. It is called from SA-CTRL to save the
; seventeen bytes of header data. It is also the exit route from that routine
; when it is set up to save the actual data.
; On entry -
; HL points to start of data.
; IX points to descriptor.
; The accumulator is set to  $00 for a header, $FF for data.

sa_bytes:
        LD      HL,saslashld_ret          ; address: SA/LD-RET
        PUSH    HL                        ; is pushed as common exit route.
                                          ; however there is only one non-terminal exit
                                          ; point.

        LD      HL,$1F80                  ; a timing constant H=$1F, L=$80
                                          ; inner and outer loop counters
                                          ; a five second lead-in is used for a header.

        BIT     7,A                       ; test one bit of accumulator.
                                          ; (AND A ?)
        JR      Z,sa_flag                 ; skip to SA-FLAG if a header is being saved.

; else is data bytes and a shorter lead-in is used.

        LD      HL,$0C98                  ; another timing value H=$0C, L=$98.
                                          ; a two second lead-in is used for the data.


sa_flag:
        EX      AF,AF'                    ; save flag
        INC     DE                        ; increase length by one.
        DEC     IX                        ; decrease start.

        DI                                ; disable interrupts

        LD      A,$02                     ; select red for border, microphone bit on.
        LD      B,A                       ; also does as an initial slight counter value.

sa_leader:
        DJNZ    sa_leader                 ; self loop to SA-LEADER for delay.
                                          ; after initial loop, count is $A4 (or $A3)

        OUT     ($FE),A                   ; output byte $02/$0D to tape port.

        XOR     $0F                       ; switch from RED (mic on) to CYAN (mic off).

        LD      B,$A4                     ; hold count. also timed instruction.

        DEC     L                         ; originally $80 or $98.
                                          ; but subsequently cycles 256 times.
        JR      NZ,sa_leader              ; back to SA-LEADER until L is zero.

; the outer loop is counted by H

        DEC     B                         ; decrement count
        DEC     H                         ; originally  twelve or thirty-one.
        JP      P,sa_leader               ; back to SA-LEADER until H becomes $FF

; now send a synch pulse. At this stage mic is off and A holds value
; for mic on.
; A synch pulse is much shorter than the steady pulses of the lead-in.

        LD      B,$2F                     ; another short timed delay.

sa_sync_1:
        DJNZ    sa_sync_1                 ; self loop to SA-SYNC-1

        OUT     ($FE),A                   ; switch to mic on and red.
        LD      A,$0D                     ; prepare mic off - cyan
        LD      B,$37                     ; another short timed delay.

sa_sync_2:
        DJNZ    sa_sync_2                 ; self loop to SA-SYNC-2

        OUT     ($FE),A                   ; output mic off, cyan border.
        LD      BC,$3B0E                  ; B=$3B time(*), C=$0E, YELLOW, MIC OFF.

;

        EX      AF,AF'                    ; restore saved flag
                                          ; which is 1st byte to be saved.

        LD      L,A                       ; and transfer to L.
                                          ; the initial parity is A, $FF or $00.
        JP      sa_start                  ; JUMP forward to SA-START     ->
                                          ; the mid entry point of loop.

; -------------------------
; During the save loop a parity byte is maintained in H.
; the save loop begins by testing if reduced length is zero and if so
; the final parity byte is saved reducing count to $FFFF.

sa_loop:
        LD      A,D                       ; fetch high byte
        OR      E                         ; test against low byte.
        JR      Z,sa_parity               ; forward to SA-PARITY if zero.

        LD      L,(IX+$00)                ; load currently addressed byte to L.

sa_loop_p:
        LD      A,H                       ; fetch parity byte.
        XOR     L                         ; exclusive or with new byte.

; -> the mid entry point of loop.

sa_start:
        LD      H,A                       ; put parity byte in H.
        LD      A,$01                     ; prepare blue, mic=on.
        SCF                               ; set carry flag ready to rotate in.
        JP      sa_8_bits                 ; JUMP forward to SA-8-BITS            -8->

; ---

sa_parity:
        LD      L,H                       ; transfer the running parity byte to L and
        JR      sa_loop_p                 ; back to SA-LOOP-P
                                          ; to output that byte before quitting normally.

; ---

; entry point to save yellow part of bit.
; a bit consists of a period with mic on and blue border followed by
; a period of mic off with yellow border.
; Note. since the DJNZ instruction does not affect flags, the zero flag is used
; to indicate which of the two passes is in effect and the carry maintains the
; state of the bit to be saved.

sa_bit_2:
        LD      A,C                       ; fetch 'mic on and yellow' which is
                                          ; held permanently in C.
        BIT     7,B                       ; set the zero flag. B holds $3E.

; entry point to save 1 entire bit. For first bit B holds $3B(*).
; Carry is set if saved bit is 1. zero is reset NZ on entry.

sa_bit_1:
        DJNZ    sa_bit_1                  ; self loop for delay to SA-BIT-1

        JR      NC,sa_out                 ; forward to SA-OUT if bit is 0.

; but if bit is 1 then the mic state is held for longer.

        LD      B,$42                     ; set timed delay. (66 decimal)

sa_set:
        DJNZ    sa_set                    ; self loop to SA-SET
                                          ; (roughly an extra 66*13 clock cycles)

sa_out:
        OUT     ($FE),A                   ; blue and mic on OR  yellow and mic off.

        LD      B,$3E                     ; set up delay
        JR      NZ,sa_bit_2               ; back to SA-BIT-2 if zero reset NZ (first pass)

; proceed when the blue and yellow bands have been output.

        DEC     B                         ; change value $3E to $3D.
        XOR     A                         ; clear carry flag (ready to rotate in).
        INC     A                         ; reset zero flag ie. NZ.

; -8->

sa_8_bits:
        RL      L                         ; rotate left through carry
                                          ; C<76543210<C
        JP      NZ,sa_bit_1               ; JUMP back to SA-BIT-1
                                          ; until all 8 bits done.

; when the initial set carry is passed out again then a byte is complete.

        DEC     DE                        ; decrease length
        INC     IX                        ; increase byte pointer
        LD      B,$31                     ; set up timing.

        LD      A,$7F                     ; test the space key and
        IN      A,($FE)                   ; return to common exit (to restore border)
        RRA                               ; if a space is pressed
        RET     NC                        ; return to SA/LD-RET.   - - >

; now test if byte counter has reached $FFFF.

        LD      A,D                       ; fetch high byte
        INC     A                         ; increment.
        JP      NZ,sa_loop                ; JUMP to SA-LOOP if more bytes.

        LD      B,$3B                     ; a final delay.

sa_delay:
        DJNZ    sa_delay                  ; self loop to SA-DELAY

        RET                               ; return - - >

; --------------------------------------------------
; Reset border and check BREAK key for LOAD and SAVE
; --------------------------------------------------
; the address of this routine is pushed on the stack prior to any load/save
; operation and it handles normal completion with the restoration of the
; border and also abnormal termination when the break key, or to be more
; precise the space key is pressed during a tape operation.
; - - >

saslashld_ret:
        PUSH    AF                        ; preserve accumulator throughout.
        LD      A,(BORDCR)                ; fetch border colour from BORDCR.
        AND     $38                       ; mask off paper bits.
        RRCA                              ; rotate
        RRCA                              ; to the
        RRCA                              ; range 0-7.

        OUT     ($FE),A                   ; change the border colour.

        LD      A,$7F                     ; read from port address $7FFE the
        IN      A,($FE)                   ; row with the space key at outside.

        RRA                               ; test for space key pressed.
        EI                                ; enable interrupts
        JR      C,saslashld_end           ; forward to SA/LD-END if not


report_da:
        RST     08H                       ; ERROR-1
        DEFB    $0C                       ; Error Report: BREAK - CONT repeats

; ---

saslashld_end:
        POP     AF                        ; restore the accumulator.
        RET                               ; return.

; ------------------------------------
; Load header or block of information
; ------------------------------------
; This routine is used to load bytes and on entry A is set to $00 for a
; header or to $FF for data.  IX points to the start of receiving location
; and DE holds the length of bytes to be loaded. If, on entry the carry flag
; is set then data is loaded, if reset then it is verified.

ld_bytes:
        INC     D                         ; reset the zero flag without disturbing carry.
        EX      AF,AF'                    ; preserve entry flags.
        DEC     D                         ; restore high byte of length.

        DI                                ; disable interrupts

        LD      A,$0F                     ; make the border white and mic off.
        OUT     ($FE),A                   ; output to port.

        LD      HL,saslashld_ret          ; Address: SA/LD-RET
        PUSH    HL                        ; is saved on stack as terminating routine.

; the reading of the EAR bit (D6) will always be preceded by a test of the
; space key (D0), so store the initial post-test state.

        IN      A,($FE)                   ; read the ear state - bit 6.
        RRA                               ; rotate to bit 5.
        AND     $20                       ; isolate this bit.
        OR      $02                       ; combine with red border colour.
        LD      C,A                       ; and store initial state long-term in C.
        CP      A                         ; set the zero flag.

;

ld_break:
        RET     NZ                        ; return if at any time space is pressed.

ld_start:
        CALL    ld_edge_1                 ; routine LD-EDGE-1
        JR      NC,ld_break               ; back to LD-BREAK with time out and no
                                          ; edge present on tape.

; but continue when a transition is found on tape.

        LD      HL,$0415                  ; set up 16-bit outer loop counter for
                                          ; approx 1 second delay.

ld_wait:
        DJNZ    ld_wait                   ; self loop to LD-WAIT (for 256 times)

        DEC     HL                        ; decrease outer loop counter.
        LD      A,H                       ; test for
        OR      L                         ; zero.
        JR      NZ,ld_wait                ; back to LD-WAIT, if not zero, with zero in B.

; continue after delay with H holding zero and B also.
; sample 256 edges to check that we are in the middle of a lead-in section.

        CALL    ld_edge_2                 ; routine LD-EDGE-2
        JR      NC,ld_break               ; back to LD-BREAK
                                          ; if no edges at all.

ld_leader:
        LD      B,$9C                     ; set timing value.
        CALL    ld_edge_2                 ; routine LD-EDGE-2
        JR      NC,ld_break               ; back to LD-BREAK if time-out

        LD      A,$C6                     ; two edges must be spaced apart.
        CP      B                         ; compare
        JR      NC,ld_start               ; back to LD-START if too close together for a
                                          ; lead-in.

        INC     H                         ; proceed to test 256 edged sample.
        JR      NZ,ld_leader              ; back to LD-LEADER while more to do.

; sample indicates we are in the middle of a two or five second lead-in.
; Now test every edge looking for the terminal synch signal.

ld_sync:
        LD      B,$C9                     ; initial timing value in B.
        CALL    ld_edge_1                 ; routine LD-EDGE-1
        JR      NC,ld_break               ; back to LD-BREAK with time-out.

        LD      A,B                       ; fetch augmented timing value from B.
        CP      $D4                       ; compare
        JR      NC,ld_sync                ; back to LD-SYNC if gap too big, that is,
                                          ; a normal lead-in edge gap.

; but a short gap will be the synch pulse.
; in which case another edge should appear before B rises to $FF

        CALL    ld_edge_1                 ; routine LD-EDGE-1
        RET     NC                        ; return with time-out.

; proceed when the synch at the end of the lead-in is found.
; We are about to load data so change the border colours.

        LD      A,C                       ; fetch long-term mask from C
        XOR     $03                       ; and make blue/yellow.

        LD      C,A                       ; store the new long-term byte.

        LD      H,$00                     ; set up parity byte as zero.
        LD      B,$B0                     ; timing.
        JR      ld_marker                 ; forward to LD-MARKER
                                          ; the loop mid entry point with the alternate
                                          ; zero flag reset to indicate first byte
                                          ; is discarded.

; --------------
; the loading loop loads each byte and is entered at the mid point.

ld_loop:
        EX      AF,AF'                    ; restore entry flags and type in A.
        JR      NZ,ld_flag                ; forward to LD-FLAG if awaiting initial flag
                                          ; which is to be discarded.

        JR      NC,ld_verify              ; forward to LD-VERIFY if not to be loaded.

        LD      (IX+$00),L                ; place loaded byte at memory location.
        JR      ld_next                   ; forward to LD-NEXT

; ---

ld_flag:
        RL      C                         ; preserve carry (verify) flag in long-term
                                          ; state byte. Bit 7 can be lost.

        XOR     L                         ; compare type in A with first byte in L.
        RET     NZ                        ; return if no match e.g. CODE vs DATA.

; continue when data type matches.

        LD      A,C                       ; fetch byte with stored carry
        RRA                               ; rotate it to carry flag again
        LD      C,A                       ; restore long-term port state.

        INC     DE                        ; increment length ??
        JR      ld_dec                    ; forward to LD-DEC.
                                          ; but why not to location after ?

; ---
; for verification the byte read from tape is compared with that in memory.

ld_verify:
        LD      A,(IX+$00)                ; fetch byte from memory.
        XOR     L                         ; compare with that on tape
        RET     NZ                        ; return if not zero.

ld_next:
        INC     IX                        ; increment byte pointer.

ld_dec:
        DEC     DE                        ; decrement length.
        EX      AF,AF'                    ; store the flags.
        LD      B,$B2                     ; timing.

; when starting to read 8 bits the receiving byte is marked with bit at right.
; when this is rotated out again then 8 bits have been read.

ld_marker:
        LD      L,$01                     ; initialize as %00000001

ld_8_bits:
        CALL    ld_edge_2                 ; routine LD-EDGE-2 increments B relative to
                                          ; gap between 2 edges.
        RET     NC                        ; return with time-out.

        LD      A,$CB                     ; the comparison byte.
        CP      B                         ; compare to incremented value of B.
                                          ; if B is higher then bit on tape was set.
                                          ; if <= then bit on tape is reset.

        RL      L                         ; rotate the carry bit into L.

        LD      B,$B0                     ; reset the B timer byte.
        JP      NC,ld_8_bits              ; JUMP back to LD-8-BITS

; when carry set then marker bit has been passed out and byte is complete.

        LD      A,H                       ; fetch the running parity byte.
        XOR     L                         ; include the new byte.
        LD      H,A                       ; and store back in parity register.

        LD      A,D                       ; check length of
        OR      E                         ; expected bytes.
        JR      NZ,ld_loop                ; back to LD-LOOP
                                          ; while there are more.

; when all bytes loaded then parity byte should be zero.

        LD      A,H                       ; fetch parity byte.
        CP      $01                       ; set carry if zero.
        RET                               ; return
                                          ; in no carry then error as checksum disagrees.

; -------------------------
; Check signal being loaded
; -------------------------
; An edge is a transition from one mic state to another.
; More specifically a change in bit 6 of value input from port $FE.
; Graphically it is a change of border colour, say, blue to yellow.
; The first entry point looks for two adjacent edges. The second entry point
; is used to find a single edge.
; The B register holds a count, up to 256, within which the edge (or edges)
; must be found. The gap between two edges will be more for a '1' than a '0'
; so the value of B denotes the state of the bit (two edges) read from tape.

; ->

ld_edge_2:
        CALL    ld_edge_1                 ; call routine LD-EDGE-1 below.
        RET     NC                        ; return if space pressed or time-out.
                                          ; else continue and look for another adjacent
                                          ; edge which together represent a bit on the
                                          ; tape.

; ->
; this entry point is used to find a single edge from above but also
; when detecting a read-in signal on the tape.

ld_edge_1:
        LD      A,$16                     ; a delay value of twenty two.

ld_delay:
        DEC     A                         ; decrement counter
        JR      NZ,ld_delay               ; loop back to LD-DELAY 22 times.

        AND      A                        ; clear carry.

ld_sample:
        INC     B                         ; increment the time-out counter.
        RET     Z                         ; return with failure when $FF passed.

        LD      A,$7F                     ; prepare to read keyboard and EAR port
        IN      A,($FE)                   ; row $7FFE. bit 6 is EAR, bit 0 is SPACE key.
        RRA                               ; test outer key the space. (bit 6 moves to 5)
        RET     NC                        ; return if space pressed.  >>>

        XOR     C                         ; compare with initial long-term state.
        AND     $20                       ; isolate bit 5
        JR      Z,ld_sample               ; back to LD-SAMPLE if no edge.

; but an edge, a transition of the EAR bit, has been found so switch the
; long-term comparison byte containing both border colour and EAR bit.

        LD      A,C                       ; fetch comparison value.
        CPL                               ; switch the bits
        LD      C,A                       ; and put back in C for long-term.

        AND     $07                       ; isolate new colour bits.
        OR      $08                       ; set bit 3 - MIC off.
        OUT     ($FE),A                   ; send to port to effect change of colour.

        SCF                               ; set carry flag signaling edge found within
                                          ; time allowed.
        RET                               ; return.

; ---------------------------------
; Entry point for all tape commands
; ---------------------------------
; This is the single entry point for the four tape commands.
; The routine first determines in what context it has been called by examining
; the low byte of the Syntax table entry which was stored in T_ADDR.
; Subtracting $EO (the present arrangement) gives a value of
; $00 - SAVE
; $01 - LOAD
; $02 - VERIFY
; $03 - MERGE
; As with all commands the address STMT-RET is on the stack.

save_etc:
        POP     AF                        ; discard address STMT-RET.
        LD      A,(T_ADDR)                ; fetch T_ADDR

; Now reduce the low byte of the Syntax table entry to give command.

        SUB     (p_save+1)&$FF            ; subtract the known offset.
                                          ; ( is SUB $E0 in standard ROM )

        LD      (T_ADDR),A                ; and put back in T_ADDR as 0,1,2, or 3
                                          ; for future reference.

        CALL    expt_exp                  ; routine EXPT-EXP checks that a string
                                          ; expression follows and stacks the
                                          ; parameters in run-time.

        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,sa_data                 ; forward to SA-DATA if checking syntax.

        LD      BC,$0011                  ; presume seventeen bytes for a header.
        LD      A,(T_ADDR)                ; fetch command from T_ADDR.
        AND     A                         ; test for zero - SAVE.
        JR      Z,sa_space                ; forward to SA-SPACE if so.

        LD      C,$22                     ; else double length to thirty four.

sa_space:
        RST     30H                       ; BC-SPACES creates 17/34 bytes in workspace.

        PUSH    DE                        ; transfer the start of new space to
        POP     IX                        ; the available index register.

; ten spaces are required for the default filename but it is simpler to
; overwrite the first file-type indicator byte as well.

        LD      B,$0B                     ; set counter to eleven.
        LD      A,$20                     ; prepare a space.

sa_blank:
        LD      (DE),A                    ; set workspace location to space.
        INC     DE                        ; next location.
        DJNZ    sa_blank                  ; loop back to SA-BLANK till all eleven done.

        LD      (IX+$01),$FF              ; set first byte of ten character filename
                                          ; to $FF as a default to signal null string.

        CALL    stk_fetch                 ; routine STK-FETCH fetches the filename
                                          ; parameters from the calculator stack.
                                          ; length of string in BC.
                                          ; start of string in DE.

        LD      HL,-10                    ; prepare the value minus ten.
        DEC     BC                        ; decrement length.
                                          ; ten becomes nine, zero becomes $FFFF.
        ADD     HL,BC                     ; trial addition.
        INC     BC                        ; restore true length.
        JR      NC,sa_name                ; forward to SA-NAME if length is one to ten.

; the filename is more than ten characters in length or the null string.

        LD      A,(T_ADDR)                ; fetch command from T_ADDR.
        AND     A                         ; test for zero - SAVE.
        JR      NZ,sa_null                ; forward to SA-NULL if not the SAVE command.

; but no more than ten characters are allowed for SAVE.
; The first ten characters of any other command parameter are acceptable.
; Weird, but necessary, if saving to sectors.
; Note. the golden rule that there are no restriction on anything is broken.

report_fa:
        RST     08H                       ; ERROR-1
        DEFB    $0E                       ; Error Report: Invalid file name

; continue with LOAD, MERGE, VERIFY and also SAVE within ten character limit.

sa_null:
        LD      A,B                       ; test length of filename
        OR      C                         ; for zero.
        JR      Z,sa_data                 ; forward to SA-DATA if so using the 255
                                          ; indicator followed by spaces.

        LD      BC,$000A                  ; else trim length to ten.

; other paths rejoin here with BC holding length in range 1 - 10.

sa_name:
        PUSH    IX                        ; push start of file descriptor.
        POP     HL                        ; and pop into HL.

        INC     HL                        ; HL now addresses first byte of filename.
        EX      DE,HL                     ; transfer destination address to DE, start
                                          ; of string in command to HL.
        LDIR                              ; copy up to ten bytes
                                          ; if less than ten then trailing spaces follow.

; the case for the null string rejoins here.

sa_data:
        RST     18H                       ; GET-CHAR
        CP      $E4                       ; is character after filename the token 'DATA' ?
        JR      NZ,sa_scrstring           ; forward to SA-SCR$ to consider SCREEN$ if
                                          ; not.

; continue to consider DATA.

        LD      A,(T_ADDR)                ; fetch command from T_ADDR
        CP      $03                       ; is it 'VERIFY' ?
        JP      Z,report_c                ; jump forward to REPORT-C if so.
                                          ; 'Nonsense in BASIC'
                                          ; VERIFY "d" DATA is not allowed.

; continue with SAVE, LOAD, MERGE of DATA.

        RST     20H                       ; NEXT-CHAR
        CALL    look_vars                 ; routine LOOK-VARS searches variables area
                                          ; returning with carry reset if found or
                                          ; checking syntax.
        SET     7,C                       ; this converts a simple string to a
                                          ; string array. The test for an array or string
                                          ; comes later.
        JR      NC,sa_v_old               ; forward to SA-V-OLD if variable found.

        LD      HL,$0000                  ; set destination to zero as not fixed.
        LD      A,(T_ADDR)                ; fetch command from T_ADDR
        DEC     A                         ; test for 1 - LOAD
        JR      Z,sa_v_new                ; forward to SA-V-NEW with LOAD DATA.
                                          ; to load a new array.

; otherwise the variable was not found in run-time with SAVE/MERGE.

report_2a:
        RST     08H                       ; ERROR-1
        DEFB    $01                       ; Error Report: Variable not found

; continue with SAVE/LOAD  DATA

sa_v_old:
        JP      NZ,report_c               ; to REPORT-C if not an array variable.
                                          ; or erroneously a simple string.
                                          ; 'Nonsense in BASIC'


        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,sa_data_1               ; forward to SA-DATA-1 if checking syntax.

        INC     HL                        ; step past single character variable name.
        LD      A,(HL)                    ; fetch low byte of length.
        LD      (IX+$0B),A                ; place in descriptor.
        INC     HL                        ; point to high byte.
        LD      A,(HL)                    ; and transfer that
        LD      (IX+$0C),A                ; to descriptor.
        INC     HL                        ; increase pointer within variable.

sa_v_new:
        LD      (IX+$0E),C                ; place character array name in  header.
        LD      A,$01                     ; default to type numeric.
        BIT     6,C                       ; test result from look-vars.
        JR      Z,sa_v_type               ; forward to SA-V-TYPE if numeric.

        INC     A                         ; set type to 2 - string array.

sa_v_type:
        LD      (IX+$00),A                ; place type 0, 1 or 2 in descriptor.

sa_data_1:
        EX      DE,HL                     ; save var pointer in DE

        RST     20H                       ; NEXT-CHAR
        CP      $29                       ; is character ')' ?
        JR      NZ,sa_v_old               ; back if not to SA-V-OLD to report
                                          ; 'Nonsense in BASIC'

        RST     20H                       ; NEXT-CHAR advances character address.
        CALL    check_end                 ; routine CHECK-END errors if not end of
                                          ; the statement.

        EX      DE,HL                     ; bring back variables data pointer.
        JP      sa_all                    ; jump forward to SA-ALL

; ---
; the branch was here to consider a 'SCREEN$', the display file.

sa_scrstring:
        CP      $AA                       ; is character the token 'SCREEN$' ?
        JR      NZ,sa_code                ; forward to SA-CODE if not.

        LD      A,(T_ADDR)                ; fetch command from T_ADDR
        CP      $03                       ; is it MERGE ?
        JP       Z,report_c               ; jump to REPORT-C if so.
                                          ; 'Nonsense in BASIC'

; continue with SAVE/LOAD/VERIFY SCREEN$.

        RST     20H                       ; NEXT-CHAR
        CALL    check_end                 ; routine CHECK-END errors if not at end of
                                          ; statement.

; continue in runtime.

        LD      (IX+$0B),$00              ; set descriptor length
        LD      (IX+$0C),$1B              ; to $1b00 to include bitmaps and attributes.

        LD      HL,display_file           ; set start to display file start.
        LD      (IX+$0D),L                ; place start in
        LD      (IX+$0E),H                ; the descriptor.
        JR      sa_type_3                 ; forward to SA-TYPE-3

; ---
; the branch was here to consider CODE.

sa_code:
        CP      $AF                       ; is character the token 'CODE' ?
        JR      NZ,sa_line                ; forward if not to SA-LINE to consider an
                                          ; auto-started BASIC program.

        LD      A,(T_ADDR)                ; fetch command from T_ADDR
        CP      $03                       ; is it MERGE ?
        JP      Z,report_c                ; jump forward to REPORT-C if so.
                                          ; 'Nonsense in BASIC'


        RST     20H                       ; NEXT-CHAR advances character address.
        CALL    pr_st_end                 ; routine PR-ST-END checks if a carriage
                                          ; return or ':' follows.
        JR      NZ,sa_code_1              ; forward to SA-CODE-1 if there are parameters.

        LD      A,(T_ADDR)                ; else fetch the command from T_ADDR.
        AND     A                         ; test for zero - SAVE without a specification.
        JP      Z,report_c                ; jump to REPORT-C if so.
                                          ; 'Nonsense in BASIC'

; for LOAD/VERIFY put zero on stack to signify handle at location saved from.

        CALL    use_zero                  ; routine USE-ZERO
        JR      sa_code_2                 ; forward to SA-CODE-2

; ---
; if there are more characters after CODE expect start and possibly length.

sa_code_1:
        CALL    expt_1num                 ; routine EXPT-1NUM checks for numeric
                                          ; expression and stacks it in run-time.

        RST     18H                       ; GET-CHAR
        CP      $2C                       ; does a comma follow ?
        JR      Z,sa_code_3               ; forward if so to SA-CODE-3

; else allow saved code to be loaded to a specified address.

        LD      A,(T_ADDR)                ; fetch command from T_ADDR.
        AND     A                         ; is the command SAVE which requires length ?
        JP      Z,report_c                ; jump to REPORT-C if so.
                                          ; 'Nonsense in BASIC'

; the command LOAD code may rejoin here with zero stacked as start.

sa_code_2:
        CALL    use_zero                  ; routine USE-ZERO stacks zero for length.
        JR      sa_code_4                 ; forward to SA-CODE-4

; ---
; the branch was here with SAVE CODE start,

sa_code_3:
        RST     20H                       ; NEXT-CHAR advances character address.
        CALL    expt_1num                 ; routine EXPT-1NUM checks for expression
                                          ; and stacks in run-time.

; paths converge here and nothing must follow.

sa_code_4:
        CALL    check_end                 ; routine CHECK-END errors with extraneous
                                          ; characters and quits if checking syntax.

; in run-time there are two 16-bit parameters on the calculator stack.

        CALL    find_int2                 ; routine FIND-INT2 gets length.
        LD      (IX+$0B),C                ; place length
        LD      (IX+$0C),B                ; in descriptor.
        CALL    find_int2                 ; routine FIND-INT2 gets start.
        LD      (IX+$0D),C                ; place start
        LD      (IX+$0E),B                ; in descriptor.
        LD      H,B                       ; transfer the
        LD      L,C                       ; start to HL also.

sa_type_3:
        LD      (IX+$00),$03              ; place type 3 - code in descriptor.
        JR      sa_all                    ; forward to SA-ALL.

; ---
; the branch was here with BASIC to consider an optional auto-start line
; number.

sa_line:
        CP      $CA                       ; is character the token 'LINE' ?
        JR      Z,sa_line_1               ; forward to SA-LINE-1 if so.

; else all possibilities have been considered and nothing must follow.

        CALL    check_end                 ; routine CHECK-END

; continue in run-time to save BASIC without auto-start.

        LD      (IX+$0E),$80              ; place high line number in descriptor to
                                          ; disable auto-start.
        JR      sa_type_0                 ; forward to SA-TYPE-0 to save program.

; ---
; the branch was here to consider auto-start.

sa_line_1:
        LD      A,(T_ADDR)                ; fetch command from T_ADDR
        AND     A                         ; test for SAVE.
        JP      NZ,report_c               ; jump forward to REPORT-C with anything else.
                                          ; 'Nonsense in BASIC'

;

        RST     20H                       ; NEXT-CHAR
        CALL    expt_1num                 ; routine EXPT-1NUM checks for numeric
                                          ; expression and stacks in run-time.
        CALL    check_end                 ; routine CHECK-END quits if syntax path.
        CALL    find_int2                 ; routine FIND-INT2 fetches the numeric
                                          ; expression.
        LD      (IX+$0D),C                ; place the auto-start
        LD      (IX+$0E),B                ; line number in the descriptor.

; Note. this isn't checked, but is subsequently handled by the system.
; If the user typed 40000 instead of 4000 then it won't auto-start
; at line 4000, or indeed, at all.

; continue to save program and any variables.

sa_type_0:
        LD      (IX+$00),$00              ; place type zero - program in descriptor.
        LD      HL,(E_LINE)               ; fetch E_LINE to HL.
        LD      DE,(PROG)                 ; fetch PROG to DE.
        SCF                               ; set carry flag to calculate from end of
                                          ; variables E_LINE -1.
        SBC     HL,DE                     ; subtract to give total length.

        LD      (IX+$0B),L                ; place total length
        LD      (IX+$0C),H                ; in descriptor.
        LD      HL,(VARS)                 ; load HL from system variable VARS
        SBC     HL,DE                     ; subtract to give program length.
        LD      (IX+$0F),L                ; place length of program
        LD      (IX+$10),H                ; in the descriptor.
        EX      DE,HL                     ; start to HL, length to DE.

sa_all:
        LD      A,(T_ADDR)                ; fetch command from T_ADDR
        AND     A                         ; test for zero - SAVE.
        JP      Z,sa_contrl               ; jump forward to SA-CONTRL with SAVE  ->

; ---
; continue with LOAD, MERGE and VERIFY.

        PUSH    HL                        ; save start.
        LD      BC,$0011                  ; prepare to add seventeen
        ADD     IX,BC                     ; to point IX at second descriptor.

ld_look_h:
        PUSH    IX                        ; save IX
        LD      DE,$0011                  ; seventeen bytes
        XOR     A                         ; reset zero flag
        SCF                               ; set carry flag
        CALL    ld_bytes                  ; routine LD-BYTES loads a header from tape
                                          ; to second descriptor.
        POP     IX                        ; restore IX.
        JR      NC,ld_look_h              ; loop back to LD-LOOK-H until header found.

        LD      A,$FE                     ; select system channel 'S'
        CALL    chan_open                 ; routine CHAN-OPEN opens it.

        LD      (IY+(SCR_CT-C_IY)),$03    ; set SCR_CT to 3 lines.

        LD      C,$80                     ; C has bit 7 set to indicate type mismatch as
                                          ; a default startpoint.

        LD      A,(IX+$00)                ; fetch loaded header type to A
        CP      (IX-$11)                  ; compare with expected type.
        JR      NZ,ld_type                ; forward to LD-TYPE with mis-match.

        LD      C,$F6                     ; set C to minus ten - will count characters
                                          ; up to zero.

ld_type:
        CP      $04                       ; check if type in acceptable range 0 - 3.
        JR      NC,ld_look_h              ; back to LD-LOOK-H with 4 and over.

; else A indicates type 0-3.

        LD      DE,tape_last4             ; address base of last 4 tape messages
        PUSH    BC                        ; save BC
        CALL    po_msg                    ; routine PO-MSG outputs relevant message.
                                          ; Note. all messages have a leading newline.
        POP     BC                        ; restore BC

        PUSH    IX                        ; transfer IX,
        POP     DE                        ; the 2nd descriptor, to DE.
        LD      HL,-16                    ; prepare minus sixteen.
        ADD     HL,DE                     ; add to point HL to 1st descriptor.
        LD      B,$0A                     ; the count will be ten characters for the
                                          ; filename.

        LD      A,(HL)                    ; fetch first character and test for
        INC     A                         ; value 255.
        JR      NZ,ld_name                ; forward to LD-NAME if not the wildcard.

; but if it is the wildcard, then add ten to C which is minus ten for a type
; match or -128 for a type mismatch. Although characters have to be counted
; bit 7 of C will not alter from state set here.

        LD      A,C                       ; transfer $F6 or $80 to A
        ADD     A,B                       ; add $0A
        LD      C,A                       ; place result, zero or -118, in C.

; At this point we have either a type mismatch, a wildcard match or ten
; characters to be counted. The characters must be shown on the screen.

ld_name:
        INC     DE                        ; address next input character
        LD      A,(DE)                    ; fetch character
        CP      (HL)                      ; compare to expected
        INC     HL                        ; address next expected character
        JR      NZ,ld_ch_pr               ; forward to LD-CH-PR with mismatch

        INC     C                         ; increment matched character count

ld_ch_pr:
        RST     10H                       ; PRINT-A prints character
        DJNZ    ld_name                   ; loop back to LD-NAME for ten characters.

; if ten characters matched and the types previously matched then C will
; now hold zero.

        BIT     7,C                       ; test if all matched
        JR      NZ,ld_look_h              ; back to LD-LOOK-H if not

; else print a terminal carriage return.

        LD      A,$0D                     ; prepare carriage return.
        RST     10H                       ; PRINT-A outputs it.

; The various control routines for LOAD, VERIFY and MERGE are executed
; during the one-second gap following the header on tape.

        POP     HL                        ; restore xx
        LD      A,(IX+$00)                ; fetch incoming type
        CP      $03                       ; compare with CODE
        JR      Z,vr_control              ; forward to VR-CONTROL if it is CODE.

;  type is a program or an array.

        LD      A,(T_ADDR)                ; fetch command from T_ADDR
        DEC     A                         ; was it LOAD ?
        JP      Z,ld_contrl               ; JUMP forward to LD-CONTRL if so to
                                          ; load BASIC or variables.

        CP      $02                       ; was command MERGE ?
        JP      Z,me_contrl               ; jump forward to ME-CONTRL if so.

; else continue into VERIFY control routine to verify.

; ---------------------
; Handle VERIFY control
; ---------------------
; There are two branches to this routine.
; 1) From above to verify a program or array
; 2) from earlier with no carry to load or verify code.

vr_control:
        PUSH    HL                        ; save pointer to data.
        LD      L,(IX-$06)                ; fetch length of old data
        LD      H,(IX-$05)                ; to HL.
        LD      E,(IX+$0B)                ; fetch length of new data
        LD      D,(IX+$0C)                ; to DE.
        LD      A,H                       ; check length of old
        OR      L                         ; for zero.
        JR      Z,vr_cont_1               ; forward to VR-CONT-1 if length unspecified
                                          ; e.g LOAD "x" CODE

; as opposed to, say, LOAD 'x' CODE 32768,300.

        SBC     HL,DE                     ; subtract the two lengths.
        JR      C,report_r                ; forward to REPORT-R if the length on tape is
                                          ; larger than that specified in command.
                                          ; 'Tape loading error'

        JR      Z,vr_cont_1               ; forward to VR-CONT-1 if lengths match.

; a length on tape shorter than expected is not allowed for CODE

        LD      A,(IX+$00)                ; else fetch type from tape.
        CP      $03                       ; is it CODE ?
        JR      NZ,report_r               ; forward to REPORT-R if so
                                          ; 'Tape loading error'

vr_cont_1:
        POP     HL                        ; pop pointer to data
        LD      A,H                       ; test for zero
        OR      L                         ; e.g. LOAD 'x' CODE
        JR      NZ,vr_cont_2              ; forward to VR-CONT-2 if destination specified.

        LD      L,(IX+$0D)                ; else use the destination in the header
        LD      H,(IX+$0E)                ; and load code at address saved from.

vr_cont_2:
        PUSH    HL                        ; push pointer to start of data block.
        POP     IX                        ; transfer to IX.
        LD      A,(T_ADDR)                ; fetch reduced command from T_ADDR
        CP      $02                       ; is it VERIFY ?
        SCF                               ; prepare a set carry flag
        JR      NZ,vr_cont_3              ; skip to VR-CONT-3 if not

        AND     A                         ; clear carry flag for VERIFY so that
                                          ; data is not loaded.

vr_cont_3:
        LD      A,$FF                     ; signal data block to be loaded

; -----------------
; Load a data block
; -----------------
; This routine is called from 3 places other than above to load a data block.
; In all cases the accumulator is first set to $FF so the routine could be
; called at the previous instruction.

ld_block:
        CALL    ld_bytes                  ; routine LD-BYTES
        RET     C                         ; return if successful.


report_r:
        RST     08H                       ; ERROR-1
        DEFB    $1A                       ; Error Report: Tape loading error

; -------------------
; Handle LOAD control
; -------------------
; This branch is taken when the command is LOAD with type 0, 1 or 2.

ld_contrl:
        LD      E,(IX+$0B)                ; fetch length of found data block
        LD      D,(IX+$0C)                ; from 2nd descriptor.
        PUSH    HL                        ; save destination
        LD      A,H                       ; test for zero
        OR      L                         ;
        JR      NZ,ld_cont_1              ; forward if not to LD-CONT-1

        INC     DE                        ; increase length
        INC     DE                        ; for letter name
        INC     DE                        ; and 16-bit length
        EX      DE,HL                     ; length to HL,
        JR      ld_cont_2                 ; forward to LD-CONT-2

; ---

ld_cont_1:
        LD      L,(IX-$06)                ; fetch length from
        LD      H,(IX-$05)                ; the first header.
        EX      DE,HL                     ;
        SCF                               ; set carry flag
        SBC     HL,DE                     ;
        JR      C,ld_data                 ; to LD-DATA

ld_cont_2:
        LD      DE,$0005                  ; allow overhead of five bytes.
        ADD     HL,DE                     ; add in the difference in data lengths.
        LD      B,H                       ; transfer to
        LD      C,L                       ; the BC register pair
        CALL    test_room                 ; routine TEST-ROOM fails if not enough room.

ld_data:
        POP     HL                        ; pop destination
        LD      A,(IX+$00)                ; fetch type 0, 1 or 2.
        AND     A                         ; test for program and variables.
        JR      Z,ld_prog                 ; forward if so to LD-PROG

; the type is a numeric or string array.

        LD      A,H                       ; test the destination for zero
        OR      L                         ; indicating variable does not already exist.
        JR      Z,ld_data_1               ; forward if so to LD-DATA-1

; else the destination is the first dimension within the array structure

        DEC     HL                        ; address high byte of total length
        LD      B,(HL)                    ; transfer to B.
        DEC     HL                        ; address low byte of total length.
        LD      C,(HL)                    ; transfer to C.
        DEC     HL                        ; point to letter of variable.
        INC     BC                        ; adjust length to
        INC     BC                        ; include these
        INC     BC                        ; three bytes also.
        LD      (X_PTR),IX                ; save header pointer in X_PTR.
        CALL    reclaim_2                 ; routine RECLAIM-2 reclaims the old variable
                                          ; sliding workspace including the two headers
                                          ; downwards.
        LD      IX,(X_PTR)                ; reload IX from X_PTR which will have been
                                          ; adjusted down by POINTERS routine.

ld_data_1:
        LD      HL,(E_LINE)               ; address E_LINE
        DEC     HL                        ; now point to the $80 variables end-marker.
        LD      C,(IX+$0B)                ; fetch new data length
        LD      B,(IX+$0C)                ; from 2nd header.
        PUSH    BC                        ; * save it.
        INC     BC                        ; adjust the
        INC     BC                        ; length to include
        INC     BC                        ; letter name and total length.
        LD      A,(IX-$03)                ; fetch letter name from old header.
        PUSH    AF                        ; preserve accumulator though not corrupted.

        CALL    make_room                 ; routine MAKE-ROOM creates space for variable
                                          ; sliding workspace up. IX no longer addresses
                                          ; anywhere meaningful.
        INC     HL                        ; point to first new location.

        POP     AF                        ; fetch back the letter name.
        LD      (HL),A                    ; place in first new location.
        POP     DE                        ; * pop the data length.
        INC     HL                        ; address 2nd location
        LD      (HL),E                    ; store low byte of length.
        INC     HL                        ; address next.
        LD      (HL),D                    ; store high byte.
        INC     HL                        ; address start of data.
        PUSH    HL                        ; transfer address
        POP     IX                        ; to IX register pair.
        SCF                               ; set carry flag indicating load not verify.
        LD      A,$FF                     ; signal data not header.
        JP      ld_block                  ; JUMP back to LD-BLOCK

; -----------------
; the branch is here when a program as opposed to an array is to be loaded.

ld_prog:
        EX      DE,HL                     ; transfer dest to DE.
        LD      HL,(E_LINE)               ; address E_LINE
        DEC     HL                        ; now variables end-marker.
        LD      (X_PTR),IX                ; place the IX header pointer in X_PTR
        LD      C,(IX+$0B)                ; get new length
        LD      B,(IX+$0C)                ; from 2nd header
        PUSH    BC                        ; and save it.

        CALL    reclaim_1                 ; routine RECLAIM-1 reclaims program and vars.
                                          ; adjusting X-PTR.

        POP     BC                        ; restore new length.
        PUSH    HL                        ; * save start
        PUSH    BC                        ; ** and length.

        CALL    make_room                 ; routine MAKE-ROOM creates the space.

        LD      IX,(X_PTR)                ; reload IX from adjusted X_PTR
        INC     HL                        ; point to start of new area.
        LD      C,(IX+$0F)                ; fetch length of BASIC on tape
        LD      B,(IX+$10)                ; from 2nd descriptor
        ADD     HL,BC                     ; add to address the start of variables.
        LD      (VARS),HL                 ; set system variable VARS

        LD      H,(IX+$0E)                ; fetch high byte of autostart line number.
        LD      A,H                       ; transfer to A
        AND     $C0                       ; test if greater than $3F.
        JR      NZ,ld_prog_1              ; forward to LD-PROG-1 if so with no autostart.

        LD      L,(IX+$0D)                ; else fetch the low byte.
        LD      (NEWPPC),HL               ; set sytem variable to line number NEWPPC
        LD      (IY+(NSPPC-C_IY)),$00     ; set statement NSPPC to zero.

ld_prog_1:
        POP     DE                        ; ** pop the length
        POP     IX                        ; * and start.
        SCF                               ; set carry flag
        LD      A,$FF                     ; signal data as opposed to a header.
        JP      ld_block                  ; jump back to LD-BLOCK

; --------------------
; Handle MERGE control
; --------------------
; the branch was here to merge a program and its variables or an array.
;

me_contrl:
        LD      C,(IX+$0B)                ; fetch length
        LD      B,(IX+$0C)                ; of data block on tape.
        PUSH    BC                        ; save it.
        INC     BC                        ; one for the pot.

        RST     30H                       ; BC-SPACES creates room in workspace.
                                          ; HL addresses last new location.
        LD      (HL),$80                  ; place end-marker at end.
        EX      DE,HL                     ; transfer first location to HL.
        POP     DE                        ; restore length to DE.
        PUSH    HL                        ; save start.

        PUSH    HL                        ; and transfer it
        POP     IX                        ; to IX register.
        SCF                               ; set carry flag to load data on tape.
        LD      A,$FF                     ; signal data not a header.
        CALL    ld_block                  ; routine LD-BLOCK loads to workspace.
        POP     HL                        ; restore first location in workspace to HL.
        LD      DE,(PROG)                 ; set DE from system variable PROG.

; now enter a loop to merge the data block in workspace with the program and
; variables.

me_new_lp:
        LD      A,(HL)                    ; fetch next byte from workspace.
        AND     $C0                       ; compare with $3F.
        JR      NZ,me_var_lp              ; forward to ME-VAR-LP if a variable or
                                          ; end-marker.

; continue when HL addresses a BASIC line number.

me_old_lp:
        LD      A,(DE)                    ; fetch high byte from program area.
        INC     DE                        ; bump prog address.
        CP      (HL)                      ; compare with that in workspace.
        INC     HL                        ; bump workspace address.
        JR      NZ,me_old_l1              ; forward to ME-OLD-L1 if high bytes don't match

        LD      A,(DE)                    ; fetch the low byte of program line number.
        CP      (HL)                      ; compare with that in workspace.

me_old_l1:
        DEC     DE                        ; point to start of
        DEC     HL                        ; respective lines again.
        JR      NC,me_new_l2              ; forward to ME-NEW-L2 if line number in
                                          ; workspace is less than or equal to current
                                          ; program line as has to be added to program.

        PUSH    HL                        ; else save workspace pointer.
        EX      DE,HL                     ; transfer prog pointer to HL
        CALL    next_one                  ; routine NEXT-ONE finds next line in DE.
        POP     HL                        ; restore workspace pointer
        JR      me_old_lp                 ; back to ME-OLD-LP until destination position
                                          ; in program area found.

; ---
; the branch was here with an insertion or replacement point.

me_new_l2:
        CALL    me_enter                  ; routine ME-ENTER enters the line
        JR      me_new_lp                 ; loop back to ME-NEW-LP.

; ---
; the branch was here when the location in workspace held a variable.

me_var_lp:
        LD      A,(HL)                    ; fetch first byte of workspace variable.
        LD      C,A                       ; copy to C also.
        CP      $80                       ; is it the end-marker ?
        RET     Z                         ; return if so as complete.  >>>>>

        PUSH    HL                        ; save workspace area pointer.
        LD      HL,(VARS)                 ; load HL with VARS - start of variables area.

me_old_vp:
        LD      A,(HL)                    ; fetch first byte.
        CP      $80                       ; is it the end-marker ?
        JR      Z,me_var_l2               ; forward if so to ME-VAR-L2 to add
                                          ; variable at end of variables area.

        CP      C                         ; compare with variable in workspace area.
        JR      Z,me_old_v2               ; forward to ME-OLD-V2 if a match to replace.

; else entire variables area has to be searched.

me_old_v1:
        PUSH    BC                        ; save character in C.
        CALL    next_one                  ; routine NEXT-ONE gets following variable
                                          ; address in DE.
        POP     BC                        ; restore character in C
        EX      DE,HL                     ; transfer next address to HL.
        JR      me_old_vp                 ; loop back to ME-OLD-VP

; ---
; the branch was here when first characters of name matched.

me_old_v2:
        AND     $E0                       ; keep bits 11100000
        CP      $A0                       ; compare   10100000 - a long-named variable.

        JR      NZ,me_var_l1              ; forward to ME-VAR-L1 if just one-character.

; but long-named variables have to be matched character by character.

        POP     DE                        ; fetch workspace 1st character pointer
        PUSH    DE                        ; and save it on the stack again.
        PUSH    HL                        ; save variables area pointer on stack.

me_old_v3:
        INC     HL                        ; address next character in vars area.
        INC     DE                        ; address next character in workspace area.
        LD      A,(DE)                    ; fetch workspace character.
        CP      (HL)                      ; compare to variables character.
        JR      NZ,me_old_v4              ; forward to ME-OLD-V4 with a mismatch.

        RLA                               ; test if the terminal inverted character.
        JR      NC,me_old_v3              ; loop back to ME-OLD-V3 if more to test.

; otherwise the long name matches in its entirety.

        POP     HL                        ; restore pointer to first character of variable
        JR      me_var_l1                 ; forward to ME-VAR-L1

; ---
; the branch is here when two characters don't match

me_old_v4:
        POP     HL                        ; restore the prog/vars pointer.
        JR      me_old_v1                 ; back to ME-OLD-V1 to resume search.

; ---
; branch here when variable is to replace an existing one

me_var_l1:
        LD      A,$FF                     ; indicate a replacement.

; this entry point is when A holds $80 indicating a new variable.

me_var_l2:
        POP     DE                        ; pop workspace pointer.
        EX      DE,HL                     ; now make HL workspace pointer, DE vars pointer
        INC     A                         ; zero flag set if replacement.
        SCF                               ; set carry flag indicating a variable not a
                                          ; program line.
        CALL    me_enter                  ; routine ME-ENTER copies variable in.
        JR      me_var_lp                 ; loop back to ME-VAR-LP

; ------------------------
; Merge a Line or Variable
; ------------------------
; A BASIC line or variable is inserted at the current point. If the line numbers
; or variable names match (zero flag set) then a replacement takes place.

me_enter:
        JR      NZ,me_ent_1               ; forward to ME-ENT-1 for insertion only.

; but the program line or variable matches so old one is reclaimed.

        EX      AF,AF'                    ; save flag??
        LD      (X_PTR),HL                ; preserve workspace pointer in dynamic X_PTR
        EX      DE,HL                     ; transfer program dest pointer to HL.
        CALL    next_one                  ; routine NEXT-ONE finds following location
                                          ; in program or variables area.
        CALL    reclaim_2                 ; routine RECLAIM-2 reclaims the space between.
        EX      DE,HL                     ; transfer program dest pointer back to DE.
        LD      HL,(X_PTR)                ; fetch adjusted workspace pointer from X_PTR
        EX      AF,AF'                    ; restore flags.

; now the new line or variable is entered.

me_ent_1:
        EX      AF,AF'                    ; save or re-save flags.
        PUSH    DE                        ; save dest pointer in prog/vars area.
        CALL    next_one                  ; routine NEXT-ONE finds next in workspace.
                                          ; gets next in DE, difference in BC.
                                          ; prev addr in HL
        LD      (X_PTR),HL                ; store pointer in X_PTR
        LD      HL,(PROG)                 ; load HL from system variable PROG
        EX      (SP),HL                   ; swap with prog/vars pointer on stack.
        PUSH    BC                        ; ** save length of new program line/variable.
        EX      AF,AF'                    ; fetch flags back.
        JR      C,me_ent_2                ; skip to ME-ENT-2 if variable

        DEC     HL                        ; address location before pointer
        CALL    make_room                 ; routine MAKE-ROOM creates room for BASIC line
        INC     HL                        ; address next.
        JR      me_ent_3                  ; forward to ME-ENT-3

; ---

me_ent_2:
        CALL    make_room                 ; routine MAKE-ROOM creates room for variable.

me_ent_3:
        INC     HL                        ; address next?

        POP     BC                        ; ** pop length
        POP     DE                        ; * pop value for PROG which may have been
                                          ; altered by POINTERS if first line.
        LD      (PROG),DE                 ; set PROG to original value.
        LD      DE,(X_PTR)                ; fetch adjusted workspace pointer from X_PTR
        PUSH    BC                        ; save length
        PUSH    DE                        ; and workspace pointer
        EX      DE,HL                     ; make workspace pointer source, prog/vars
                                          ; pointer the destination
        LDIR                              ; copy bytes of line or variable into new area.
        POP     HL                        ; restore workspace pointer.
        POP     BC                        ; restore length.
        PUSH    DE                        ; save new prog/vars pointer.
        CALL    reclaim_2                 ; routine RECLAIM-2 reclaims the space used
                                          ; by the line or variable in workspace block
                                          ; as no longer required and space could be
                                          ; useful for adding more lines.
        POP     DE                        ; restore the prog/vars pointer
        RET                               ; return.

; -------------------
; Handle SAVE control
; -------------------
; A branch from the main SAVE-ETC routine at SAVE-ALL.
; First the header data is saved. Then after a wait of 1 second
; the data itself is saved.
; HL points to start of data.
; IX points to start of descriptor.

sa_contrl:
        PUSH    HL                        ; save start of data

        LD      A,$FD                     ; select system channel 'S'
        CALL    chan_open                 ; routine CHAN-OPEN

        XOR     A                         ; clear to address table directly
        LD      DE,tape_msgs              ; address: tape-msgs
        CALL    po_msg                    ; routine PO-MSG -
                                          ; 'Start tape then press any key.'

        SET     5,(IY+(TV_FLAG-C_IY))     ; TV_FLAG  - Signal lower screen requires
                                          ; clearing
        CALL    wait_key                  ; routine WAIT-KEY

        PUSH    IX                        ; save pointer to descriptor.
        LD      DE,$0011                  ; there are seventeen bytes.
        XOR     A                         ; signal a header.
        CALL    sa_bytes                  ; routine SA-BYTES

        POP     IX                        ; restore descriptor pointer.

        LD      B,$32                     ; wait for a second - 50 interrupts.

sa_1_sec:
        HALT                              ; wait for interrupt
        DJNZ    sa_1_sec                  ; back to SA-1-SEC until pause complete.

        LD      E,(IX+$0B)                ; fetch length of bytes from the
        LD      D,(IX+$0C)                ; descriptor.

        LD      A,$FF                     ; signal data bytes.

        POP     IX                        ; retrieve pointer to start
        JP      sa_bytes                  ; jump back to SA-BYTES


; Arrangement of two headers in workspace.
; Originally IX addresses first location and only one header is required
; when saving.
;
;   OLD     NEW         PROG   DATA  DATA  CODE
;   HEADER  HEADER             num   chr          NOTES.
;   ------  ------      ----   ----  ----  ----   -----------------------------
;   IX-$11  IX+$00      0      1     2     3      Type.
;   IX-$10  IX+$01      x      x     x     x      F  ($FF if filename is null).
;   IX-$0F  IX+$02      x      x     x     x      i
;   IX-$0E  IX+$03      x      x     x     x      l
;   IX-$0D  IX+$04      x      x     x     x      e
;   IX-$0C  IX+$05      x      x     x     x      n
;   IX-$0B  IX+$06      x      x     x     x      a
;   IX-$0A  IX+$07      x      x     x     x      m
;   IX-$09  IX+$08      x      x     x     x      e
;   IX-$08  IX+$09      x      x     x     x      .
;   IX-$07  IX+$0A      x      x     x     x      (terminal spaces).
;   IX-$06  IX+$0B      lo     lo    lo    lo     Total
;   IX-$05  IX+$0C      hi     hi    hi    hi     Length of datablock.
;   IX-$04  IX+$0D      Auto   -     -     Start  Various
;   IX-$03  IX+$0E      Start  a-z   a-z   addr   ($80 if no autostart).
;   IX-$02  IX+$0F      lo     -     -     -      Length of Program
;   IX-$01  IX+$10      hi     -     -     -      only i.e. without variables.
;


; ------------------------
; Canned cassette messages
; ------------------------
; The last-character-inverted Cassette messages.
; Starts with normal initial step-over byte.

tape_msgs:
        DEFB    $80
        DEFM    "Start tape, then press any key"
tape_last4:
        DEFB    '.'+$80
        DEFB    $0D
        DEFM    "Program:"
        DEFB    ' '+$80
        DEFB    $0D
        DEFM    "Number array:"
        DEFB    ' '+$80
        DEFB    $0D
        DEFM    "Character array:"
        DEFB    ' '+$80
        DEFB    $0D
        DEFM    "Bytes:"
        DEFB    ' '+$80


;**************************************************
;** Part 5. SCREEN AND PRINTER HANDLING ROUTINES **
;**************************************************

; ---------------------
; General PRINT routine
; ---------------------
; This is the routine most often used by the RST 10H restart although the
; subroutine is on two occasions called directly when it is known that
; output will definitely be to the lower screen.

print_out:
        CALL    po_fetch                  ; routine PO-FETCH fetches print position
                                          ; to HL register pair.
        CP      $20                       ; is character a space or higher ?
        JP      NC,po_able                ; jump forward to PO-ABLE if so.

        CP      $06                       ; is character in range 00-05 ?
        JR      C,po_quest                ; to PO-QUEST to print '?' if so.

        CP      $18                       ; is character in range 24d - 31d ?
        JR      NC,po_quest               ; to PO-QUEST to also print '?' if so.

        LD      HL,ctlchrtab - 6          ; address 0A0B - the base address of control
                                          ; character table - where zero would be.
        LD      E,A                       ; control character 06 - 23d
        LD      D,$00                     ; is transferred to DE.

        ADD     HL,DE                     ; index into table.

        LD      E,(HL)                    ; fetch the offset to routine.
        ADD     HL,DE                     ; add to make HL the address.
        PUSH    HL                        ; push the address.
        JP      po_fetch                  ; to PO-FETCH, as the screen/printer position
                                          ; has been disturbed, and indirectly to
                                          ; routine on stack.

; -----------------------
; Control character table
; -----------------------
; For control characters in the range 6 - 23d the following table
; is indexed to provide an offset to the handling routine that
; follows the table.

ctlchrtab:
        DEFB    po_comma - $              ; 06d offset $4E to Address: PO-COMMA
        DEFB    po_quest - $              ; 07d offset $57 to Address: PO-QUEST
        DEFB    po_back - $               ; 08d offset $10 to Address: PO-BACK-1
        DEFB    po_right - $              ; 09d offset $29 to Address: PO-RIGHT
        DEFB    po_quest - $              ; 10d offset $54 to Address: PO-QUEST
        DEFB    po_quest - $              ; 11d offset $53 to Address: PO-QUEST
        DEFB    po_quest - $              ; 12d offset $52 to Address: PO-QUEST
        DEFB    po_enter - $              ; 13d offset $37 to Address: PO-ENTER
        DEFB    po_quest - $              ; 14d offset $50 to Address: PO-QUEST
        DEFB    po_quest - $              ; 15d offset $4F to Address: PO-QUEST
        DEFB    po_1_oper - $             ; 16d offset $5F to Address: PO-1-OPER
        DEFB    po_1_oper - $             ; 17d offset $5E to Address: PO-1-OPER
        DEFB    po_1_oper - $             ; 18d offset $5D to Address: PO-1-OPER
        DEFB    po_1_oper - $             ; 19d offset $5C to Address: PO-1-OPER
        DEFB    po_1_oper - $             ; 20d offset $5B to Address: PO-1-OPER
        DEFB    po_1_oper - $             ; 21d offset $5A to Address: PO-1-OPER
        DEFB    po_2_oper - $             ; 22d offset $54 to Address: PO-2-OPER
        DEFB    po_2_oper - $             ; 23d offset $53 to Address: PO-2-OPER


; -------------------
; Cursor left routine
; -------------------
; Backspace one character. If backspacing from left side of screen (chan S/K), go to last char of previous line, if
; not on first line of S/K. For ZX printer if cannot backspace because at start of line, do nothing. Update stored
; position.
;
; If printer in use:
;   On entry:
;     Bit 1 of FLAGS set
;     C = current printer column (33 for leftmost column, ... 2 for rightmost column, 1 = end of line)
;   On exit:
;     A = 33 - C = actual printer x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     C = new printer column (33 for leftmost column, ... 2 for rightmost column, 1 = end of line):
;         entry C != 33;
;           exit C = entry C + 1
;         entry C == 33:
;           exit C = 33;
;     D = 0
;     E = 33 - C = actual printer x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     HL = printer buffer address = 0x5b00 + (33-exit C)
;     F = X3_FLAG | H_FLAG
;     [P_POSN_X] set to printer position (=exit C)
;     [PR_CC] set to printer buffer address (=exit HL)
;
; If upper screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] clear
;     B = current upper screen row (24 - actual upper screen row)
;         => 24 for top upper screen line, 23 for second upper screen line, ...
;     C = current upper screen column (33 for leftmost column, ... 2 for rightmost column, 1 = end of line)
;   On exit:
;     A = 33 - C = actual upper screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     C = new upper screen column (33 for leftmost column, ... 2 for rightmost column, 1 = end of line):
;         entry C != 33;
;           exit B = ....
;           exit C = entry C + 1
;         entry C == 33:
;           entry B != ....
;             exit B = ....
;             exit C = ....
;           entry B == ....
;             exit B = ....
;             exit C = ....
;     D = 0
;     E = 33 - C = actual upper screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     HL = 0x4000 + (33-C) + 32*8*8*int((24-B)/8) + 32*((24-B)%8) = display file address for upper screen position
;     F = H_FLAG|X3_FLAG|PV_FLAG|Z_FLAG
;     [S_POSN_{X,Y}] set to upper screen position (=BC)
;     [DF_CC] set to display file address of upper screen position (=HL)
;
; If lower screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] set
;     [DF_SZ] set to number of lines for lower screen
;     B = value to store in S_POSN_Y_L and ECHO_E_Y = 48 - [DF_SZ] - actual lower screen row
;         => 24 for top lower screen line, 23 for second lower screen line, ...
;     C = value to store in S_POSN_X_L and ECHO_E_X (33 for leftmost column, ... 2 for rightmost column, 1 = end of line)
;   On exit:
;     A = 33 - C = actual lower screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     D = 0
;     E = 33 - C = actual lower screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     HL = 0x4000 + (33-C) + 32*8*8*int((48-B-[DF_SZ])/8) + 32*((48-B-[DF_SZ])%8) = display file address for lower screen position
;     F = X3_FLAG | H_FLAG
;     [S_POSN_{X,Y}_L] set to lower screen position (=BC)
;     [ECHO_E_{X,Y}] set to lower screen position (=BC)
;     [DF_CC_L] set to display file address of lower screen position (=HL)
po_back:
        INC     C                         ; move left one column.
        LD      A,$22                     ; value $21 is leftmost column.
        CP      C                         ; have we passed ?
        JR      NZ,2f                     ; to 2: if not and store new position.

        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - is printer in use ?
        JR      NZ,1f                     ; to 1: if so, as we are unable to
                                          ; backspace from the leftmost position.


        INC     B                         ; move up one screen line
        LD      C,$02                     ; the rightmost column position.
        LD      A,$18                     ; Note. This should be $19
                                          ; credit. Dr. Frank O'Hara, 1982

        CP      B                         ; has position moved past top of screen ?
        JR      NZ,2f                     ; to 2: if not and store new position.

        DEC     B                         ; else back to $18.

1:
        LD      C,$21                     ; the leftmost column position.

2:
        JP      cl_set                    ; to CL-SET and PO-STORE to save new
                                          ; position in system variables.

; --------------------
; Cursor right routine
; --------------------
; This moves the print position to the right leaving a trail in the
; current background colour.
; "However the programmer has failed to store the new print position
;  so CHR$ 9 will only work if the next print position is at a newly
;  defined place.
;   e.g. PRINT PAPER 2; CHR$ 9; AT 4,0;
;  does work but is not very helpful"
; - Dr. Ian Logan, Understanding Your Spectrum, 1982.

po_right:
        LD      A,(P_FLAG)                ; fetch P_FLAG value
        PUSH    AF                        ; and save it on stack.

        LD      (IY+(P_FLAG-C_IY)),$01    ; temporarily set P_FLAG 'OVER 1'.
        LD      A,$20                     ; prepare a space.
        CALL    po_char                   ; routine PO-CHAR to print it.
                                          ; Note. could be PO-ABLE which would update
                                          ; the column position.

        POP     AF                        ; restore the permanent flag.
        LD      (P_FLAG),A                ; and restore system variable P_FLAG

        RET                               ; return without updating column position

; -----------------------
; Perform carriage return
; -----------------------
; A carriage return is 'printed' to screen or printer buffer.

po_enter:
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - is printer in use ?
        JP      NZ,copy_buff              ; to COPY-BUFF if so, to flush buffer and reset
                                          ; the print position.

        LD      C,$21                     ; the leftmost column position.
        CALL    po_scr                    ; routine PO-SCR handles any scrolling required.
        DEC     B                         ; to next screen line.
        JP      cl_set                    ; jump forward to CL-SET to store new position.

; -----------
; Print comma
; -----------
; The comma control character. The 32 column screen has two 16 character
; tabstops.  The routine is only reached via the control character table.

po_comma:
        CALL    po_fetch                  ; routine PO-FETCH - seems unnecessary.

        LD      A,C                       ; the column position. $21-$01
        DEC     A                         ; move right. $20-$00
        DEC     A                         ; and again   $1F-$00 or $FF if trailing
        AND     $10                       ; will be $00 or $10.
        JR      po_fill                   ; forward to PO-FILL

; -------------------
; Print question mark
; -------------------
; This routine prints a question mark which is commonly
; used to print an unassigned control character in range 0-31d.
; there are a surprising number yet to be assigned.

po_quest:
        LD      A,$3F                     ; prepare the character '?'.
        JR      po_able                   ; forward to PO-ABLE.

; --------------------------------
; Control characters with operands
; --------------------------------
; Certain control characters are followed by 1 or 2 operands.
; The entry points from control character table are PO-2-OPER and PO-1-OPER.
; The routines alter the output address of the current channel so that
; subsequent RST 10H instructions take the appropriate action
; before finally resetting the output address back to PRINT-OUT.

po_tv_2:
        LD      DE,po_cont                ; address: PO-CONT will be next output routine
        LD      (TVDATA_hi),A             ; store first operand in TVDATA-hi
        JR      po_change                 ; forward to PO-CHANGE >>

; ---

; -> This initial entry point deals with two operands - AT or TAB.

po_2_oper:
        LD      DE,po_tv_2                ; address: PO-TV-2 will be next output routine
        JR      po_tv_1                   ; forward to PO-TV-1

; ---

; -> This initial entry point deals with one operand INK to OVER.

po_1_oper:
        LD      DE,po_cont                ; address: PO-CONT will be next output routine

po_tv_1:
        LD      (TVDATA),A                ; store control code in TVDATA-lo

; -------------------------------------------------
; Change the output routine for the current channel
; -------------------------------------------------
; On entry:
;   DE = address of new output routine for current channel
; On exit:
;   HL = [CURCHL]+1
;   [[CURCHL]] = DE

po_change:
        LD      HL,(CURCHL)               ; use CURCHL to find current output channel.
        LD      (HL),E                    ; make it
        INC     HL                        ; the supplied
        LD      (HL),D                    ; address from DE.
        RET                               ; return.

; ---

po_cont:
        LD      DE,print_out              ; Address: PRINT-OUT
        CALL    po_change                 ; routine PO-CHANGE to restore normal channel.
        LD      HL,(TVDATA)               ; TVDATA gives control code and possible
                                          ; subsequent character
        LD      D,A                       ; save current character
        LD      A,L                       ; the stored control code
        CP      $16                       ; was it INK to OVER (1 operand) ?
        JP      C,co_temp_5               ; to CO-TEMP-5

        JR      NZ,po_tab                 ; to PO-TAB if not 22d i.e. 23d TAB.

                                          ; else must have been 22d AT.
        LD      B,H                       ; line to H   (0-23d)
        LD      C,D                       ; column to C (0-31d)
        LD      A,$1F                     ; the value 31d
        SUB     C                         ; reverse the column number.
        JR      C,po_at_err               ; to PO-AT-ERR if C was greater than 31d.

        ADD     A,$02                     ; transform to system range $02-$21
        LD      C,A                       ; and place in column register.

        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - is printer in use ?
        JR      NZ,po_at_set              ; to PO-AT-SET as line can be ignored.

        LD      A,$16                     ; 22 decimal
        SUB     B                         ; subtract line number to reverse
                                          ; 0 - 22 becomes 22 - 0.

po_at_err:
        JP      C,report_bb               ; to REPORT-B if higher than 22 decimal
                                          ; Integer out of range.

        INC     A                         ; adjust for system range $01-$17
        LD      B,A                       ; place in line register
        INC     B                         ; adjust to system range  $02-$18
        BIT     0,(IY+(TV_FLAG-C_IY))     ; TV_FLAG  - Lower screen in use ?
        JP      NZ,po_scr                 ; exit to PO-SCR to test for scrolling

        CP      (IY+(DF_SZ-C_IY))         ; Compare against DF_SZ
        JP      C,report_5                ; to REPORT-5 if too low
                                          ; Out of screen.

po_at_set:
        JP      cl_set                    ; print position is valid so exit via CL-SET

; Continue here when dealing with TAB.
; Note. In BASIC, TAB is followed by a 16-bit number and was initially
; designed to work with any output device.

po_tab:
        LD      A,H                       ; transfer parameter to A
                                          ; Losing current character -
                                          ; High byte of TAB parameter.


po_fill:
        CALL    po_fetch                  ; routine PO-FETCH, HL-addr, BC=line/column.
                                          ; column 1 (right), $21 (left)
        ADD     A,C                       ; add operand to current column
        DEC     A                         ; range 0 - 31+
        AND     $1F                       ; make range 0 - 31d
        RET     Z                         ; return if result zero

        LD      D,A                       ; Counter to D
        SET     0,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal suppress leading space.

po_space:
        LD      A,$20                     ; space character.
        CALL    po_save                   ; routine PO-SAVE prints the character
                                          ; using alternate set (normal output routine)
        DEC     D                         ; decrement counter.
        JR      NZ,po_space               ; to PO-SPACE until done

        RET                               ; return

; ----------------------
; Printable character(s)
; ----------------------
; This routine prints printable characters and continues into
; the position store routine

po_able:
        CALL    po_any                    ; routine PO-ANY
                                          ; and continue into position store routine.

; -------------------------------------
; Store line, column, and pixel address
; -------------------------------------
; This routine updates the system variables associated with either
; the main screen, the lower screen/input buffer or the ZX printer.
;
; If printer in use:
;   On entry:
;     Bit 1 of FLAGS set
;     C = value to store in P_POSN_X
;     HL= value to store in PR_CC
;   On exit:
;     [P_POSN_X] set to printer position
;     [PR_CC] set to printer buffer address
;     F=
;       X3 / H set
;       X5 / S / N / PV / Z clear
;       C unchanged
;
; If upper screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] clear
;     B = value to store in S_POSN_Y
;     C = value to store in S_POSN_X
;     HL= value to store in DF_CC
;   On exit:
;     [S_POSN_{X,Y}] set to upper screen position
;     [DF_CC] set to display file address of upper screen position
;     F=
;       PV / X3 / H / Z set
;       X5 / S / N clear
;       C unchanged
;
; If lower screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] set
;     B = value to store in S_POSN_Y_L and ECHO_E_Y
;     C = value to store in S_POSN_X_L and ECHO_E_X
;     HL= value to store in DF_CC_L
;   On exit:
;     [S_POSN_{X,Y}_L] set to lower screen position
;     [ECHO_E_{X,Y}] set to lower screen position
;     [DF_CC_L] set to display file address of lower screen position
;     F=
;       X3 / H set
;       X5 / S / N / PV / Z clear
;       C unchanged

po_store:
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - Is printer in use ?
        JR      NZ,po_st_pr               ; to PO-ST-PR if so

        BIT     0,(IY+(TV_FLAG-C_IY))     ; TV_FLAG  - Lower screen in use ?
        JR      NZ,po_st_e                ; to PO-ST-E if so

        LD      (S_POSN_X),BC             ; S_POSN_{X,Y} line/column upper screen
        LD      (DF_CC),HL                ; DF_CC  display file address
        RET                               ;

; ---

po_st_e:
        LD      (S_POSN_X_L),BC           ; S_POSN_{X,Y}_L lower screen
        LD      (ECHO_E_X),BC             ; ECHO_E_{X,Y} line/column input buffer
        LD      (DF_CC_L),HL              ; DF_CC_L lower screen memory address
        RET                               ;

; ---

po_st_pr:
        LD      (IY+(P_POSN_X-C_IY)),C    ; P_POSN_X column position printer
        LD      (PR_CC),HL                ; PR_CC  full printer buffer memory address
        RET                               ;

; -------------------------
; Fetch position parameters
; -------------------------
; This routine fetches the line/column and display file address
; of the upper and lower screen or, if the printer is in use,
; the column position and absolute memory address.
; Note. that PR-CC-hi (23681) is used by this routine and the one above
; and if, in accordance with the manual (that says this is unused), the
; location has been used for other purposes, then subsequent output
; to the printer buffer could corrupt a 256-byte section of memory.
;
; If printer in use:
;   On entry:
;     Bit 1 of FLAGS set
;     [P_POSN_X] set to printer position
;     [PR_CC] set to printer buffer address
;   On exit:
;     C=[P_POSN_X]
;     HL=[PR_CC]
;     F=
;       X3 / H set
;       X5 / S / N / PV / Z clear
;       C unchanged
;
; If upper screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] clear
;     [S_POSN_{X,Y}] set to upper screen position
;     [DF_CC] set to display file address of upper screen position
;   On exit:
;     B=[S_POSN_Y]
;     C=[S_POSN_X]
;     HL=[DF_CC]
;     F=
;       PV / X3 / H / Z set
;       X5 / S / N clear
;       C unchanged
;
; If lower screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] set
;     [S_POSN_{X,Y}_L] set to lower screen position
;     [DF_CC_L] set to display file address of lower screen position
;   On exit:
;     B=[S_POSN_Y_L]
;     C=[S_POSN_X_L]
;     HL=[DF_CC_L]
;     F=
;       X3 / H set (X3 = bit 3 of high byte of FLAGS = bit 3 of 0x5c = 1)
;       X5 / S / N / PV / Z clear (X5 taken from bit 5 of high byte of FLAGS = bit 5 of 0x5c = 0)
;       C unchanged

po_fetch:
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - Is printer in use
        JR      NZ,po_f_pr                ; to PO-F-PR if so

                                          ; assume upper screen
        LD      BC,(S_POSN_X)             ; S_POSN
        LD      HL,(DF_CC)                ; DF_CC display file address
        BIT     0,(IY+(TV_FLAG-C_IY))     ; TV_FLAG  - Lower screen in use ?
        RET     Z                         ; return if upper screen

                                          ; ah well, was lower screen
        LD      BC,(S_POSN_X_L)           ; S_POSN_{X,Y}_L
        LD      HL,(DF_CC_L)              ; DFCCL
        RET                               ; return

; ---

po_f_pr:
        LD      C,(IY+(P_POSN_X-C_IY))    ; P_POSN_X column only
        LD      HL,(PR_CC)                ; PR_CC printer buffer address
        RET                               ; return

; -------------------
; Print any character
; -------------------
; This routine is used to print any character in range 32d - 255d
; It is only called from PO-ABLE which continues into PO-STORE

po_any:
        CP      $80                       ; ASCII ?
        JR      C,po_char                 ; to PO-CHAR if so.

        CP      $90                       ; test if a block graphic character.
        JR      NC,po_t_udg               ; to PO-T&UDG to print tokens and udg's

; The 16 2*2 mosaic characters 128-143 decimal are formed from
; bits 0-3 of the character.

        LD      B,A                       ; save character
        CALL    1f                        ; routine to construct top half
                                          ; then bottom half.
        CALL    po_fetch                  ; routine PO-FETCH fetches print position.
        LD      DE,MEMBOT                 ; MEM-0 is location of 8 bytes of character
        JR      pr_all                    ; to PR-ALL to print to screen or printer

; ---

1:      LD      HL,MEMBOT                 ; address MEM-0 - a temporary buffer in
                                          ; systems variables which is normally used
                                          ; by the calculator.
        CALL    po_mosaic_half            ; routine PO-MOSAIC-HALF to construct top half
                                          ; and continue into routine to construct
                                          ; bottom half.

; On entry:
;   B = mosaic pattern in bits 1 and 0 ("<b1>", "<b0>")
;   HL = address to write pattern to
; On exit:
;   [HL+0] = 0b<b1><b1><b1><b1><b0><b0><b0><b0>
;   [HL+1] = 0b<b1><b1><b1><b1><b0><b0><b0><b0>
;   [HL+2] = 0b<b1><b1><b1><b1><b0><b0><b0><b0>
;   [HL+3] = 0b<b1><b1><b1><b1><b0><b0><b0><b0>
;   A = 0b<b1><b1><b1><b1><b0><b0><b0><b0>
;   B = (B | carry<<8) >> 2
;   C = 0
;   HL += 4
;   F = Z_FLAG|N_FLAG

po_mosaic_half:
        RR      B                         ; rotate bit 0/2 to carry
        SBC     A,A                       ; result $00 or $FF
        AND     $0F                       ; mask off right hand side
        LD      C,A                       ; store part in C
        RR      B                         ; rotate bit 1/3 of original chr to carry
        SBC     A,A                       ; result $00 or $FF
        AND     $F0                       ; mask off left hand side
        OR      C                         ; combine with stored pattern
        LD      C,$04                     ; four bytes for top/bottom half

1:      LD      (HL),A                    ; store bit patterns in temporary buffer
        INC     HL                        ; next address
        DEC     C                         ; jump back to
        JR      NZ,1b                     ; loop until byte is stored 4 times

        RET                               ; return

; ---

; Tokens and User defined graphics are now separated.

po_t_udg:
        JP      print_token_udg_patch     ; Spectrum 128 patch
        NOP
rejoin_po_t_udg:
        ADD     A,$15                     ; add 21d to restore to 0 - 20
        PUSH    BC                        ; save current print position
        LD      BC,(UDG)                  ; fetch UDG to address bit patterns
        JR      po_char_2                 ; to PO-CHAR-2 - common code to lay down
                                          ; a bit patterned character

; ---

po_t:
        CALL    po_tokens                 ; routine PO-TOKENS prints tokens
        JP      po_fetch                  ; exit via a JUMP to PO-FETCH as this routine
                                          ; must continue into PO-STORE.
                                          ; A JR instruction could be used.

; This routine is used to print ASCII characters  32d - 127d.
;
; Bit 0 of [FLAGS] updated to 1 if A=' ' (=> no leading space), otherwise 0 (=>
; leading space).
;
; On entry:
;   A=char (32-127)
;   HL=destination address in printer buffer or display file
;   C=column (33-actual x position, or 1 for end-of-line)
;   [CHARS] = font table address of theoretical char 0
;   [FLAGS] bit 1 (printer in use or not)
;   [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
;   if printer not in use:
;     B=line (24-actual y position)
;     [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
;     [TV_FLAGS] bit 0 (lower screen in use or not)
;     [DF_SZ]
;     [ATTR_T]
;     [MASK_T]
; On exit:
;   [FLAGS] bit 0 == 1 if A==' ' else 0
;   If printer in use:
;     printer buffer updated
;     If was at end-of-line before printing (entry C == 1):
;       Printer buffer flushed
;   Else:
;     display file and attributes file updated
;     A' = last byte written to display file
;     F' disturbed
;     A = attribute file value
;     F disturbed
;     BC = new cursor position
;     DE = [ATTR_T] (D=[MASK_T], E=[ATTR_T])
;     HL += 1 (correct new cursor memory location, unless L == 0)
;     If was at end-of-line before printing (entry C == 1):
;       If lower screen:
;         [S_POSN_X_L] = 33 (start of line)
;         [S_POSN_Y_L] = B-1 (line below)
;         [ECHO_E_X] = 33 (start of line)
;         [ECHO_E_Y] = B-1 (line below)
;         [DF_CC_L] set to display file address for [S_POSN_{X,Y}_L]
;       If upper screen:
;         [S_POSN_X] = 33 (start of line)
;         [S_POSN_Y] = B-1 (line below)
;         [DF_CC] set to display file address for [S_POSN_{X,Y}]
po_char:
        PUSH    BC                        ; save print position
        LD      BC,(CHARS)                ; address CHARS

; This common code is used to transfer the character bytes to memory.

po_char_2:
        EX      DE,HL                     ; transfer destination address to DE
        LD      HL,FLAGS                  ; point to FLAGS
        RES     0,(HL)                    ; allow for leading space
        CP      $20                       ; is it a space ?
        JR      NZ,1f                     ; to 1: if not

        SET     0,(HL)                    ; signal no leading space to FLAGS

1:
        LD      H,$00                     ; set high byte to 0
        LD      L,A                       ; character to A
                                          ; 0-21 UDG or 32-127 ASCII.
        ADD     HL,HL                     ; multiply
        ADD     HL,HL                     ; by
        ADD     HL,HL                     ; eight
        ADD     HL,BC                     ; HL now points to first byte of character
        POP     BC                        ; the source address CHARS or UDG
        EX      DE,HL                     ; character address to DE

; --------------------
; Print all characters
; --------------------
; This entry point entered from above to render ASCII and UDGs
; but also from earlier to render mosaic characters to the screen
; or printer.
;
; On entry:
;   HL=destination address in printer buffer or display file
;   DE=address of character pixel map (8 bytes for the 8x8 pixels) to render
;   C=column (33-actual x position, or 1 for end-of-line)
;   [FLAGS] bit 1 (printer in use or not)
;   [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
;   if printer not in use:
;     B=line (24-actual y position)
;     [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
;     [TV_FLAGS] bit 0 (lower screen in use or not)
;     [DF_SZ]
;     [ATTR_T]
;     [MASK_T]
; On exit:
;   If printer in use:
;     printer buffer updated
;     If was at end-of-line before printing (entry C == 1):
;       Printer buffer flushed
;   Else:
;     display file and attributes file updated
;     A' = last byte written to display file
;     F' disturbed
;     A = attribute file value
;     F disturbed
;     BC = new cursor position
;     DE = [ATTR_T] (D=[MASK_T], E=[ATTR_T])
;     HL += 1 (correct new cursor memory location, unless L == 0)
;     If was at end-of-line before printing (entry C == 1):
;       If lower screen:
;         [S_POSN_X_L] = 33 (start of line)
;         [S_POSN_Y_L] = B-1 (line below)
;         [ECHO_E_X] = 33 (start of line)
;         [ECHO_E_Y] = B-1 (line below)
;         [DF_CC_L] set to display file address for [S_POSN_{X,Y}_L]
;       If upper screen:
;         [S_POSN_X] = 33 (start of line)
;         [S_POSN_Y] = B-1 (line below)
;         [DF_CC] set to display file address for [S_POSN_{X,Y}]
pr_all:
        LD      A,C                       ; column to A
        DEC     A                         ; move right
        LD      A,$21                     ; pre-load with leftmost position
        JR      NZ,pr_all_1               ; but if not zero to PR-ALL-1

        DEC     B                         ; down one line
        LD      C,A                       ; load C with $21
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - Is printer in use
        JR      Z,pr_all_1                ; to PR-ALL-1 if not

        PUSH    DE                        ; save source address
        CALL    copy_buff                 ; routine COPY-BUFF outputs line to printer
        POP     DE                        ; restore character source address
        LD      A,C                       ; the new column number ($21) to C

pr_all_1:
        CP      C                         ; this test is really for screen - new line ?
        PUSH    DE                        ; save source

        CALL    Z,po_scr                  ; routine PO-SCR considers scrolling

        POP     DE                        ; restore source
        PUSH    BC                        ; save line/column
        PUSH    HL                        ; and destination
        LD      A,(P_FLAG)                ; fetch P_FLAG to accumulator
        LD      B,$FF                     ; prepare OVER mask in B.
        RRA                               ; bit 0 set if OVER 1
        JR      C,pr_all_2                ; to PR-ALL-2

        INC     B                         ; set OVER mask to 0

pr_all_2:
        RRA                               ; skip bit 1 of P_FLAG
        RRA                               ; bit 2 is INVERSE
        SBC     A,A                       ; will be FF for INVERSE 1 else zero
        LD      C,A                       ; transfer INVERSE mask to C
        LD      A,$08                     ; prepare to count 8 bytes
        AND     A                         ; clear carry to signal screen
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - is printer in use ?
        JR      Z,pr_all_3                ; to PR-ALL-3 if screen

        SET     1,(IY+(FLAGS2-C_IY))      ; update FLAGS2  - signal printer buffer has
                                          ; been used.
        SCF                               ; set carry flag to signal printer.

pr_all_3:
        EX      DE,HL                     ; now HL=source, DE=destination

pr_all_4:
        EX      AF,AF'                    ; save printer/screen flag
        LD      A,(DE)                    ; fetch existing destination byte
        AND     B                         ; consider OVER
        XOR     (HL)                      ; now XOR with source
        XOR     C                         ; now with INVERSE MASK
        LD      (DE),A                    ; update screen/printer
        EX      AF,AF'                    ; restore flag
        JR      C,pr_all_6                ; to PR-ALL-6 - printer address update

        INC     D                         ; gives next pixel line down screen

pr_all_5:
        INC     HL                        ; address next character byte
        DEC     A                         ; the byte count is decremented
        JR      NZ,pr_all_4               ; back to PR-ALL-4 for all 8 bytes

        EX      DE,HL                     ; destination to HL
        DEC     H                         ; bring back to last updated screen position
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - is printer in use ?
        CALL    Z,po_attr                 ; if not, call routine PO-ATTR to update
                                          ; corresponding colour attribute.
        POP     HL                        ; restore screen/printer position
        POP     BC                        ; and line column
        DEC     C                         ; move column to right
        INC     HL                        ; increase screen/printer position
                                          ; Note: at end of screen thirds this will be the wrong address,
                                          ; but cl_set presumably fixes it, before subsequent pr_all call.
                                          ; Instead of calling cl_set everywhere, probably the above
                                          ; could have been fixed to handle screen third endings.

        RET                               ; return and continue into PO-STORE
                                          ; within PO-ABLE

; ---

; This branch is used to update the printer position by 32 places
; Note. The high byte of the address D remains constant (which it should).

pr_all_6:
        EX      AF,AF'                    ; save the flag
        LD      A,$20                     ; load A with 32 decimal
        ADD     A,E                       ; add this to E
        LD      E,A                       ; and store result in E
        EX      AF,AF'                    ; fetch the flag
        JR      pr_all_5                  ; back to PR-ALL-5

; -------------
; Set attribute
; -------------
; This routine is entered with the HL register holding the last screen
; address to be updated by PRINT or PLOT.
; The Spectrum screen arrangement leads to the L register holding
; the correct value for the attribute file and it is only necessary
; to manipulate H to form the correct colour attribute address.
; On entry:
;   HL = display file address
; On exit:
;   A = new attribute value
;   D = [MASK-T]
;   E = [ATTR-T]
;   HL = attributes file address
;   F = <updated>
;   [HL] = A

po_attr:
        LD       A,H                      ; fetch high byte $40 - $57
        RRCA                              ; shift
        RRCA                              ; bits 3 and 4
        RRCA                              ; to right.
        AND     $03                       ; range is now 0 - 2
        OR      $58                       ; form correct high byte for third of screen
        LD      H,A                       ; HL is now correct
        LD      DE,(ATTR_T)               ; make E hold ATTR_T, D hold MASK-T
        LD      A,(HL)                    ; fetch existing attribute
        XOR     E                         ; apply masks
        AND     D                         ;
        XOR     E                         ;
        BIT     6,(IY+(P_FLAG-C_IY))      ; test P_FLAG  - is this PAPER 9 ??
        JR      Z,po_attr_1               ; skip to PO-ATTR-1 if not.

        AND     $C7                       ; set paper
        BIT     2,A                       ; to contrast with ink
        JR      NZ,po_attr_1              ; skip to PO-ATTR-1

        XOR     $38                       ;

po_attr_1:
        BIT     4,(IY+(P_FLAG-C_IY))      ; test P_FLAG  - Is this INK 9 ??
        JR      Z,po_attr_2               ; skip to PO-ATTR-2 if not

        AND     $F8                       ; make ink
        BIT     5,A                       ; contrast with paper.
        JR      NZ,po_attr_2              ; to PO-ATTR-2

        XOR     $07                       ;

po_attr_2:
        LD      (HL),A                    ; save the new attribute.
        RET                               ; return.

; ----------------
; Message printing
; ----------------
; Find message in table, print it, with possible leading space (no trailing
; space). This entry point is used to print tape, boot-up, scroll? and error
; messages.
;
; Leading space if A >= 32 and first char >= 'A' and bit 0 of [IY+(FLAGS-C_IY)] is clear.
;
; On entry:
;   Bit 0 of [IY+(FLAGS-C_IY)] set if leading space should be suppressed
;   A = index of entry:
;         first message cannot be retrieved (typically '?'+$80)
;         0 for second message
;         1 for third message
;         ...
;   DE = address of message table
;   [[CURCHL]] = print routine to call
;   ... any settings that routine at [[CURCHL]] requires ...
; On exit:
;   D = 0
;   E = L
;   HL preserved (regardless of whether [[CURCHL]] changes it)
;   AF is determined as follows:
;
;     if message ends with '$' or message ends in a char >= 'A':
;       A = 0 (regardless of whether [[CURCHL]] changes it)
;       F = Carry set, Negative set, ... (result of CP 0x03) (regardless of whether [[CURCHL]] changes it)
;     else:
;       A = last char of message * 2 (regardless of whether [[CURCHL]] changes it)
;       F = C_FLAG | N_FLAG, ... (result of CP 0x82) (regardless of whether [[CURCHL]] changes it)
;
;   Plus any other register changes that [[CURCHL]] makes when printing the message (or trailing space) ...

po_msg:
        PUSH    HL                        ; put hi-byte zero on stack to suppress
        LD      H,$00                     ; trailing spaces
        EX      (SP),HL                   ; ld h,0; push hl would have done ?
                                          ; (perhaps preserving hl was important)
        JR      po_table                  ; forward to PO-TABLE.

; ---

; This entry point prints the BASIC keywords, '<>' etc. from alt set

; ---------------------------------------------------------------------------------------
; Find message in token table and print it with possible leading and/or trailing space(s)
; ---------------------------------------------------------------------------------------
; Leading space if bit 0 of [IY+(FLAGS-C_IY)] is clear, except for:
;
;   RND
;   INKEY$
;   PI
;   FN
;   POINT
;   SCREEN$
;   ATTR
;   AT
;   TAB
;   VAL$
;   CODE
;   VAL
;   LEN
;   SIN
;   COS
;   TAN
;   ASN
;   ACS
;   ATN
;   LN
;   EXP
;   INT
;   SQR
;   SGN
;   ABS
;   PEEK
;   IN
;   USR
;   STR$
;   CHR$
;   NOT
;   BIN
;   <=
;   >=
;   <>
;
; Trailing space (regardless of bit 0 of [IY+(FLAGS-C_IY)]), except for:
;
;   RND
;   INKEY$
;   PI
;   <=
;   >=
;   <>
;   OPEN #
;   CLOSE #
;
; On entry:
;   A = index of BASIC keyword (0x00 = RND ... 0x5a = COPY)
;   Bit 0 of [IY+(FLAGS-C_IY)] set if leading space should be suppressed regardless of keyword
;   [[CURCHL]] = print routine to call
;   ... any settings that routine at [[CURCHL]] requires ...
; On exit:
;   DE = entry AF
;   HL preserved
;   AF is determined as follows:
;
;     For RND / INKEY$ / PI:
;       A unchanged
;       F = Carry | Negative | Half carry | Sign
;
;     For <= / >= / <> / OPEN # / CLOSE #:
;       A = last char of message * 2
;       F = Carry | Negative | Overflow | Sign
;
;     For all other keywords:
;       A = ' ' (unless [[CURCHL]] updates A when printing trailing space)
;       F = (result of entry CP 0x03) (unless changed by [[CURCHL]] when printing trailing space)
;
;   Plus any changes that [[CURCHL]] makes to BC, AF', BC', DE', HL', IX, IY.

po_tokens:
        LD      DE,tkn_table              ; address: TKN-TABLE
        PUSH    AF                        ; save the token number to control
                                          ; trailing spaces - see later *

; ---------------------------------------------------------------------------------
; Find message in table and print it with possible leading and/or trailing space(s)
; ---------------------------------------------------------------------------------
; Leading space if A >= 32 and first char >= 'A' and bit 0 of [IY+(FLAGS-C_IY)] is clear.
; Trailing space if value on stack >= 0x300 and (message ends with a char >= 'A' or '$').
;
; On entry:
;   Bit 0 of [IY+(FLAGS-C_IY)] set if leading space should be suppressed
;   A = index of entry:
;         first message cannot be retrieved (typically '?'+$80)
;         0 for second message
;         1 for third message
;         ...
;   DE = address of message table
;   [[CURCHL]] = print routine to call
;   ... any settings that routine at [[CURCHL]] requires ...
;   16 bit value on stack
; On exit:
;   DE = value from stack
;   HL preserved
;   AF is determined as follows:
;
;     if message ends with '$' or message ends in a char >= 'A':
;       if value on stack < 0x300:
;         A = D (regardless of whether [[CURCHL]] changes it)
;         F = Carry set, Negative set, ... (result of CP 0x03) (regardless of whether [[CURCHL]] changes it)
;       else:
;         A = ' ' (unless [[CURCHL]] changes it when printing trailing space
;         F = Carry clear, Negative clear, ... (result of CP 0x03) (unless changed by [[CURCHL]] when printing trailing space)
;     else:
;       A = last char of message * 2 (regardless of whether [[CURCHL]] changes it)
;       F = C_FLAG | N_FLAG, ... (result of CP 0x82) (regardless of whether [[CURCHL]] changes it)
;
;   Plus any other register changes that [[CURCHL]] makes when printing the message (or trailing space) ...

po_table:
        CALL    po_search                 ; routine PO-SEARCH will set carry for
                                          ; all messages and function words.

; This entry point is jumped to from the PRINT TOKEN/UDG PATCH routine at 0x3B9F

; ------------------------------------------------------
; Print message and possibly a leading/trailing space(s)
; ------------------------------------------------------

; On entry:
;   Bit 0 of [IY+(FLAGS-C_IY)] and carry flag both clear if leading space required.
;   DE = address of a message
;   [[CURCHL]] = print routine to call
;   ... any settings that routine at [[CURCHL]] requires ...
;   16 bit value on stack:
;     if 16 bit value on stack >= 0x300 and (message ends in '$' or message ends in a char >= 'A'):
;       print trailing space
; On exit:
;   DE = value from stack
;   HL preserved
;   ... any other register changes that [[CURCHL]] makes when printing the message (or trailing space) ...
;
;   Additionally...
;
;   if message ends with '$' or message ends in a char >= 'A':
;     if value on stack < 0x300:
;       A = D
;       F = Carry set, Negative set, ... (result of CP 0x03)
;     else:
;       A = ' ' (unless [[CURCHL]] changes it when printing trailing space
;       F = Carry clear, Negative clear, ... (result of CP 0x03) (unless changed by [[CURCHL]] when printing trailing space)
;   else:
;     A = last char of message * 2
;     F = C_FLAG | N_FLAG, ... (result of CP 0x82)

po_table_1:

        JR      C,1f                      ; forward to 1: if not a command,
                                          ; '<>' etc.

        LD      A,$20                     ; prepare leading space
        BIT     0,(IY+(FLAGS-C_IY))       ; test FLAGS  - leading space if not set
        CALL    Z,po_save                 ; routine PO-SAVE to print a space
1:
        LD      A,(DE)                    ; fetch character
        AND     $7F                       ; remove any inverted bit
        CALL    po_save                   ; routine PO-SAVE to print using alternate
                                          ; set of registers.
        LD      A,(DE)                    ; re-fetch character.
        INC     DE                        ; address next
        ADD     A,A                       ; was character inverted ?
                                          ; (this also doubles character)
        JR      NC,1b                     ; back if not

        POP     DE                        ; * re-fetch trailing space flag to D (was A)
        CP      $48                       ; was last character '$' ($24*2)
        JR      Z,2f                      ; forward to consider trailing space if so.

        CP      $82                       ; was it < 'A' i.e. '#','>','=' from tokens
                                          ; or ' ','.' (from tape) or '?' from scroll
        RET     C                         ; no trailing space
2:
        LD      A,D                       ; the trailing space flag (zero if an error msg)
        CP      $03                       ; test against RND, INKEY$ and PI
                                          ; which have no parameters and
        RET     C                         ; therefore no trailing space so return.

        LD      A, ' '                    ; else continue and print a trailing space.

; ------------------------------------------------------------
; Call RST10H with alternate registers BC'/DE'/HL' switched in
; ------------------------------------------------------------
; This routine (which is part of PRINT-OUT) calls RST 10H with the alternate
; BC/DE/HL register set, which itself calls [[CURCHL]] with the alternate
; BC/DE/HL register set, so that the use of alternate register sets is
; cancelled out, and [[CURCHL]] is called with currently switched in
; AF/BC/DE/HL registers. DE and HL are preserved.
;
; On entry:
;   A = byte to print
;   [[CURCHL]] = print routine to call
;   ... any settings that routine at [[CURCHL]] requires ...
; On exit:
;   DE preserved
;   HL preserved
;   ... any other register changes that routine at [[CURCHL]] made ...

po_save:
        PUSH    DE                        ; save DE as CALL-SUB doesn't.
        EXX                               ; switch in main set

        RST     10H                       ; PRINT-A prints using this alternate set.

        EXX                               ; back to this alternate set.
        POP     DE                        ; restore initial DE.
        RET                               ; return.

; ------------
; Table search
; ------------
; This subroutine searches a message or the token table for the
; message number held in A. DE holds the address of the table.
;
; Table contains a sequence of messages with the last character
; of each message identified by having bit 7 set. First message
; is skipped over and cannot be retrieved, typically '?'+$80.
;
; On entry:
;   A = index of entry:
;         first message cannot be retrieved (typically '?'+$80)
;         0 for second message
;         1 for third message
;         ...
;   DE = address of message table
; On exit:
;   A = if entry A < 32:
;         unchanged
;       else:
;         first char of message - 'A'
;   DE = address of found message
;   F = if entry A < 32:
;         result of (entry A / CP 0x20)
;       else:
;         result of (first char of message / SUB 'A')
;
;       Therefore, N flag is always set.
;
;       Also, for the *token table*:
;         the zero flag in F is only set for entry A = 0x21 ("AND")
;         the carry and sign flags in F are *SET* for:
;           RND (A=0x00)
;           ...
;           BIN (A=0x1f)
;           <=
;           >=
;           <>
;         and *CLEAR* for:
;           OR
;           AND
;           LINE (A=0x25)
;           ...
;           COPY (A=0x5a)

po_search:
        PUSH    AF                        ; save the message/token number
        EX      DE,HL                     ; transfer DE to HL
        INC     A                         ; adjust for initial step-over byte

po_step:
        BIT     7,(HL)                    ; is character inverted ?
        INC     HL                        ; address next
        JR      Z,po_step                 ; back to PO-STEP if not inverted.

        DEC     A                         ; decrease counter
        JR      NZ,po_step                ; back to PO-STEP if not zero

        EX      DE,HL                     ; transfer address to DE
        POP     AF                        ; restore message/token number
        CP      $20                       ; return with carry set
        RET     C                         ; for all messages and function tokens

        LD      A,(DE)                    ; test first character of token
        SUB     'A'                       ; and return with carry set
        RET                               ; if it is less than 'A'
                                          ; i.e. '<>', '<=', '>='

; ---------------
; Test for scroll
; ---------------
; This test routine is called when printing carriage return, when considering
; PRINT AT and from the general PRINT ALL characters routine to test if
; scrolling is required, prompting the user if necessary.
; This is therefore using the alternate set.
;
;
; If printer in use:
;   On entry:
;     Bit 1 of FLAGS set
;   On exit:
;     F = X3_FLAG | H_FLAG
;
; If upper screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] clear
;     [DF_SZ] set to number of lines for lower screen
;     B = 24 - actual screen line (24 = top line, 23 = second line, etc)
;     C = (33 - actual column) or 0x01 for past end of line but no carriage return
;   On exit:
;     If B > [DF_SZ]:
;       A = 33 - C = actual upper screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;       D = 0
;       E = 33 - C = actual upper screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;       HL = 0x4000 + (33-C) + 32*8*8*int((24-B)/8) + 32*((24-B)%8) = display file address for upper screen position
;       F = H_FLAG|X3_FLAG|PV_FLAG|Z_FLAG
;       [S_POSN_{X,Y}] set to upper screen position (=BC)
;       [DF_CC] set to display file address of upper screen position (=HL)
;     If B == [DF_SZ]:
;       TODO (scrolling occurs)
;     If B < [DF_SZ]:
;       TODO (out of screen)
;
; If lower screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] set
;     [DF_SZ] set to number of lines for lower screen
;     B = 48 - [DF_SZ] - actual screen line (24 = top line of lower screen, 23 = second line of lower screen, etc)
;     C = (33 - actual column) or 0x01 for past end of line but no carriage return
;   On exit:
;     If B > 24-[DF_SZ]:
;       A = 33 - C = actual lower screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;       D = 0
;       E = 33 - C = actual lower screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;       HL = 0x4000 + (33-C) + 32*8*8*int((48-B-[DF_SZ])/8) + 32*((48-B-[DF_SZ])%8) = display file address for lower screen position
;       F = X3_FLAG | H_FLAG
;       [S_POSN_{X,Y}_L] set to lower screen position (=BC)
;       [ECHO_E_{X,Y}] set to lower screen position (=BC)
;       [DF_CC_L] set to display file address of lower screen position (=HL)
;     If B == 24-[DF_SZ]:
;       TODO (scrolling occurs)
;     If B < 2:
;       TODO (out of screen)
;     If B < 24-[DF_SZ]:
;       TODO (out of screen)

po_scr:
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - is printer in use ?
        RET     NZ                        ; return immediately if so.

        LD      DE,cl_set                 ; set DE to address: CL-SET
        PUSH    DE                        ; and push for return address.
        LD      A,B                       ; transfer the line to A.
        BIT     0,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG  - Lower screen in use ?
        JP      NZ,po_scr_4               ; jump forward to PO-SCR-4 if so.

        CP      (IY+(DF_SZ-C_IY))         ; greater than DF_SZ display file size ?
        JR      C,report_5                ; forward to REPORT-5 if less.
                                          ; 'Out of screen'

        RET     NZ                        ; return (via CL-SET) if greater

        BIT     4,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG  - Automatic listing ?
        JR      Z,po_scr_2                ; forward to PO-SCR-2 if not.

        LD      E,(IY+(BREG-C_IY))        ; fetch BREG - the count of scroll lines to E.
        DEC     E                         ; decrease and jump
        JR      Z,po_scr_3                ; to PO-SCR-3 if zero and scrolling required.

        LD      A,$00                     ; explicit - select channel zero.
        CALL    chan_open                 ; routine CHAN-OPEN opens it.

        LD      SP,(LISTSP)               ; set stack pointer to LIST_SP

        RES     4,(IY+(TV_FLAG-C_IY))     ; reset TV_FLAG  - signal auto listing finished.
        RET                               ; return ignoring pushed value, CL-SET
                                          ; to MAIN or EDITOR without updating
                                          ; print position                         ->

; ---


report_5:
        RST     08H                       ; ERROR-1
        DEFB    $04                       ; Error Report: Out of screen

; continue here if not an automatic listing.

po_scr_2:
        DEC     (IY+(SCR_CT-C_IY))        ; decrease SCR_CT
        JR      NZ,po_scr_3               ; forward to PO-SCR-3 to scroll display if
                                          ; result not zero.

; now produce prompt.

        LD      A,$18                     ; reset
        SUB     B                         ; the
        LD      (SCR_CT),A                ; SCR_CT scroll count
        LD      HL,(ATTR_T)               ; L=ATTR_T, H=MASK_T
        PUSH    HL                        ; save on stack
        LD      A,(P_FLAG)                ; P_FLAG
        PUSH    AF                        ; save on stack to prevent lower screen
                                          ; attributes (BORDCR etc.) being applied.
        LD      A,$FD                     ; select system channel 'K'
        CALL    chan_open                 ; routine CHAN-OPEN opens it
        XOR     A                         ; clear to address message directly
        LD      DE,scroll_message         ; make DE address: scrl-mssg
        CALL    po_msg                    ; routine PO-MSG prints to lower screen
        SET     5,(IY+(TV_FLAG-C_IY))     ; set TV_FLAG  - signal lower screen requires
                                          ; clearing
        LD      HL,FLAGS                  ; make HL address FLAGS
        SET     3,(HL)                    ; signal 'L' mode.
        RES     5,(HL)                    ; signal 'no new key'.
        EXX                               ; switch to main set.
                                          ; as calling chr input from alternative set.
        CALL    wait_key                  ; routine WAIT-KEY waits for new key
                                          ; Note. this is the right routine but the
                                          ; stream in use is unsatisfactory. From the
                                          ; choices available, it is however the best.

        EXX                               ; switch back to alternate set.
        CP      $20                       ; space is considered as BREAK
        JR      Z,report_d                ; forward to REPORT-D if so
                                          ; 'BREAK - CONT repeats'

        CP      $E2                       ; is character 'STOP' ?
        JR      Z,report_d                ; forward to REPORT-D if so

        OR      $20                       ; convert to lower-case
        CP      $6E                       ; is character 'n' ?
        JR      Z,report_d                ; forward to REPORT-D if so else scroll.

        LD      A,$FE                     ; select system channel 'S'
        CALL    chan_open                 ; routine CHAN-OPEN
        POP     AF                        ; restore original P_FLAG
        LD      (P_FLAG),A                ; and save in P_FLAG.
        POP     HL                        ; restore original ATTR_T, MASK_T
        LD      (ATTR_T),HL               ; and reset ATTR_T, MASK-T as 'scroll?' has
                                          ; been printed.

po_scr_3:
        CALL    cl_sc_all                 ; routine CL-SC-ALL to scroll whole display
        LD      B,(IY+(DF_SZ-C_IY))       ; fetch DF_SZ to B
        INC     B                         ; increase to address last line of display
        LD      C,$21                     ; set C to $21 (was $21 from above routine)
        PUSH    BC                        ; save the line and column in BC.

        CALL    cl_addr                   ; routine CL-ADDR finds display address.

        LD      A,H                       ; now find the corresponding attribute byte
        RRCA                              ; (this code sequence is used twice
        RRCA                              ; elsewhere and is a candidate for
        RRCA                              ; a subroutine.)
        AND     $03                       ;
        OR      $58                       ;
        LD      H,A                       ;

        LD      DE,attributes_file+23*32  ; start of last 'line' of attribute area
        LD      A,(DE)                    ; get attribute for last line
        LD      C,(HL)                    ; transfer to base line of upper part
        LD      B,$20                     ; there are thirty two bytes
        EX      DE,HL                     ; swap the pointers.

1:      LD      (DE),A                    ; transfer
        LD      (HL),C                    ; attributes.
        INC     DE                        ; address next.
        INC     HL                        ; address next.
        DJNZ    1b                        ; loop back to 1: for all adjacent
                                          ; attribute lines.

        POP     BC                        ; restore the line/column.
        RET                               ; return via CL-SET (was pushed on stack).

; ---

; The message 'scroll?' appears here with last byte inverted.

scroll_message:
        DEFB    $80                       ; initial step-over byte.
        DEFM    "scroll"
        DEFB    '?'+$80

report_d:
        RST     08H                       ; ERROR-1
        DEFB    $0C                       ; Error Report: BREAK - CONT repeats

; continue here if using lower display - A holds line number.

po_scr_4:
        CP      $02                       ; is line number less than 2 ?
        JR      C,report_5                ; to REPORT-5 if so
                                          ; 'Out of Screen'.

        ADD     A,(IY+(DF_SZ-C_IY))       ; add DF_SZ
        SUB     $19                       ;
        RET     NC                        ; return if scrolling unnecessary

        NEG                               ; Negate to give number of scrolls required.
        PUSH    BC                        ; save line/column
        LD      B,A                       ; count to B
        LD      HL,(ATTR_T)               ; fetch current ATTR_T, MASK_T to HL.
        PUSH    HL                        ; and save
        LD      HL,(P_FLAG)               ; fetch P_FLAG
        PUSH    HL                        ; and save.
                                          ; to prevent corruption by input AT

        CALL    temps                     ; routine TEMPS sets to BORDCR etc
        LD      A,B                       ; transfer scroll number to A.

po_scr_4a:
        PUSH    AF                        ; save scroll number.
        LD      HL,DF_SZ                  ; address DF_SZ
        LD      B,(HL)                    ; fetch old value
        LD      A,B                       ; transfer to A
        INC     A                         ; and increment
        LD      (HL),A                    ; then put back.
        LD      HL,S_POSN_Y               ; address S_POSN_hi - line
        CP      (HL)                      ; compare
        JR      C,po_scr_4b               ; forward to PO-SCR-4B if scrolling required

        INC     (HL)                      ; else increment S_POSN_hi
        LD      B,$18                     ; set count to whole display ??
                                          ; Note. should be $17 and the top line
                                          ; will be scrolled into the ROM which
                                          ; is harmless on the standard set up.

po_scr_4b:
        CALL    cl_scroll                 ; routine CL-SCROLL scrolls B lines
        POP     AF                        ; restore scroll counter.
        DEC     A                         ; decrease
        JR      NZ,po_scr_4a              ; back to to PO-SCR-4A until done

        POP     HL                        ; restore original P_FLAG.
        LD      (IY+(P_FLAG-C_IY)),L      ; and overwrite system variable P_FLAG.

        POP     HL                        ; restore original ATTR_T/MASK_T.
        LD      (ATTR_T),HL               ; and update system variables.

        LD      BC,(S_POSN_X)             ; B=[S_POSN_Y], C=[S_POSN_X]
        RES     0,(IY+(TV_FLAG-C_IY))     ; signal to TV_FLAG  - main screen in use.
        CALL    cl_set                    ; call routine CL-SET for upper display.

        SET     0,(IY+(TV_FLAG-C_IY))     ; signal to TV_FLAG  - lower screen in use.
        POP     BC                        ; restore line/column
        RET                               ; return via CL-SET for lower display.

; ----------------------
; Temporary colour items
; ----------------------
; This subroutine is called 11 times to copy the permanent colour items
; to the temporary ones.
; On entry:
; On exit:
;   A = updated [P_FLAG] (see below)
;   HL = P_FLAG
;   F = **I think**:
;     S_FLAG = bit 7 of [P_FLAG]
;     Z_FLAG is set if [P_FLAG] == 0
;     X5_FLAG = bit 5 of [P_FLAG]
;     H_FLAG is clear
;     X3_FLAG = bit 3 of [P_FLAG]
;     PV_FLAG is set if parity of [P_FLAG] even; otherwise clear
;     N_FLAG is clear
;     C_FLAG is clear
;   If bit 0 of TV_FLAG is set (lower screen in use):
;     [ATTR_T] = [BORDCR]
;     [MASK_T] = 0x00
;     [P_FLAG] = temp bits cleared
;
;   If bit 0 of TV_FLAG is clear (lower screen not in use):
;     [ATTR_T] = [ATTR_P]
;     [MASK_T] = [MASK_P]
;     [P_FLAG] = temp bits copied from perm bits


temps:
        XOR     A                         ; A=0
        LD      HL,(ATTR_P)               ; L=[ATTR_P], H=[MASK_P]
        BIT     0,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG - is lower screen in use ?
        JR      Z,1f                      ; skip to 1: if not
; lower screen in use
        LD      H,A                       ; H=0
        LD      L,(IY+(BORDCR-C_IY))      ; L=[BORDCR]
1:      LD      (ATTR_T),HL               ; [ATTR_T]=L, [MASK_T]=H
; In P_FLAG the permanent values are stored in bits 7,5,3,1; temporary values in bits 6,4,2,0.
        LD      HL,P_FLAG                 ; address P_FLAG.
        JR      NZ,2f                     ; skip to 2: if lower screen in use (A=0)
        LD      A,(HL)                    ; else pick up flag bits.
        RRCA                              ; rotate permanent bits to temporary bits.
2:      XOR     (HL)                      ;
        AND     $55                       ; BIN 01010101
        XOR     (HL)                      ; permanent now as original
        LD      (HL),A                    ; apply permanent bits to temporary bits.
        RET                               ; and return.

; ------------------
; Handle CLS command
; ------------------
; clears the display.
; if it's difficult to write it should be difficult to read.

cls:
        CALL    cl_all                    ; routine CL-ALL  clears display and
                                          ; resets attributes to permanent.
                                          ; re-attaches it to this computer.

; this routine called from INPUT, **

cls_lower:
        LD      HL,TV_FLAG                ; address System Variable TV_FLAG.
        RES     5,(HL)                    ; TV_FLAG - signal do not clear lower screen.
        SET     0,(HL)                    ; TV_FLAG - signal lower screen in use.
        CALL    temps                     ; routine TEMPS picks up temporary colours.
        LD      B,(IY+(DF_SZ-C_IY))       ; fetch lower screen DF_SZ
        CALL    cl_line                   ; routine CL-LINE clears lower part
                                          ; and sets permanent attributes.

        LD      HL,attributes_file+22*32  ; fetch attribute address leftmost cell,
                                          ; second line up.
        LD      A,(ATTR_P)                ; fetch permanent attribute from ATTR_P.
        DEC     B                         ; decrement lower screen display file size
        JR      cls_3                     ; forward to CLS-3 ->

; ---

cls_1:
        LD      C,$20                     ; set counter to 32 characters per line

cls_2:
        DEC     HL                        ; decrease attribute address.
        LD      (HL),A                    ; and place attributes in next line up.
        DEC     C                         ; decrease 32 counter.
        JR      NZ,cls_2                  ; loop back to CLS-2 until all 32 done.

cls_3:
        DJNZ    cls_1                     ; decrease B counter and back to CLS-1
                                          ; if not zero.

        LD      (IY+(DF_SZ-C_IY)),$02     ; set DF_SZ lower screen to 2

; This entry point is called from CL-ALL below to
; reset the system channel input and output addresses to normal.

; On entry:
; On exit:
;     [CURCHL] = address in CHANS block of channel K
;     [FLAGS] : clears bit 1 and bit 5 => Printer not in use and no new key
;     [FLAGS2] : sets bit 4 => Channel K in use
;     [TV_FLAG] : sets bit 0 => Lower screen in use
;     [ATTR_T] = [BORDCR]
;     [MASK_T] = 0
;     [P_FLAG] : temp bits cleared
;     [[CURCHL]] = PRINT_OUT    (Channel K output routine)
;     [[CURCHL]+8] = KEY_INPUT  (Channel K input routine)
;     [S_POSN_L] = 0x1721
;     [ECHO_E] = 0x1721
;     [DF_CC_L] = display_file + ((25-[DF_SZ])/8)*32*8*8 + 32*(25-[DF_SZ])%8)
;     A = 0
;     BC = 0x1721
;     DE = 0
;     HL = display_file + ((25-[DF_SZ])/8)*32*8*8 + 32*(25-[DF_SZ])%8)
;     F = X3_FLAG | H_FLAG

cl_chan:
        LD      A,$FD                     ; select system channel 'K'
        CALL    chan_open                 ; routine CHAN-OPEN opens it.
        LD      HL,(CURCHL)               ; fetch CURCHL to HL to address current channel
        LD      DE,print_out              ; set address to PRINT-OUT for first pass.
        AND     A                         ; clear carry for first pass.

1:      LD      (HL),E                    ; insert output address first pass.
        INC     HL                        ; or input address on second pass.
        LD      (HL),D                    ;
        INC     HL                        ;
        LD      DE,key_input              ; fetch address KEY-INPUT for second pass
        CCF                               ; complement carry flag - will set on pass 1.

        JR      C,1b                      ; back to 1: if first pass else done.

        LD      BC,$1721                  ; line 23 for lower screen
        JR      cl_set                    ; exit via CL-SET to set column
                                          ; for lower display

; ---------------------------
; Clearing whole display area
; ---------------------------
; This subroutine called from CLS, AUTO-LIST and MAIN-3
; clears 24 lines of the display and resets the relevant system variables
; and system channels.

cl_all:
        LD      HL,$0000                  ; initialize plot coordinates.
        LD      (COORDS_X),HL             ; set COORDS to 0,0.
        RES     0,(IY+(FLAGS2-C_IY))      ; update FLAGS2  - signal main screen is clear.

        CALL    cl_chan                   ; routine CL-CHAN makes channel 'K' 'normal'.

        LD      A,$FE                     ; select system channel 'S'
        CALL    chan_open                 ; routine CHAN-OPEN opens it
        CALL    temps                     ; routine TEMPS picks up permanent values.
        LD      B,$18                     ; There are 24 lines.
        CALL    cl_line                   ; routine CL-LINE clears 24 text lines
                                          ; (and sets BC to $1821)

        LD      HL,(CURCHL)               ; fetch CURCHL make HL address current
                                          ; channel 'S'
        LD      DE,print_out              ; address: PRINT-OUT
        LD      (HL),E                    ; is made
        INC     HL                        ; the normal
        LD      (HL),D                    ; output address.

        LD      (IY+(SCR_CT-C_IY)),$01    ; set SCR_CT - scroll count is set to default.
                                          ; Note. BC already contains $1821.
        LD      BC,$1821                  ; reset column and line to 0,0
                                          ; and continue into CL-SET, below, exiting
                                          ; via PO-STORE (for upper screen).

; ---------------------------
; Set line and column numbers
; ---------------------------
; This routine is used to calculate and store the display file address of the
; current cursor position for upper screen or lower screen or the printer buffer
; address, and to store the current upper screen coordinates or lower screen
; coordinates or printer x position in the appropriate system variables.
;
; If printer in use:
;   On entry:
;     Bit 1 of FLAGS set
;     C = value to store in P_POSN_X (33 for leftmost column, ... 2 for rightmost column, 1 = end of line)
;   On exit:
;     A = 33 - C = actual printer x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     D = 0
;     E = 33 - C = actual printer x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     HL = printer buffer address = 0x5b00 + (33-C)
;     F = X3_FLAG | H_FLAG
;     [P_POSN_X] set to printer position (=C)
;     [PR_CC] set to printer buffer address (=HL)
;
; If upper screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] clear
;     B = value to store in S_POSN_Y = 24 - actual upper screen row
;         => 24 for top upper screen line, 23 for second upper screen line, ...
;     C = value to store in S_POSN_X (33 for leftmost column, ... 2 for rightmost column, 1 = end of line)
;   On exit:
;     A = 33 - C = actual upper screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     D = 0
;     E = 33 - C = actual upper screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     HL = 0x4000 + (33-C) + 32*8*8*int((24-B)/8) + 32*((24-B)%8) = display file address for upper screen position
;     F = H_FLAG|X3_FLAG|PV_FLAG|Z_FLAG
;     [S_POSN_{X,Y}] set to upper screen position (=BC)
;     [DF_CC] set to display file address of upper screen position (=HL)
;
; If lower screen in use:
;   On entry:
;     Bit 1 of FLAGS clear
;     Bit 0 of [TV_FLAG] set
;     [DF_SZ] set to number of lines for lower screen
;     B = value to store in S_POSN_Y_L and ECHO_E_Y = 48 - [DF_SZ] - actual lower screen row
;         => 24 for top lower screen line, 23 for second lower screen line, ...
;     C = value to store in S_POSN_X_L and ECHO_E_X (33 for leftmost column, ... 2 for rightmost column, 1 = end of line)
;   On exit:
;     A = 33 - C = actual lower screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     D = 0
;     E = 33 - C = actual lower screen x position (0 for leftmost column, ... 31 for rightmost column, 32 = end of line)
;     HL = 0x4000 + (33-C) + 32*8*8*int((48-B-[DF_SZ])/8) + 32*((48-B-[DF_SZ])%8) = display file address for lower screen position
;     F = X3_FLAG | H_FLAG
;     [S_POSN_{X,Y}_L] set to lower screen position (=BC)
;     [ECHO_E_{X,Y}] set to lower screen position (=BC)
;     [DF_CC_L] set to display file address of lower screen position (=HL)

cl_set:
        LD      HL,PRINTER_BUFFER_48      ; the base address of printer buffer
        BIT     1,(IY+(FLAGS-C_IY))       ; test FLAGS  - is printer in use ?
        JR      NZ,2f                     ; forward to 2: if so.

        LD      A,B                       ; transfer line to A.
        BIT     0,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG  - lower screen in use ?
        JR      Z,1f                      ; skip forward to 1: if handling upper part

        ADD     A,(IY+(DF_SZ-C_IY))       ; add DF_SZ for lower screen
        SUB     $18                       ; and adjust.
1:
        PUSH    BC                        ; save the line/column.
        LD      B,A                       ; transfer line to B
                                          ; (adjusted if lower screen)
        CALL    cl_addr                   ; routine CL-ADDR calculates address at left
        POP     BC                        ; restore the line/column.

2:
        LD      A,$21                     ; the column $1-$21 is reversed
        SUB     C                         ; to range $00 - $20
        LD      E,A                       ; now transfer to DE
        LD      D,$00                     ; prepare for addition
        ADD     HL,DE                     ; and add to base address
        JP      po_store                  ; exit via PO-STORE to update relevant
                                          ; system variables.
; ----------------
; Handle scrolling
; ----------------
; The routine CL-SC-ALL is called once from PO to scroll all the display
; and from the routine CL-SCROLL, once, to scroll part of the display.

cl_sc_all:
        LD      B,$17                     ; scroll 23 lines, after 'scroll?'.

cl_scroll:
        CALL    cl_addr                   ; routine CL-ADDR gets screen address in HL.
        LD      C,$08                     ; there are 8 pixel lines to scroll.

cl_scr_1:
        PUSH    BC                        ; save counters.
        PUSH    HL                        ; and initial address.
        LD      A,B                       ; get line count.
        AND     $07                       ; will set zero if all third to be scrolled.
        LD      A,B                       ; re-fetch the line count.
        JR      NZ,cl_scr_3               ; forward to CL-SCR-3 if partial scroll.

; HL points to top line of third and must be copied to bottom of previous 3rd.
; ( so HL = display_file+(0x0000 / 0x0800 / 0x1000 )

cl_scr_2:
        EX      DE,HL                     ; copy HL to DE.
        LD      HL,$F8E0                  ; subtract $08 from H and add $E0 to L -
        ADD     HL,DE                     ; to make destination bottom line of previous
                                          ; third.
        EX      DE,HL                     ; restore the source and destination.
        LD      BC,next_char              ; thirty-two bytes are to be copied.
        DEC     A                         ; decrement the line count.
        LDIR                              ; copy a pixel line to previous third.

cl_scr_3:
        EX      DE,HL                     ; save source in DE.
        LD      HL,-32                    ; load the value -32.
        ADD     HL,DE                     ; add to form destination in HL.
        EX      DE,HL                     ; switch source and destination
        LD      B,A                       ; save the count in B.
        AND     $07                       ; mask to find count applicable to current
        RRCA                              ; third and
        RRCA                              ; multiply by
        RRCA                              ; thirty two (same as 5 RLCAs)

        LD      C,A                       ; transfer byte count to C ($E0 at most)
        LD      A,B                       ; store line count to A
        LD      B,$00                     ; make B zero
        LDIR                              ; copy bytes (BC=0, H incremented, L=0)
        LD      B,$07                     ; set B to 7, C is zero.
        ADD     HL,BC                     ; add 7 to H to address next third.
        AND     $F8                       ; has last third been done ?
        JR      NZ,cl_scr_2               ; back to CL-SCR-2 if not

        POP     HL                        ; restore topmost address.
        INC     H                         ; next pixel line down.
        POP     BC                        ; restore counts.
        DEC     C                         ; reduce pixel line count.
        JR      NZ,cl_scr_1               ; back to CL-SCR-1 if all eight not done.

        CALL    cl_attr                   ; routine CL-ATTR gets address in attributes
                                          ; from current 'ninth line', count in BC.
        LD      HL,-32                    ; set HL to the 16-bit value -32.
        ADD     HL,DE                     ; and add to form destination address.
        EX      DE,HL                     ; swap source and destination addresses.
        LDIR                              ; copy bytes scrolling the linear attributes.
        LD      B,$01                     ; continue to clear the bottom line.

; ---------------------------
; Clear text lines of display
; ---------------------------
; This subroutine, called from CL-ALL, CLS-LOWER and AUTO-LIST and above,
; clears text lines at bottom of display.
; The B register holds on entry the number of lines to be cleared 1-24.

cl_line:
        PUSH    BC                        ; save line count
        CALL    cl_addr                   ; routine CL-ADDR gets top address
        LD      C,$08                     ; there are eight screen lines to a text line.

cl_line_1:
        PUSH    BC                        ; save pixel line count
        PUSH    HL                        ; and save the address
        LD      A,B                       ; transfer the line to A (1-24).

cl_line_2:
        AND     $07                       ; mask 0-7 to consider thirds at a time
        RRCA                              ; multiply
        RRCA                              ; by 32  (same as five RLCA instructions)
        RRCA                              ; now 32 - 256(0)
        LD      C,A                       ; store result in C
        LD      A,B                       ; save line in A (1-24)
        LD      B,$00                     ; set high byte to 0, prepare for ldir.
        DEC     C                         ; decrement count 31-255.
        LD      D,H                       ; copy HL
        LD      E,L                       ; to DE.
        LD      (HL),$00                  ; blank the first byte.
        INC     DE                        ; make DE point to next byte.
        LDIR                              ; ldir will clear lines.
        LD      DE,$0701                  ; now address next third adjusting
        ADD     HL,DE                     ; register E to address left hand side
        DEC     A                         ; decrease the line count.
        AND     $F8                       ; will be 16, 8 or 0  (AND $18 will do).
        LD      B,A                       ; transfer count to B.
        JR      NZ,cl_line_2              ; back to CL-LINE-2 if 16 or 8 to do
                                          ; the next third.

        POP     HL                        ; restore start address.
        INC     H                         ; address next line down.
        POP     BC                        ; fetch counts.
        DEC     C                         ; decrement pixel line count
        JR      NZ,cl_line_1              ; back to CL-LINE-1 till all done.

        CALL    cl_attr                   ; routine CL-ATTR gets attribute address
                                          ; in DE and B * 32 in BC.
        LD      H,D                       ; transfer the address
        LD      L,E                       ; to HL.

        INC     DE                        ; make DE point to next location.

        LD      A,(ATTR_P)                ; fetch ATTR_P - permanent attributes
        BIT     0,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG  - lower screen in use ?
        JR      Z,cl_line_3               ; skip to CL-LINE-3 if not.

        LD      A,(BORDCR)                ; else lower screen uses BORDCR as attribute.

cl_line_3:
        LD      (HL),A                    ; put attribute in first byte.
        DEC     BC                        ; decrement the counter.
        LDIR                              ; copy bytes to set all attributes.
        POP     BC                        ; restore the line $01-$24.
        LD      C,$21                     ; make column $21. (No use is made of this)
        RET                               ; return to the calling routine.

; ------------------
; Attribute handling
; ------------------
; This subroutine is called from CL-LINE or CL-SCROLL with the HL register
; pointing to the 'ninth' line and H needs to be decremented before or after
; the division. Had it been done first then either present code or that used
; at the start of PO-ATTR could have been used.
; The Spectrum screen arrangement leads to the L register holding already
; the correct value for the attribute file and it is only necessary
; to manipulate H to form the correct colour attribute address.

cl_attr:
        LD      A,H                       ; fetch H to A - $48, $50, or $58.
        RRCA                              ; divide by
        RRCA                              ; eight.
        RRCA                              ; $09, $0A or $0B.
        DEC     A                         ; $08, $09 or $0A.
        OR      $50                       ; $58, $59 or $5A.
        LD      H,A                       ; save high byte of attributes.

        EX      DE,HL                     ; transfer attribute address to DE
        LD      H,C                       ; set H to zero - from last LDIR.
        LD      L,B                       ; load L with the line from B.
        ADD     HL,HL                     ; multiply
        ADD     HL,HL                     ; by
        ADD     HL,HL                     ; thirty two
        ADD     HL,HL                     ; to give count of attribute
        ADD     HL,HL                     ; cells to end of display.

        LD      B,H                       ; transfer result
        LD      C,L                       ; to register BC.

        RET                               ; and return.

; -------------------------------
; Handle display with line number
; -------------------------------
; This subroutine is called from four places to calculate the address
; of the start of a screen character line which is supplied in B.
; On entry:
;   B = 24 for top screen line, 23 for second screen line ... 1 for lowest screen line
; On exit:
;   A = 0x40 (top screen third) / 0x48 (middle screen third) / 0x50 (bottom screen third)
;   D = 24 - B
;   HL = address in display file of start of screen character line
;   F:
;     top screen third    (0x18 <= B < 0x10): none set
;     middle screen third (0x10 <= B < 0x08): PV, X3 set
;     bottom screen third (0x08 <= B < 0x00): PV set

cl_addr:
        LD      A,$18                     ; reverse the line number
        SUB     B                         ; to range $00 - $17.
        LD      D,A                       ; save line in D for later.
        RRCA                              ; multiply
        RRCA                              ; by
        RRCA                              ; thirty-two.

        AND     $E0                       ; mask off low bits to make
        LD      L,A                       ; L a multiple of 32.

        LD      A,D                       ; bring back the line to A.

        AND     $18                       ; now $00, $08 or $10.

        OR      $40                       ; add the base address of screen.

        LD      H,A                       ; HL now has the correct address.
        RET                               ; return.

; -------------------
; Handle COPY command
; -------------------
; This command copies the top 176 lines to the ZX Printer

copy:

        DI                                ; disable interrupts as this is time-critical.

        LD      B,$B0                     ; top 176 lines.

; It is popular to call this from machine code here (address 0x0eaf)
; with B holding 192 (and interrupts disabled) for a full-screen
; copy. This particularly applies to 16K Spectrums as time-critical
; machine code routines cannot be written in the first 16K of RAM as
; it is shared with the ULA which has precedence over the Z80 chip.
        LD      HL,display_file           ; address start of the display file.

; now enter a loop to handle each pixel line.

copy_1:
        PUSH    HL                        ; save the screen address.
        PUSH    BC                        ; and the line counter.

        CALL    copy_line                 ; routine COPY-LINE outputs one line.

        POP     BC                        ; restore the line counter.
        POP     HL                        ; and display address.
        INC     H                         ; next line down screen within 'thirds'.
        LD      A,H                       ; high byte to A.
        AND     $07                       ; result will be zero if we have left third.
        JR      NZ,copy_2                 ; forward to COPY-2 if not to continue loop.

        LD      A,L                       ; consider low byte first.
        ADD     A,$20                     ; increase by 32 - sets carry if back to zero.
        LD      L,A                       ; will be next group of 8.
        CCF                               ; complement - carry set if more lines in
                                          ; the previous third.
        SBC     A,A                       ; will be FF, if more, else 00.
        AND     $F8                       ; will be F8 (-8) or 00.
        ADD     A,H                       ; that is subtract 8, if more to do in third.
        LD      H,A                       ; and reset address.

copy_2:
        DJNZ    copy_1                    ; back to COPY-1 for all lines.

        JR      copy_end                  ; forward to COPY-END to switch off the printer
                                          ; motor and enable interrupts.
                                          ; Note. Nothing else required.

; ------------------------------
; Pass printer buffer to printer
; ------------------------------
; This routine is used to copy 8 pixel lines from the printer buffer
; to the ZX Printer. These text lines are mapped linearly so HL does
; not need to be adjusted at the end of each line.

copy_buff:
        DI                                ; disable interrupts
        LD      HL,PRINTER_BUFFER_48      ; the base address of the Printer Buffer.
        LD      B,$08                     ; set count to 8 lines of 32 bytes.

copy_3:
        PUSH    BC                        ; save counter.
        CALL    copy_line                 ; routine COPY-LINE outputs 32 bytes
        POP     BC                        ; restore counter.
        DJNZ    copy_3                    ; loop back to COPY-3 for all 8 lines.
                                          ; then stop motor and clear buffer.

; Note. the COPY command rejoins here, essentially to execute the next
; three instructions.

copy_end:
        LD      A,$04                     ; output value 4 to port
        OUT     ($FB),A                   ; to stop the slowed printer motor.
        EI                                ; enable interrupts.

; --------------------
; Clear Printer Buffer
; --------------------
; This routine clears an arbitrary 256 bytes of memory.
; Note. The routine seems designed to clear a buffer that follows the
; system variables.
; The routine should check a flag or HL address and simply return if COPY
; is in use.
; (T-ADDR-lo would work for the system but not if COPY called externally.)
; As a consequence of this omission the buffer will needlessly
; be cleared when COPY is used and the screen/printer position may be set to
; the start of the buffer and the line number to 0 (B)
; giving an 'Out of Screen' error.
; There seems to have been an unsuccessful attempt to circumvent the use
; of PR_CC_hi.

clear_prb:
        LD      HL,PRINTER_BUFFER_48      ; the location of the buffer.
        LD      (IY+(PR_CC-C_IY)),L       ; update PR_CC_lo - set to zero - superfluous.
        XOR     A                         ; clear the accumulator.
        LD      B,A                       ; set count to 256 bytes.

prb_bytes:
        LD      (HL),A                    ; set addressed location to zero.
        INC     HL                        ; address next byte - Note. not INC L.
        DJNZ    prb_bytes                 ; back to PRB-BYTES. repeat for 256 bytes.

        RES     1,(IY+(FLAGS2-C_IY))      ; set FLAGS2 - signal printer buffer is clear.
        LD      C,$21                     ; set the column position .
        JP      cl_set                    ; exit via CL-SET and then PO-STORE.

; -----------------
; Copy line routine
; -----------------
; This routine is called from COPY and COPY-BUFF to output a line of
; 32 bytes to the ZX Printer.
; Output to port $FB -
; bit 7 set - activate stylus.
; bit 7 low - deactivate stylus.
; bit 2 set - stops printer.
; bit 2 reset - starts printer
; bit 1 set - slows printer.
; bit 1 reset - normal speed.

copy_line:
        LD      A,B                       ; fetch the counter 1-8 or 1-176
        CP      $03                       ; is it 01 or 02 ?.
        SBC     A,A                       ; result is $FF if so else $00.
        AND     $02                       ; result is 02 now else 00.
                                          ; bit 1 set slows the printer.
        OUT     ($FB),A                   ; slow the printer for the
                                          ; last two lines.
        LD      D,A                       ; save the mask to control the printer later.

copy_l_1:
        CALL    break_key                 ; call BREAK-KEY to read keyboard immediately.
        JR      C,copy_l_2                ; forward to COPY-L-2 if 'break' not pressed.

        LD      A,$04                     ; else stop the
        OUT     ($FB),A                   ; printer motor.
        EI                                ; enable interrupts.
        CALL    clear_prb                 ; call routine CLEAR-PRB.
                                          ; Note. should not be cleared if COPY in use.

report_dc:
        RST     08H                       ; ERROR-1
        DEFB    $0C                       ; Error Report: BREAK - CONT repeats

copy_l_2:
        IN      A,($FB)                   ; test now to see if
        ADD     A,A                       ; a printer is attached.
        RET     M                         ; return if not - but continue with parent
                                          ; command.

        JR      NC,copy_l_1               ; back to COPY-L-1 if stylus of printer not
                                          ; in position.

        LD      C,$20                     ; set count to 32 bytes.

copy_l_3:
        LD      E,(HL)                    ; fetch a byte from line.
        INC     HL                        ; address next location. Note. not INC L.
        LD      B,$08                     ; count the bits.

copy_l_4:
        RL      D                         ; prepare mask to receive bit.
        RL      E                         ; rotate leftmost print bit to carry
        RR      D                         ; and back to bit 7 of D restoring bit 1

copy_l_5:
        IN      A,($FB)                   ; read the port.
        RRA                               ; bit 0 to carry.
        JR      NC,copy_l_5               ; back to COPY-L-5 if stylus not in position.

        LD      A,D                       ; transfer command bits to A.
        OUT     ($FB),A                   ; and output to port.
        DJNZ    copy_l_4                  ; loop back to COPY-L-4 for all 8 bits.

        DEC     C                         ; decrease the byte count.
        JR      NZ,copy_l_3               ; back to COPY-L-3 until 256 bits done.

        RET                               ; return to calling routine COPY/COPY-BUFF.


; ----------------------------------
; Editor routine for BASIC and INPUT
; ----------------------------------
; The editor is called to prepare or edit a BASIC line.
; It is also called from INPUT to input a numeric or string expression.
; The behaviour and options are quite different in the various modes
; and distinguished by bit 5 of FLAGX.
;
; This is a compact and highly versatile routine.

editor:
        LD      HL,(ERR_SP)               ; fetch ERR_SP
        PUSH    HL                        ; save on stack

ed_again:
        LD      HL,ed_error               ; address: ED-ERROR
        PUSH    HL                        ; save address on stack and
        LD      (ERR_SP),SP               ; make ERR_SP point to it.

; Note. While in editing/input mode should an error occur then RST 08H will
; update X_PTR to the location reached by CH_ADD and jump to ED-ERROR
; where the error will be cancelled and the loop begin again from ED-AGAIN
; above. The position of the error will be apparent when the lower screen is
; reprinted. If no error then the re-iteration is to ED-LOOP below when
; input is arriving from the keyboard.

ed_loop:
        CALL    wait_key                  ; routine WAIT-KEY gets key possibly
                                          ; changing the mode.
        PUSH    AF                        ; save key.
        LD      D,$00                     ; and give a short click based
        LD      E,(IY+(PIP-C_IY))         ; on PIP value for duration.
        LD      HL,$00C8                  ; and pitch.
        CALL    beeper                    ; routine BEEPER gives click - effective
                                          ; with rubber keyboard.
        POP     AF                        ; get saved key value.
        LD      HL,ed_loop                ; address: ED-LOOP is loaded to HL.
        PUSH    HL                        ; and pushed onto stack.

; At this point there is a looping return address on the stack, an error
; handler and an input stream set up to supply characters.
; The character that has been received can now be processed.

        CP      $18                       ; range 24 to 255 ?
        JR      NC,add_char               ; forward to ADD-CHAR if so.

        CP      $07                       ; lower than 7 ?
        JR      C,add_char                ; forward to ADD-CHAR also.
                                          ; Note. This is a 'bug' and chr$ 6, the comma
                                          ; control character, should have had an
                                          ; entry in the ED-KEYS table.
                                          ; Steven Vickers, 1984, Pitman.

        CP      $10                       ; less than 16 ?
        JR      C,ed_keys                 ; forward to ED-KEYS if editing control
                                          ; range 7 to 15 dealt with by a table

        LD      BC,$0002                  ; prepare for ink/paper etc.
        LD      D,A                       ; save character in D
        CP      $16                       ; is it ink/paper/bright etc. ?
        JR      C,ed_contr                ; forward to ED-CONTR if so

                                          ; leaves 22d AT and 23d TAB
                                          ; which can't be entered via KEY-INPUT.
                                          ; so this code is never normally executed
                                          ; when the keyboard is used for input.

        INC     BC                        ; if it was AT/TAB - 3 locations required
        BIT     7,(IY+(FLAGX-C_IY))       ; test FLAGX  - Is this INPUT LINE ?
        JP      Z,ed_ignore               ; jump to ED-IGNORE if not, else

        CALL    wait_key                  ; routine WAIT-KEY - input address is KEY-NEXT
                                          ; but is reset to KEY-INPUT
        LD      E,A                       ; save first in E

ed_contr:
        CALL    wait_key                  ; routine WAIT-KEY for control.
                                          ; input address will be key-next.

        PUSH    DE                        ; saved code/parameters
        LD      HL,(K_CUR)                ; fetch address of keyboard cursor from K_CUR
        RES     0,(IY+(MODE-C_IY))        ; set MODE to 'L'

        CALL    make_room                 ; routine MAKE-ROOM makes 2/3 spaces at cursor

        POP     BC                        ; restore code/parameters
        INC     HL                        ; address first location
        LD      (HL),B                    ; place code (ink etc.)
        INC     HL                        ; address next
        LD      (HL),C                    ; place possible parameter. If only one
                                          ; then DE points to this location also.
        JR      add_ch_1                  ; forward to ADD-CH-1

; ------------------------
; Add code to current line
; ------------------------
; this is the branch used to add normal non-control characters
; with ED-LOOP as the stacked return address.
; it is also the OUTPUT service routine for system channel 'R'.

add_char:
        RES     0,(IY+(MODE-C_IY))        ; set MODE to 'L'

        LD      HL,(K_CUR)                ; fetch address of keyboard cursor from K_CUR
        CALL    one_space                 ; routine ONE-SPACE creates one space.

; either a continuation of above or from ED-CONTR with ED-LOOP on stack.

add_ch_1:
        LD      (DE),A                    ; load current character to last new location.
        INC     DE                        ; address next
        LD      (K_CUR),DE                ; and update K_CUR system variable.
        RET                               ; return - either a simple return
                                          ; from ADD-CHAR or to ED-LOOP on stack.

; ---

; a branch of the editing loop to deal with control characters
; using a look-up table.

ed_keys:
        LD      E,A                       ; character to E.
        LD      D,$00                     ; prepare to add.
        LD      HL,ed_keys_t - 7          ; base address of editing keys table. $0F99
        ADD     HL,DE                     ; add E
        LD      E,(HL)                    ; fetch offset to E
        ADD     HL,DE                     ; add offset for address of handling routine.
        PUSH    HL                        ; push the address on machine stack.
        LD      HL,(K_CUR)                ; load address of cursor from K_CUR.
        RET                               ; an make an indirect jump forward to routine.

; ------------------
; Editing keys table
; ------------------
; For each code in the range $07 to $0F this table contains a
; single offset byte to the routine that services that code.
; Note. for what was intended there should also have been an
; entry for chr$ 6 with offset to ed-symbol.

ed_keys_t:
        DEFB    ed_edit - $               ; 07d offset $09 to Address: ED-EDIT
        DEFB    ed_left - $               ; 08d offset $66 to Address: ED-LEFT
        DEFB    ed_right - $              ; 09d offset $6A to Address: ED-RIGHT
        DEFB    ed_down - $               ; 10d offset $50 to Address: ED-DOWN
        DEFB    ed_up - $                 ; 11d offset $B5 to Address: ED-UP
        DEFB    ed_delete - $             ; 12d offset $70 to Address: ED-DELETE
        DEFB    ed_enter - $              ; 13d offset $7E to Address: ED-ENTER
        DEFB    ed_symbol - $             ; 14d offset $CF to Address: ED-SYMBOL
        DEFB    ed_graph - $              ; 15d offset $D4 to Address: ED-GRAPH

; ---------------
; Handle EDIT key
; ---------------
; The user has pressed SHIFT 1 to bring edit line down to bottom of screen.
; Alternatively the user wishes to clear the input buffer and start again.
; Alternatively ...

ed_edit:
        LD      HL,(E_PPC)                ; fetch E_PPC the last line number entered.
                                          ; Note. may not exist and may follow program.
        BIT     5,(IY+(FLAGX-C_IY))       ; test FLAGX  - input mode ?
        JP      NZ,clear_sp               ; jump forward to CLEAR-SP if not in editor.

        CALL    line_addr                 ; routine LINE-ADDR to find address of line
                                          ; or following line if it doesn't exist.
        CALL    line_no                   ; routine LINE-NO will get line number from
                                          ; address or previous line if at end-marker.
        LD      A,D                       ; if there is no program then DE will
        OR      E                         ; contain zero so test for this.
        JP      Z,clear_sp                ; jump to to CLEAR-SP if so.

; Note. at this point we have a validated line number, not just an
; approximation and it would be best to update E_PPC with the true
; cursor line value which would enable the line cursor to be suppressed
; in all situations - see shortly.

        PUSH    HL                        ; save address of line.
        INC     HL                        ; address low byte of length.
        LD      C,(HL)                    ; transfer to C
        INC     HL                        ; next to high byte
        LD      B,(HL)                    ; transfer to B.
        LD      HL,$000A                  ; an overhead of ten bytes
        ADD     HL,BC                     ; is added to length.
        LD      B,H                       ; transfer adjusted value
        LD      C,L                       ; to BC register.
        CALL    test_room                 ; routine TEST-ROOM checks free memory.
        CALL    clear_sp                  ; routine CLEAR-SP clears editing area.
        LD      HL,(CURCHL)               ; address CURCHL
        EX      (SP),HL                   ; swap with line address on stack
        PUSH    HL                        ; save line address underneath

        LD      A,$FF                     ; select system channel 'R'
        CALL    chan_open                 ; routine CHAN-OPEN opens it

        POP     HL                        ; drop line address
        DEC     HL                        ; make it point to first byte of line num.
        DEC     (IY+(E_PPC-C_IY))         ; decrease E_PPC_lo to suppress line cursor.
                                          ; Note. ineffective when E_PPC is one
                                          ; greater than last line of program perhaps
                                          ; as a result of a delete.
                                          ; credit. Paul Harrison 1982.

        CALL    out_line                  ; routine OUT-LINE outputs the BASIC line
                                          ; to the editing area.
        INC     (IY+(E_PPC-C_IY))         ; restore E_PPC_lo to the previous value.
        LD      HL,(E_LINE)               ; address E_LINE in editing area.
        INC     HL                        ; advance
        INC     HL                        ; past space
        INC     HL                        ; and digit characters
        INC     HL                        ; of line number.

        LD      (K_CUR),HL                ; update K_CUR to address start of BASIC.
        POP     HL                        ; restore the address of CURCHL.
        CALL    chan_flag                 ; routine CHAN-FLAG sets flags for it.
        RET                               ; RETURN to ED-LOOP.

; -------------------
; Cursor down editing
; -------------------
; The BASIC lines are displayed at the top of the screen and the user
; wishes to move the cursor down one line in edit mode.
; In input mode this key can be used as an alternative to entering STOP.

ed_down:
        BIT     5,(IY+(FLAGX-C_IY))       ; test FLAGX  - Input Mode ?
        JR      NZ,ed_stop                ; skip to ED-STOP if so

        LD      HL,E_PPC                  ; address E_PPC - 'current line'
        CALL    ln_fetch                  ; routine LN-FETCH fetches number of next
                                          ; line or same if at end of program.
        JR      ed_list                   ; forward to ED-LIST to produce an
                                          ; automatic listing.

; ---

ed_stop:
        LD      (IY+(ERR_NR-C_IY)),$10    ; set ERR_NR to 'STOP in INPUT' code
        JR      ed_enter                  ; forward to ED-ENTER to produce error.

; -------------------
; Cursor left editing
; -------------------
; This acts on the cursor in the lower section of the screen in both
; editing and input mode.

ed_left:
        CALL    ed_edge                   ; routine ED-EDGE moves left if possible
        JR      ed_cur                    ; forward to ED-CUR to update K-CUR
                                          ; and return to ED-LOOP.

; --------------------
; Cursor right editing
; --------------------
; This acts on the cursor in the lower screen in both editing and input
; mode and moves it to the right.

ed_right:
        LD      A,(HL)                    ; fetch addressed character.
        CP      $0D                       ; is it carriage return ?
        RET     Z                         ; return if so to ED-LOOP

        INC     HL                        ; address next character

ed_cur:
        LD      (K_CUR),HL                ; update K_CUR system variable
        RET                               ; return to ED-LOOP

; --------------
; DELETE editing
; --------------
; This acts on the lower screen and deletes the character to left of
; cursor. If control characters are present these are deleted first
; leaving the naked parameter (0-7) which appears as a '?' except in the
; case of chr$ 6 which is the comma control character. It is not mandatory
; to delete these second characters.

ed_delete:
        CALL    ed_edge                   ; routine ED-EDGE moves cursor to left.
        LD      BC,$0001                  ; of character to be deleted.
        JP      reclaim_2                 ; to RECLAIM-2 reclaim the character.

; ------------------------------------------
; Ignore next 2 codes from key-input routine
; ------------------------------------------
; Since AT and TAB cannot be entered this point is never reached
; from the keyboard. If inputting from a tape device or network then
; the control and two following characters are ignored and processing
; continues as if a carriage return had been received.
; Here, perhaps, another Spectrum has said print #15; AT 0,0; "This is yellow"
; and this one is interpreting input #15; a$.

ed_ignore:
        CALL    wait_key                  ; routine WAIT-KEY to ignore keystroke.
        CALL    wait_key                  ; routine WAIT-KEY to ignore next key.

; -------------
; Enter/newline
; -------------
; The enter key has been pressed to have BASIC line or input accepted.

ed_enter:
        POP     HL                        ; discard address ED-LOOP
        POP     HL                        ; drop address ED-ERROR

ed_end:
        POP     HL                        ; the previous value of ERR_SP
        LD      (ERR_SP),HL               ; is restored to ERR_SP system variable
        BIT     7,(IY+(ERR_NR-C_IY))      ; is ERR_NR $FF (= 'OK') ?
        RET     NZ                        ; return if so

        LD      SP,HL                     ; else put error routine on stack
        RET                               ; and make an indirect jump to it.

; -----------------------------
; Move cursor left when editing
; -----------------------------
; This routine moves the cursor left. The complication is that it must
; not position the cursor between control codes and their parameters.
; It is further complicated in that it deals with TAB and AT characters
; which are never present from the keyboard.
; The method is to advance from the beginning of the line each time,
; jumping one, two, or three characters as necessary saving the original
; position at each jump in DE. Once it arrives at the cursor then the next
; legitimate leftmost position is in DE.

ed_edge:
        SCF                               ; carry flag must be set to call the nested
        CALL    set_de                    ; subroutine SET-DE.
                                          ; if input   then DE=WORKSP
                                          ; if editing then DE=E_LINE
        SBC     HL,DE                     ; subtract address from start of line
        ADD     HL,DE                     ; and add back.
        INC     HL                        ; adjust for carry.
        POP     BC                        ; drop return address
        RET     C                         ; return to ED-LOOP if already at left
                                          ; of line.

        PUSH    BC                        ; resave return address - ED-LOOP.
        LD      B,H                       ; transfer HL - cursor address
        LD      C,L                       ; to BC register pair.
                                          ; at this point DE addresses start of line.

ed_edge_1:
        LD      H,D                       ; transfer DE - leftmost pointer
        LD      L,E                       ; to HL
        INC     HL                        ; address next leftmost character to
                                          ; advance position each time.
        LD      A,(DE)                    ; pick up previous in A
        AND     $F0                       ; lose the low bits
        CP      $10                       ; is it INK to TAB $10-$1F ?
                                          ; that is, is it followed by a parameter ?
        JR      NZ,ed_edge_2              ; to ED-EDGE-2 if not
                                          ; HL has been incremented once

        INC     HL                        ; address next as at least one parameter.

; in fact since 'tab' and 'at' cannot be entered the next section seems
; superfluous.
; The test will always fail and the jump to ED-EDGE-2 will be taken.

        LD      A,(DE)                    ; reload leftmost character
        SUB     $17                       ; decimal 23 ('tab')
        ADC     A,$00                     ; will be 0 for 'tab' and 'at'.
        JR      NZ,ed_edge_2              ; forward to ED-EDGE-2 if not
                                          ; HL has been incremented twice

        INC     HL                        ; increment a third time for 'at'/'tab'

ed_edge_2:
        AND     A                         ; prepare for true subtraction
        SBC     HL,BC                     ; subtract cursor address from pointer
        ADD     HL,BC                     ; and add back
                                          ; Note when HL matches the cursor position BC,
                                          ; there is no carry and the previous
                                          ; position is in DE.
        EX      DE,HL                     ; transfer result to DE if looping again.
                                          ; transfer DE to HL to be used as K-CUR
                                          ; if exiting loop.
        JR      C,ed_edge_1               ; back to ED-EDGE-1 if cursor not matched.

        RET                               ; return.

; -----------------
; Cursor up editing
; -----------------
; The main screen displays part of the BASIC program and the user wishes
; to move up one line scrolling if necessary.
; This has no alternative use in input mode.

ed_up:
        BIT     5,(IY+(FLAGX-C_IY))       ; test FLAGX  - input mode ?
        RET     NZ                        ; return if not in editor - to ED-LOOP.

        LD      HL,(E_PPC)                ; get current line from E_PPC
        CALL    line_addr                 ; routine LINE-ADDR gets address
        EX      DE,HL                     ; and previous in DE
        CALL    line_no                   ; routine LINE-NO gets prev line number
        LD      HL,E_PPC_hi               ; set HL to E_PPC_hi as next routine stores
                                          ; top first.
        CALL    ln_store                  ; routine LN-STORE loads DE value to HL
                                          ; high byte first - E_PPC_lo takes E

; this branch is also taken from ed-down.

ed_list:
        CALL    auto_list                 ; routine AUTO-LIST lists to upper screen
                                          ; including adjusted current line.
        LD      A,$00                     ; select lower screen again
        JP      chan_open                 ; exit via CHAN-OPEN to ED-LOOP

; --------------------------------
; Use of symbol and graphics codes
; --------------------------------
; These will not be encountered with the keyboard but would be handled
; otherwise as follows.
; As noted earlier, Vickers says there should have been an entry in
; the KEYS table for chr$ 6 which also pointed here.
; If, for simplicity, two Spectrums were both using #15 as a bi-directional
; channel connected to each other:-
; then when the other Spectrum has said PRINT #15; x, y
; input #15; i ; j  would treat the comma control as a newline and the
; control would skip to input j.
; You can get round the missing chr$ 6 handler by sending multiple print
; items separated by a newline '.

; chr$14 would have the same functionality.

; This is chr$ 14.
ed_symbol:
        BIT     7,(IY+(FLAGX-C_IY))       ; test FLAGX - is this INPUT LINE ?
        JR      Z,ed_enter                ; back to ED-ENTER if not to treat as if
                                          ; enter had been pressed.
                                          ; else continue and add code to buffer.

; Next is chr$ 15
; Note that ADD-CHAR precedes the table so we can't offset to it directly.

ed_graph:
        JP      add_char                  ; jump back to ADD-CHAR

; --------------------
; Editor error routine
; --------------------
; If an error occurs while editing, or inputting, then ERR_SP
; points to the stack location holding address ED_ERROR.

ed_error:
        BIT     4,(IY+(FLAGS2-C_IY))      ; test FLAGS2  - is K channel in use ?
        JR      Z,ed_end                  ; back to ED-END if not.

; but as long as we're editing lines or inputting from the keyboard, then
; we've run out of memory so give a short rasp.

        LD      (IY+(ERR_NR-C_IY)),$FF    ; reset ERR_NR to 'OK'.
        LD      D,$00                     ; prepare for beeper.
        LD      E,(IY+(RASP-C_IY))        ; use RASP value.
        LD      HL,p_for                  ; set a duration.
        CALL    beeper                    ; routine BEEPER emits a warning rasp.
        JP      ed_again                  ; to ED-AGAIN to re-stack address of
                                          ; this routine and make ERR_SP point to it.

; ---------------------
; Clear edit/work space
; ---------------------
; The editing area or workspace is cleared depending on context.
; This is called from ED-EDIT to clear workspace if edit key is
; used during input, to clear editing area if no program exists
; and to clear editing area prior to copying the edit line to it.
; It is also used by the error routine to clear the respective
; area depending on FLAGX.

clear_sp:
        PUSH    HL                        ; preserve HL
        CALL    set_hl                    ; routine SET-HL
                                          ; if in edit   HL = WORKSP-1, DE = E_LINE
                                          ; if in input  HL = STKBOT,   DE = WORKSP
        DEC     HL                        ; adjust
        CALL    reclaim_1                 ; routine RECLAIM-1 reclaims space
        LD      (K_CUR),HL                ; set K_CUR to start of empty area
        LD      (IY+(MODE-C_IY)),$00      ; set MODE to 'KLC'
        POP     HL                        ; restore HL.
        RET                               ; return.

; ---------------------
; Handle keyboard input
; ---------------------
; This is the service routine for the input stream of the keyboard
; channel 'K'.

key_input:
        BIT     3,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG  - has a key been pressed in
                                          ; editor ?
        CALL    NZ,ed_copy                ; routine ED-COPY if so to reprint the lower
                                          ; screen at every keystroke.
        AND     A                         ; clear carry - required exit condition.
        BIT     5,(IY+(FLAGS-C_IY))       ; test FLAGS  - has a new key been pressed ?
        RET     Z                         ; return if not.

        LD      A,(LASTK)                 ; system variable LASTK will hold last key -
                                          ; from the interrupt routine.
        RES     5,(IY+(FLAGS-C_IY))       ; update FLAGS  - reset the new key flag.
        PUSH    AF                        ; save the input character.
        BIT     5,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG  - clear lower screen ?
        CALL    NZ,cls_lower              ; routine CLS-LOWER if so.

        POP     AF                        ; restore the character code.
        CP      $20                       ; if space or higher then
        JR      NC,key_done2              ; forward to KEY-DONE2 and return with carry
                                          ; set to signal key-found.

        CP      $10                       ; with 16d INK and higher skip
        JR      NC,key_contr              ; forward to KEY-CONTR.

        CP      $06                       ; for 6 - 15d
        JR      NC,key_m_cl               ; skip forward to KEY-M-CL to handle Modes
                                          ; and CapsLock.

; that only leaves 0-5, the flash bright inverse switches.

        LD      B,A                       ; save character in B
        AND     $01                       ; isolate the embedded parameter (0/1).
        LD      C,A                       ; and store in C
        LD      A,B                       ; re-fetch copy (0-5)
        RRA                               ; halve it 0, 1 or 2.
        ADD     A,$12                     ; add 18d gives 'flash', 'bright'
                                          ; and 'inverse'.
        JR      key_data                  ; forward to KEY-DATA with the
                                          ; parameter (0/1) in C.

; ---

; Now separate capslock 06 from modes 7-15.

key_m_cl:
        JR      NZ,key_mode               ; forward to KEY-MODE if not 06 (capslock)

        LD      HL,FLAGS2                 ; point to FLAGS2
        LD      A,$08                     ; value 00000100
        XOR     (HL)                      ; toggle BIT 2 of FLAGS2 the capslock bit
        LD      (HL),A                    ; and store result in FLAGS2 again.
        JR      key_flag                  ; forward to KEY-FLAG to signal no-key.

; ---

key_mode:
        CP      $0E                       ; compare with chr 14d
        RET     C                         ; return with carry set "key found" for
                                          ; codes 7 - 13d leaving 14d and 15d
                                          ; which are converted to mode codes.

        SUB     $0D                       ; subtract 13d leaving 1 and 2
                                          ; 1 is 'E' mode, 2 is 'G' mode.
        LD      HL,MODE                   ; address the MODE system variable.
        CP      (HL)                      ; compare with existing value before
        LD      (HL),A                    ; inserting the new value.
        JR      NZ,key_flag               ; forward to KEY-FLAG if it has changed.

        LD      (HL),$00                  ; else make MODE zero - KLC mode
                                          ; Note. while in Extended/Graphics mode,
                                          ; the Extended Mode/Graphics key is pressed
                                          ; again to get out.

key_flag:
        SET     3,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - show key state has changed
        CP      A                         ; clear carry and reset zero flags -
                                          ; no actual key returned.
        RET                               ; make the return.

; ---

; now deal with colour controls - 16-23 ink, 24-31 paper

key_contr:
        LD      B,A                       ; make a copy of character.
        AND     $07                       ; mask to leave bits 0-7
        LD      C,A                       ; and store in C.
        LD      A,$10                     ; initialize to 16d - INK.
        BIT     3,B                       ; was it paper ?
        JR      NZ,key_data               ; forward to KEY-DATA with INK 16d and
                                          ; colour in C.

        INC     A                         ; else change from INK to PAPER (17d) if so.

key_data:
        LD      (IY+(K_DATA-C_IY)),C      ; put the colour (0-7)/state(0/1) in KDATA
        LD      DE,key_next               ; address: KEY-NEXT will be next input stream
        JR      key_chan                  ; forward to KEY-CHAN to change it ...

; ---

; ... so that INPUT_AD directs control to here at next call to WAIT-KEY

key_next:
        LD      A,(K_DATA)                ; pick up the parameter stored in KDATA.
        LD      DE,key_input              ; address: KEY-INPUT will be next input stream
                                          ; continue to restore default channel and
                                          ; make a return with the control code.

key_chan:
        LD      HL,(CHANS)                ; address start of CHANNELS area using CHANS
                                          ; system variable.
                                          ; Note. One might have expected CURCHL to
                                          ; have been used.
        INC     HL                        ; step over the
        INC     HL                        ; output address
        LD      (HL),E                    ; and update the input
        INC     HL                        ; routine address for
        LD      (HL),D                    ; the next call to WAIT-KEY.

key_done2:
        SCF                               ; set carry flag to show a key has been found
        RET                               ; and return.

; --------------------
; Lower screen copying
; --------------------
; This subroutine is called whenever the line in the editing area or
; input workspace is required to be printed to the lower screen.
; It is by calling this routine after any change that the cursor, for
; instance, appears to move to the left.
; Remember the edit line will contain characters and tokens
; e.g. "1000 LET a = 1" is 12 characters.

ed_copy:
        CALL    temps                     ; routine TEMPS sets temporary attributes.
        RES     3,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - signal no change in mode
        RES     5,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - signal don't clear lower
                                          ; screen.
        LD      HL,(S_POSN_X_L)           ; fetch S_POSN_{X,Y}_L
        PUSH    HL                        ; and save on stack.

        LD      HL,(ERR_SP)               ; fetch ERR_SP
        PUSH    HL                        ; and save also
        LD      HL,ed_full                ; address: ED-FULL
        PUSH    HL                        ; is pushed as the error routine
        LD      (ERR_SP),SP               ; and ERR_SP made to point to it.

        LD      HL,(ECHO_E_X)             ; fetch ECHO_E
        PUSH    HL                        ; and push also

        SCF                               ; set carry flag to control SET-DE
        CALL    set_de                    ; call routine SET-DE
                                          ; if in input DE = WORKSP
                                          ; if in edit  DE = E_LINE
        EX      DE,HL                     ; start address to HL

        CALL    out_line2                 ; routine OUT-LINE2 outputs entire line up to
                                          ; carriage return including initial
                                          ; characterized line number when present.
        EX      DE,HL                     ; transfer new address to DE
        CALL    out_curs                  ; routine OUT-CURS considers a
                                          ; terminating cursor.

        LD      HL,(S_POSN_X_L)           ; fetch updated S_POSN_{X,Y}_L
        EX      (SP),HL                   ; exchange with ECHO_E_{X,Y} on stack
        EX      DE,HL                     ; transfer ECHO_E_{X,Y} to DE
        CALL    temps                     ; routine TEMPS to re-set attributes
                                          ; if altered.

; the lower screen was not cleared, at the outset, so if deleting then old
; text from a previous print may follow this line and requires blanking.

ed_blank:
        LD      A,(S_POSN_Y_L)            ; fetch S_POSN_Y_L is current line
        SUB     D                         ; compare with old
        JR      C,ed_c_done               ; forward to ED-C-DONE if no blanking

        JR      NZ,ed_spaces              ; forward to ED-SPACES if line has changed

        LD      A,E                       ; old column to A
        SUB     (IY+(S_POSN_X_L-C_IY))    ; subtract new in S_POSN_X_L
        JR      NC,ed_c_done              ; forward to ED-C-DONE if no backfilling.

ed_spaces:
        LD      A,$20                     ; prepare a space.
        PUSH    DE                        ; save old line/column.
        CALL    print_out                 ; routine PRINT-OUT prints a space over
                                          ; any text from previous print.
                                          ; Note. Since the blanking only occurs when
                                          ; using print_out to print to the lower screen,
                                          ; there is no need to vector via a RST 10H
                                          ; and we can use this alternate set.
        POP     DE                        ; restore the old line column.
        JR      ed_blank                  ; back to ED-BLANK until all old text blanked.

; -------
; ED-FULL
; -------
; this is the error routine addressed by ERR_SP. This is not for the out of
; memory situation as we're just printing. The pitch and duration are exactly
; the same as used by ED-ERROR from which this has been augmented. The
; situation is that the lower screen is full and a rasp is given to suggest
; that this is perhaps not the best idea you've had that day.

ed_full:
        LD      D,$00                     ; prepare to moan.
        LD      E,(IY+(RASP-C_IY))        ; fetch RASP value.
        LD      HL,p_for                  ; set duration.
        CALL    beeper                    ; routine BEEPER.
        LD      (IY+(ERR_NR-C_IY)),$FF    ; clear ERR_NR.
        LD      DE,(S_POSN_X_L)           ; fetch S_POSN_{X,Y}_L.
        JR      ed_c_end                  ; forward to ED-C-END

; -------

; the exit point from line printing continues here.

ed_c_done:
        POP     DE                        ; fetch new line/column.
        POP     HL                        ; fetch the error address.

; the error path rejoins here.

ed_c_end:
        POP     HL                        ; restore the old value of ERR_SP.
        LD      (ERR_SP),HL               ; update the system variable ERR_SP
        POP     BC                        ; old value of S_POSN_{X,Y}_L
        PUSH    DE                        ; save new value
        CALL    cl_set                    ; routine CL-SET and PO-STORE
                                          ; update ECHO_E_{X,Y} and S_POSN_{X,Y}_L from BC
        POP     HL                        ; restore new value
        LD      (ECHO_E_X),HL             ; and update ECHO_E
        LD      (IY+(X_PTR_hi-C_IY)),$00  ; make error pointer X_PTR_hi out of bounds
        RET                               ; return

; -----------------------------------------------
; Point to first and last locations of work space
; -----------------------------------------------
; These two nested routines ensure that the appropriate pointers are
; selected for the editing area or workspace. The routines that call
; these routines are designed to work on either area.

; this routine is called once
set_hl:
        LD      HL,(WORKSP)               ; fetch WORKSP to HL.
        DEC     HL                        ; point to last location of editing area.
        AND     A                         ; clear carry to limit exit points to first
                                          ; or last.

; this routine is called with carry set and exits at a conditional return.

set_de:
        LD      DE,(E_LINE)               ; fetch E_LINE to DE
        BIT     5,(IY+(FLAGX-C_IY))       ; test FLAGX  - Input Mode ?
        RET     Z                         ; return now if in editing mode

        LD      DE,(WORKSP)               ; fetch WORKSP to DE
        RET     C                         ; return if carry set ( entry = set-de)

        LD      HL,(STKBOT)               ; fetch STKBOT to HL as well
        RET                               ; and return  (entry = set-hl (in input))

; -------------------------------
; Remove floating point from line
; -------------------------------
; When a BASIC LINE or the INPUT BUFFER is parsed any numbers will have
; an invisible chr 14d inserted after them and the 5-byte integer or
; floating point form inserted after that. Similar invisible value holders
; are also created after the numeric and string variables in a DEF FN list.
; This routine removes these 'compiled' numbers from the edit line or
; input workspace.

remove_fp:
        LD      A,(HL)                    ; fetch character
        CP      $0E                       ; is it the number marker ?
        LD      BC,$0006                  ; prepare for six bytes
        CALL    Z,reclaim_2               ; routine RECLAIM-2 reclaims space if $0E
        LD      A,(HL)                    ; reload next (or same) character
        INC     HL                        ; and advance address
        CP      $0D                       ; end of line or input buffer ?
        JR      NZ,remove_fp              ; back to REMOVE-FP until entire line done.

        RET                               ; return



;*********************************
;** Part 6. EXECUTIVE ROUTINES  **
;*********************************

; -------------------
; Handle NEW command
; -------------------
; The NEW command is about to set all RAM below RAMTOP to zero and
; then re-initialize the system. All RAM above RAMTOP should, and will be,
; preserved.
; There is nowhere to store values in RAM or on the stack which becomes
; inoperable. Similarly PUSH and CALL instructions cannot be used to
; store values or section common code. The alternate register set is the only
; place available to store 3 persistent 16-bit system variables.

new:
        DI                                ; disable interrupts - machine stack will be
                                          ; cleared.
        LD      A,$FF                     ; flag coming from NEW.
        LD      DE,(RAMTOP)               ; fetch RAMTOP as top value.
        EXX                               ; switch in alternate set.
        LD      BC,(P_RAMT)               ; fetch P-RAMT differs on 16K/48K machines.
        LD      DE,(RASP)                 ; fetch RASP/PIP.
        LD      HL,(UDG)                  ; fetch UDG    differs on 16K/48K machines.
        EXX                               ; switch back to main set and continue into...

; ---------------------------
; Main entry (initialization)
; ---------------------------
; This common code tests ram and sets it to zero re-initializing
; all the non-zero system variables and channel information.
; The A register tells if coming from START or NEW

start_new:
        LD      B,A                       ; save the flag for later branching.

        LD      A,$07                     ; select a white border
        OUT     ($FE),A                   ; and set it now.

        LD      A,$3F                     ; load accumulator with last page in ROM.
        LD      I,A                       ; set the I register - this remains constant
                                          ; and can't be in range $40 - $7F as 'snow'
                                          ; appears on the screen.
        NOP                               ; these seem unnecessary.
        NOP                               ;
        NOP                               ;
        NOP                               ;
        NOP                               ;
        NOP                               ;

; ------------
; Check RAM
; ------------
; Typically a Spectrum will have 16K or 48K of Ram and this code will
; test it all till it finds an unpopulated location or, less likely, a
; faulty location. Usually it stops when it reaches the top $FFFF or
; in the case of NEW the supplied top value. The entire screen turns
; black with sometimes red stripes on black paper visible.

ram_check:
        LD      H,D                       ; transfer the top value to
        LD      L,E                       ; the HL register pair.

ram_fill:
        LD      (HL),$02                  ; load with 2 - red ink on black paper
        DEC     HL                        ; next lower
        CP      H                         ; have we reached ROM - $3F ?
        JR      NZ,ram_fill               ; back to RAM-FILL if not.

ram_read:
        AND     A                         ; clear carry - prepare to subtract
        SBC     HL,DE                     ; subtract and add back setting
        ADD     HL,DE                     ; carry when back at start.
        INC     HL                        ; and increment for next iteration.
        JR      NC,ram_done               ; forward to RAM-DONE if we've got back to
                                          ; starting point with no errors.

        DEC     (HL)                      ; decrement to 1.
        JR      Z,ram_done                ; forward to RAM-DONE if faulty.

        DEC     (HL)                      ; decrement to zero.
        JR      Z,ram_read                ; back to RAM-READ if zero flag was set.

ram_done:
        DEC     HL                        ; step back to last valid location.
        EXX                               ; regardless of state, set up possibly
                                          ; stored system variables in case from NEW.
        LD      (P_RAMT),BC               ; insert P-RAMT.
        LD      (RASP),DE                 ; insert RASP/PIP.
        LD      (UDG),HL                  ; insert UDG.
        EXX                               ; switch in main set.
        INC     B                         ; now test if we arrived here from NEW.
        JR      Z,ram_set                 ; forward to RAM-SET if we did.

; this section applies to START only.

        LD      (P_RAMT),HL               ; set P-RAMT to the highest working RAM
                                          ; address.
        LD      DE,last_u_byte            ; address of last byte of 'U' bitmap in ROM.
        LD      BC,$00A8                  ; there are 21 user defined graphics.
        EX      DE,HL                     ; switch pointers and make the UDGs a
        LDDR                              ; copy of the standard characters A - U.
        EX      DE,HL                     ; switch the pointer to HL.
        INC     HL                        ; update to start of 'A' in RAM.
        LD      (UDG),HL                  ; make UDG system variable address the first
                                          ; bitmap.
        DEC     HL                        ; point at RAMTOP again.

        LD      BC,$0040                  ; set the values of
        LD      (RASP),BC                 ; the PIP and RASP system variables.

; the NEW command path rejoins here.

ram_set:
        LD      (RAMTOP),HL               ; set system variable RAMTOP to HL.

        LD      HL,char_set-32*8          ; a strange place to set the pointer to the
        LD      (CHARS),HL                ; character set, CHARS - as no printing yet.

        LD      HL,(RAMTOP)               ; fetch RAMTOP to HL again as we've lost it.

        LD      (HL),$3E                  ; top of user ram holds GOSUB end marker
                                          ; an impossible line number - see RETURN.
                                          ; no significance in the number $3E. It has
                                          ; been traditional since the ZX80.

        DEC     HL                        ; followed by empty byte (not important).
        LD      SP,HL                     ; set up the machine stack pointer.
        DEC     HL                        ;
        DEC     HL                        ;
        LD      (ERR_SP),HL               ; ERR_SP is where the error pointer is
                                          ; at moment empty - will take address MAIN-4
                                          ; at the call preceding that address,
                                          ; although interrupts and calls will make use
                                          ; of this location in meantime.

        IM      1                         ; select interrupt mode 1.
        LD      IY,ERR_NR                 ; set IY to ERR_NR. IY can reach all standard
                                          ; system variables but shadow ROM system
                                          ; variables will be mostly out of range.

        EI                                ; enable interrupts now that we have a stack.

        LD      HL,sysvars_48k_end        ; the address of the channels - initially
                                          ; following system variables.
        LD      (CHANS),HL                ; set the CHANS system variable.

        LD      DE,init_chan              ; address: init-chan in ROM.
        LD      BC,$0015                  ; there are 21 bytes of initial data in ROM.
        EX      DE,HL                     ; swap the pointers.
        LDIR                              ; copy the bytes to RAM.

        EX      DE,HL                     ; swap pointers. HL points to program area.
        DEC     HL                        ; decrement address.
        LD      (DATADD),HL               ; set DATADD to location before program area.
        INC     HL                        ; increment again.

        LD      (PROG),HL                 ; set PROG the location where BASIC starts.
        LD      (VARS),HL                 ; set VARS to same location with a
        LD      (HL),$80                  ; variables end-marker.
        INC     HL                        ; advance address.
        LD      (E_LINE),HL               ; set E_LINE, where the edit line
                                          ; will be created.
                                          ; Note. it is not strictly necessary to
                                          ; execute the next fifteen bytes of code
                                          ; as this will be done by the call to SET-MIN.
                                          ; --
        LD      (HL),$0D                  ; initially just has a carriage return
        INC     HL                        ; followed by
        LD      (HL),$80                  ; an end-marker.
        INC     HL                        ; address the next location.
        LD      (WORKSP),HL               ; set WORKSP - empty workspace.
        LD      (STKBOT),HL               ; set STKBOT - bottom of the empty stack.
        LD      (STKEND),HL               ; set STKEND to the end of the empty stack.
                                          ; --
        LD      A,$38                     ; the colour system is set to white paper,
                                          ; black ink, no flash or bright.
        LD      (ATTR_P),A                ; set ATTR_P permanent colour attributes.
        LD      (ATTR_T),A                ; set ATTR_T temporary colour attributes.
        LD      (BORDCR),A                ; set BORDCR the border colour/lower screen
                                          ; attributes.

        LD      HL,$0523                  ; The keyboard repeat and delay values
        LD      (REPDEL),HL               ; are loaded to REPDEL and REPPER.

        DEC     (IY+(KSTATE-C_IY))        ; set KSTATE-0 to $FF.
        DEC     (IY-$36)                  ; set KSTATE-4 to $FF.
                                          ; thereby marking both available.

        LD      HL,init_strm              ; set source to ROM Address: init-strm
        LD      DE,STRMS                  ; set destination to system variable STRM-FD
        LD      BC,$000E                  ; copy the 14 bytes of initial 7 streams data
        LDIR                              ; from ROM to RAM.

        SET     1,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal printer in use.
        CALL    clear_prb                 ; call routine CLEAR-PRB to initialize system
                                          ; variables associated with printer.

        LD      (IY+(DF_SZ-C_IY)),$02     ; set DF_SZ the lower screen display size to
                                          ; two lines
        CALL    cls                       ; call routine CLS to set up system
                                          ; variables associated with screen and clear
                                          ; the screen and set attributes.
        XOR     A                         ; clear accumulator so that we can address
        LD      DE,copyright - 1          ; the message table directly.
        CALL    po_msg                    ; routine PO-MSG puts
                                          ; '(c) 1982 Sinclair Research Ltd'
                                          ; at bottom of display.
        SET     5,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - signal lower screen will
                                          ; require clearing.

        JR      main_1                    ; forward to MAIN-1

; -------------------
; Main execution loop
; -------------------
;
;

main_exec:
        LD      (IY+(DF_SZ-C_IY)),$02     ; set DF_SZ lower screen display file
                                          ; size to 2 lines.
        CALL    auto_list                 ; routine AUTO-LIST

main_1:
        CALL    set_min                   ; routine SET-MIN clears work areas.

main_2:
        LD      A,$00                     ; select channel 'K' the keyboard
        CALL    chan_open                 ; routine CHAN-OPEN opens it
        CALL    editor                    ; routine EDITOR is called.
                                          ; Note the above routine is where the Spectrum
                                          ; waits for user-interaction. Perhaps the
                                          ; most common input at this stage
                                          ; is LOAD "".
        CALL    line_scan                 ; routine LINE-SCAN scans the input.
        BIT     7,(IY+(ERR_NR-C_IY))      ; test ERR_NR - will be $FF if syntax
                                          ; is correct.
        JR      NZ,main_3                 ; forward, if correct, to MAIN-3.

;

        BIT     4,(IY+(FLAGS2-C_IY))      ; test FLAGS2 - K channel in use ?
        JR      Z,main_4                  ; forward to MAIN-4 if not.

;

        LD      HL,(E_LINE)               ; an editing error so address E_LINE.
        CALL    remove_fp                 ; routine REMOVE-FP removes the hidden
                                          ; floating-point forms.
        LD      (IY+(ERR_NR-C_IY)),$FF    ; system variable ERR_NR is reset to 'OK'.
        JR      main_2                    ; back to MAIN-2 to allow user to correct.

; ---

; the branch was here if syntax has passed test.

main_3:
        LD      HL,(E_LINE)               ; fetch the edit line address from E_LINE.
        LD      (CH_ADD),HL               ; system variable CH_ADD is set to first
                                          ; character of edit line.
                                          ; Note. the above two instructions are a little
                                          ; inadequate.
                                          ; They are repeated with a subtle difference
                                          ; at the start of the next subroutine and are
                                          ; therefore not required above.

        CALL    e_line_no                 ; routine E-LINE-NO will fetch any line
                                          ; number to BC if this is a program line.

        LD      A,B                       ; test if the number of
        OR      C                         ; the line is non-zero.
        JP      NZ,main_add               ; jump forward to MAIN-ADD if so to add the
                                          ; line to the BASIC program.

; Has the user just pressed the ENTER key ?

        RST     18H                       ; GET-CHAR gets character addressed by CH_ADD.
        CP      $0D                       ; is it a carriage return ?
        JR      Z,main_exec               ; back to MAIN-EXEC if so for an automatic
                                          ; listing.

; this must be a direct command.

        BIT     0,(IY+(FLAGS2-C_IY))      ; test FLAGS2 - clear the main screen ?
        CALL    NZ,cl_all                 ; routine CL-ALL, if so, e.g. after listing.
        CALL    cls_lower                 ; routine CLS-LOWER anyway.
        LD      A,$19                     ; compute scroll count to 25 minus
        SUB     (IY+(S_POSN_Y-C_IY))      ; value of S_POSN_Y.
        LD      (SCR_CT),A                ; update SCR_CT system variable.
        SET     7,(IY+(FLAGS-C_IY))       ; update FLAGS - signal running program.
        LD      (IY+(ERR_NR-C_IY)),$FF    ; set ERR_NR to 'OK'.
        LD      (IY+(NSPPC-C_IY)),$01     ; set NSPPC to one for first statement.
        CALL    line_run                  ; call routine LINE-RUN to run the line.
                                          ; sysvar ERR_SP therefore addresses MAIN-4

; Examples of direct commands are RUN, CLS, LOAD "", PRINT USR 40000,
; LPRINT "A"; etc..
; If a user written machine-code program disables interrupts then it
; must enable them to pass the next step. We also jumped to here if the
; keyboard was not being used.

main_4:
        HALT                              ; wait for interrupt.

        RES     5,(IY+(FLAGS-C_IY))       ; update FLAGS - signal no new key.
        BIT     1,(IY+(FLAGS2-C_IY))      ; test FLAGS2 - is printer buffer clear ?
        CALL    NZ,copy_buff              ; call routine COPY-BUFF if not.
                                          ; Note. the programmer has neglected
                                          ; to set bit 1 of FLAGS first.

        LD      A,(ERR_NR)                ; fetch ERR_NR
        INC     A                         ; increment to give true code.

; Now deal with a runtime error as opposed to an editing error.
; However if the error code is now zero then the OK message will be printed.

main_g:
        PUSH    AF                        ; save the error number.

        LD      HL,$0000                  ; prepare to clear some system variables.
        LD      (IY+(FLAGX-C_IY)),H       ; clear all the bits of FLAGX.
        LD      (IY+(X_PTR_hi-C_IY)),H    ; blank X_PTR_hi to suppress error marker.
        LD      (DEFADD),HL               ; blank DEFADD to signal that no defined
                                          ; function is currently being evaluated.

        LD      HL,$0001                  ; explicit - inc hl would do.
        LD      (STRM_00),HL              ; ensure STRM-00 is keyboard.

        CALL    set_min                   ; routine SET-MIN clears workspace etc.
        RES     5,(IY+(FLAGX-C_IY))       ; update FLAGX - signal in EDIT not INPUT mode.
                                          ; Note. all the bits were reset earlier.

        CALL    cls_lower                 ; call routine CLS-LOWER.
        SET     5,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG - signal lower screen
                                          ; requires clearing.

        POP     AF                        ; bring back the error number
        LD      B,A                       ; and make a copy in B.
        CP      $0A                       ; is it a print-ready digit ?
        JR      C,main_5                  ; forward to MAIN-5 if so.

        ADD     A,$07                     ; add ASCII offset to letters.

main_5:
        CALL    out_code                  ; call routine OUT-CODE to print the code.

        LD      A,$20                     ; followed by a space.
        RST     10H                       ; PRINT-A

        LD      A,B                       ; fetch stored report code.
        LD      DE,rpt_mesgs              ; address: rpt-mesgs.
        CALL    po_msg                    ; call routine PO-MSG to print.

        CALL    print_new_error_patch     ; Spectrum 128 patch
        NOP

        CALL    po_msg                    ; routine PO-MSG prints them although it would
                                          ; be more succinct to use RST 10H.

        LD      BC,(PPC)                  ; fetch PPC the current line number.
        CALL    out_num_1                 ; routine OUT-NUM-1 will print that
        LD      A,$3A                     ; then a ':'.
        RST     10H                       ; PRINT-A

        LD      C,(IY+(SUBPPC-C_IY))      ; then SUBPPC for statement
        LD      B,$00                     ; limited to 127
        CALL    out_num_1                 ; routine OUT-NUM-1

        CALL    clear_sp                  ; routine CLEAR-SP clears editing area.
                                          ; which probably contained 'RUN'.
        LD      A,(ERR_NR)                ; fetch ERR_NR again
        INC     A                         ; test for no error originally $FF.
        JR      Z,main_9                  ; forward to MAIN-9 if no error.

        CP      $09                       ; is code Report 9 STOP ?
        JR      Z,main_6                  ; forward to MAIN-6 if so

        CP      $15                       ; is code Report L Break ?
        JR      NZ,main_7                 ; forward to MAIN-7 if not

; Stop or Break was encountered so consider CONTINUE.

main_6:
        INC     (IY+(SUBPPC-C_IY))        ; increment SUBPPC to next statement.

main_7:
        LD      BC,$0003                  ; prepare to copy 3 system variables to
        LD      DE,OSPPC                  ; address OSPPC - statement for CONTINUE.
                                          ; also updating OLDPPC line number below.

        LD      HL,NSPPC                  ; set source top to NSPPC next statement.
        BIT     7,(HL)                    ; did BREAK occur before the jump ?
                                          ; e.g. between GO TO and next statement.
        JR      Z,main_8                  ; skip forward to MAIN-8, if not, as setup
                                          ; is correct.

        ADD     HL,BC                     ; set source to SUBPPC number of current
                                          ; statement/line which will be repeated.

main_8:
        LDDR                              ; copy PPC to OLDPPC and SUBPPC to OSPCC
                                          ; or NSPPC to OLDPPC and NEWPPC to OSPCC

main_9:
        LD      (IY+(NSPPC-C_IY)),$FF     ; update NSPPC - signal 'no jump'.
        RES     3,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal use 'K' mode for
                                          ; the first character in the editor and
        JP      main_2                    ; jump back to MAIN-2.


; ----------------------
; Canned report messages
; ----------------------
; The Error reports with the last byte inverted. The first entry
; is a dummy entry. The last, which begins with $7F, the Spectrum
; character for copyright symbol, is placed here for convenience
; as is the preceding comma and space.
; The report line must accommodate a 4-digit line number and a 3-digit
; statement number which limits the length of the message text to twenty
; characters.
; e.g.  "B Integer out of range, 1000:127"

rpt_mesgs:
        DEFB    $80
        DEFB    'O','K'+$80               ; 0
        DEFM    "NEXT without FO"
        DEFB    'R'+$80                   ; 1
        DEFM    "Variable not foun"
        DEFB    'd'+$80                   ; 2
        DEFM    "Subscript wron"
        DEFB    'g'+$80                   ; 3
        DEFM    "Out of memor"
        DEFB    'y'+$80                   ; 4
        DEFM    "Out of scree"
        DEFB    'n'+$80                   ; 5
        DEFM    "Number too bi"
        DEFB    'g'+$80                   ; 6
        DEFM    "RETURN without GOSU"
        DEFB    'B'+$80                   ; 7
        DEFM    "End of fil"
        DEFB    'e'+$80                   ; 8
        DEFM    "STOP statemen"
        DEFB    't'+$80                   ; 9
        DEFM    "Invalid argumen"
        DEFB    't'+$80                   ; A
        DEFM    "Integer out of rang"
        DEFB    'e'+$80                   ; B
        DEFM    "Nonsense in BASI"
        DEFB    'C'+$80                   ; C
        DEFM    "BREAK - CONT repeat"
        DEFB    's'+$80                   ; D
        DEFM    "Out of DAT"
        DEFB    'A'+$80                   ; E
        DEFM    "Invalid file nam"
        DEFB    'e'+$80                   ; F
        DEFM    "No room for lin"
        DEFB    'e'+$80                   ; G
        DEFM    "STOP in INPU"
        DEFB    'T'+$80                   ; H
        DEFM    "FOR without NEX"
        DEFB    'T'+$80                   ; I
        DEFM    "Invalid I/O devic"
        DEFB    'e'+$80                   ; J
        DEFM    "Invalid colou"
        DEFB    'r'+$80                   ; K
        DEFM    "BREAK into progra"
        DEFB    'm'+$80                   ; L
        DEFM    "RAMTOP no goo"
        DEFB    'd'+$80                   ; M
        DEFM    "Statement los"
        DEFB    't'+$80                   ; N
        DEFM    "Invalid strea"
        DEFB    'm'+$80                   ; O
        DEFM    "FN without DE"
        DEFB    'F'+$80                   ; P
        DEFM    "Parameter erro"
        DEFB    'r'+$80                   ; Q
        DEFM    "Tape loading erro"
        DEFB    'r'+$80                   ; R
comma_sp:
        DEFB    ',',' '+$80               ; used in report line.
copyright:
        DEFB    $7F                       ; copyright
        DEFM    " 1982 Sinclair Research Lt"
        DEFB    'd'+$80


; -------------
; REPORT-G
; -------------
; Note ERR_SP points here during line entry which allows the
; normal 'Out of Memory' report to be augmented to the more
; precise 'No Room for line' report.

report_g:
; No Room for line
        LD      A,$10                     ; i.e. 'G' -$30 -$07
        LD      BC,$0000                  ; this seems unnecessary.
        JP      main_g                    ; jump back to MAIN-G

; -----------------------------
; Handle addition of BASIC line
; -----------------------------
; Note this is not a subroutine but a branch of the main execution loop.
; System variable ERR_SP still points to editing error handler.
; A new line is added to the BASIC program at the appropriate place.
; An existing line with same number is deleted first.
; Entering an existing line number deletes that line.
; Entering a non-existent line allows the subsequent line to be edited next.

main_add:
        LD      (E_PPC),BC                ; set E_PPC to extracted line number.
        LD      HL,(CH_ADD)               ; fetch CH_ADD - points to location after the
                                          ; initial digits (set in E_LINE_NO).
        EX      DE,HL                     ; save start of BASIC in DE.

        LD      HL,report_g               ; Address: REPORT-G
        PUSH    HL                        ; is pushed on stack and addressed by ERR_SP.
                                          ; the only error that can occur is
                                          ; 'Out of memory'.

        LD      HL,(WORKSP)               ; fetch WORKSP - end of line.
        SCF                               ; prepare for true subtraction.
        SBC     HL,DE                     ; find length of BASIC and
        PUSH    HL                        ; save it on stack.
        LD      H,B                       ; transfer line number
        LD      L,C                       ; to HL register.
        CALL    line_addr                 ; routine LINE-ADDR will see if
                                          ; a line with the same number exists.
        JR      NZ,main_add1              ; forward if no existing line to MAIN-ADD1.

        CALL    next_one                  ; routine NEXT-ONE finds the existing line.
        CALL    reclaim_2                 ; routine RECLAIM-2 reclaims it.

main_add1:
        POP     BC                        ; retrieve the length of the new line.
        LD      A,C                       ; and test if carriage return only
        DEC     A                         ; i.e. one byte long.
        OR      B                         ; result would be zero.
        JR      Z,main_add2               ; forward to MAIN-ADD2 is so.

        PUSH    BC                        ; save the length again.
        INC     BC                        ; adjust for inclusion
        INC     BC                        ; of line number (two bytes)
        INC     BC                        ; and line length
        INC     BC                        ; (two bytes).
        DEC     HL                        ; HL points to location before the destination

        LD      DE,(PROG)                 ; fetch the address of PROG
        PUSH    DE                        ; and save it on the stack
        CALL    make_room                 ; routine MAKE-ROOM creates BC spaces in
                                          ; program area and updates pointers.
        POP     HL                        ; restore old program pointer.
        LD      (PROG),HL                 ; and put back in PROG as it may have been
                                          ; altered by the POINTERS routine.

        POP     BC                        ; retrieve BASIC length
        PUSH    BC                        ; and save again.

        INC     DE                        ; points to end of new area.
        LD      HL,(WORKSP)               ; set HL to WORKSP - location after edit line.
        DEC     HL                        ; decrement to address end marker.
        DEC     HL                        ; decrement to address carriage return.
        LDDR                              ; copy the BASIC line back to initial command.

        LD      HL,(E_PPC)                ; fetch E_PPC - line number.
        EX      DE,HL                     ; swap it to DE, HL points to last of
                                          ; four locations.
        POP     BC                        ; retrieve length of line.
        LD      (HL),B                    ; high byte last.
        DEC     HL                        ;
        LD      (HL),C                    ; then low byte of length.
        DEC     HL                        ;
        LD      (HL),E                    ; then low byte of line number.
        DEC     HL                        ;
        LD      (HL),D                    ; then high byte range $0 - $27 (1-9999).

main_add2:
        POP     AF                        ; drop the address of Report G
        JP      main_exec                 ; and back to MAIN-EXEC producing a listing
                                          ; and to reset ERR_SP in EDITOR.


; ---------------------------
; Initial channel information
; ---------------------------
; This initial channel information is copied from ROM to RAM,
; during initialization. It's new location is after the system
; variables and is addressed by the system variable CHANS
; which means that it can slide up and down in memory.
; The table is never searched and the last character which could be anything
; other than a comma provides a convenient resting place for DATADD.

init_chan:
        DEFW    print_out                 ; PRINT-OUT
        DEFW    key_input                 ; KEY-INPUT
        DEFB    $4B                       ; 'K'
        DEFW    print_out                 ; PRINT-OUT
        DEFW    report_j                  ; REPORT-J
        DEFB    $53                       ; 'S'
        DEFW    add_char                  ; ADD-CHAR
        DEFW    report_j                  ; REPORT-J
        DEFB    $52                       ; 'R'
        DEFW    print_out                 ; PRINT-OUT
        DEFW    report_j                  ; REPORT-J
        DEFB    $50                       ; 'P'

        DEFB    $80                       ; End Marker

report_j:
        RST     08H                       ; ERROR-1
        DEFB    $12                       ; Error Report: Invalid I/O device


; -------------------
; Initial stream data
; -------------------
; This is the initial stream data for the seven streams $FD - $03 that is
; copied from ROM to the STRMS system variables area during initialization.
; There are reserved locations there for another 12 streams.
; Each location contains an offset to the second byte of a channel.
; The first byte of a channel can't be used as that would result in an
; offset of zero for some and zero is used to denote that a stream is closed.

init_strm:
        DEFB    $01, $00                  ; stream $FD offset to channel 'K'
        DEFB    $06, $00                  ; stream $FE offset to channel 'S'
        DEFB    $0B, $00                  ; stream $FF offset to channel 'R'

        DEFB    $01, $00                  ; stream $00 offset to channel 'K'
        DEFB    $01, $00                  ; stream $01 offset to channel 'K'
        DEFB    $06, $00                  ; stream $02 offset to channel 'S'
        DEFB    $10, $00                  ; stream $03 offset to channel 'P'

; ----------------------------
; Control for input subroutine
; ----------------------------
;

wait_key:
        BIT     5,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG - clear lower screen ?
        JR      NZ,wait_key1              ; forward to WAIT-KEY1 if so.

        SET     3,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG - signal reprint the edit
                                          ; line to the lower screen.

wait_key1:
        CALL    input_ad                  ; routine INPUT-AD is called.
        RET     C                         ; return with acceptable keys.

        JR      Z,wait_key1               ; back to WAIT-KEY1 if no key is pressed
                                          ; or it has been handled within INPUT-AD.

; Note. When inputting from the keyboard all characters are returned with
; above conditions so this path is never taken.

report_8:
        RST     08H                       ; ERROR-1
        DEFB    $07                       ; Error Report: End of file

; ------------------------------
; Make HL point to input address
; ------------------------------
; This routine fetches the address of the input stream from the current
; channel area using system variable CURCHL.

input_ad:
        EXX                               ; switch in alternate set.
        PUSH    HL                        ; save HL register
        LD      HL,(CURCHL)               ; fetch address of CURCHL - current channel.
        INC     HL                        ; step over output routine
        INC     HL                        ; to point to low byte of input routine.
        JR      call_sub                  ; forward to CALL-SUB.

; -------------------
; Main Output Routine
; -------------------
; The entry point OUT-CODE is called on five occasions to print
; the ASCII equivalent of a value 0-9.
;
; PRINT-A-2 is a continuation of the RST 10H to print any character.
; Both print to the current channel and the printing of control codes
; may alter that channel to divert subsequent RST 10H instructions
; to temporary routines. The normal channel is print_out.

out_code:
        LD      E,$30                     ; add 48 decimal to give ASCII
        ADD     A,E                       ; character '0' to '9'.

; On entry:
;   A = byte to print
;   [[CURCHL]] = print routine to call with [AF BC' DE' HL'] switched in
;   ... plus any settings that routine at [[CURCHL]] requires ...
; On exit:
;   DE' =
;     if [[CURCHL]] updates its DE (caller's DE'):
;       that value
;     else:
;       [CURCHL]+1
;   HL' preserved, regardless of [[CURCHL]] routine called
;   ... plus other register changes that routine [[CURCHL]] (with [AF BC' DE' HL'] switched in) makes...

print_a_2:
        EXX                               ; switch in alternate set
        PUSH    HL                        ; save HL register
        LD      HL,(CURCHL)               ; fetch CURCHL the current channel.

; input-ad rejoins here also.

call_sub:
        LD      E,(HL)                    ; put the low byte in E.
        INC     HL                        ; advance address.
        LD      D,(HL)                    ; put the high byte to D.
        EX      DE,HL                     ; transfer the stream to HL.
        CALL    call_jump                 ; use routine CALL-JUMP.
                                          ; in effect CALL (HL).

        POP     HL                        ; restore saved HL register.
        EXX                               ; switch back to the main set and
        RET                               ; return.

; ------------
; Open channel
; ------------
; This subroutine is used by the ROM to open a channel 'K', 'S', 'R', 'P' or a
; custom user channel. This is either for its own use or in response to a user's
; request, for example, when '#' is encountered with output - PRINT, LIST etc.
; or with input - INPUT, INKEY$ etc. It is entered with a system stream $FD -
; $FF, or a user stream $00 - $0F in the accumulator.
;
; On entry:
;   A = stream number (-3 to 15)
;   STRMS entry configured for given stream
;   CHANS entry configured for given stream's channel
;   If channel K, also:
;     [BORDCR] configured
;     [P_FLAG] configured
;   If channel S, also:
;     [ATTR_P] configured
;     [MASK_P] configured
;     [P_FLAG] configured
; On exit:
;   C = Channel letter ('K'/'S'/'P'/'R'/custom channel letter)
;   [CURCHL] = address in channel block of 5 byte channel entry
;   Channel K:
;     A = updated [P_FLAG] (temp bits cleared?)
;     DE = 0x06
;     HL = P_FLAG
;     F = S_FLAG|X5_FLAG
;
;     [ATTR_T] = [BORDCR]
;     [MASK_T] = 0x00
;     [P_FLAG] = temp bits cleared?
;
;     FLAGS bit 1 clear => Printer not in use
;     FLAGS bit 5 clear => No new key
;     FLAGS2 bit 4 set => K channel in use
;     TV_FLAG bit 0 set => Lower screen in use
;
;   Channel S:
;     A = updated [P_FLAG] (perm bits copied to temp bits?)
;     DE = 0x12
;     HL = P_FLAG
;     F = S_FLAG|X5_FLAG|PV_FLAG
;
;     [ATTR_T] = [ATTR_P]
;     [MASK_T] = [MASK_P]
;     [P_FLAG] = perm bits copied to temp bits?
;
;     FLAGS bit 1 clear => Printer not in use
;     FLAGS2 bit 4 clear => K channel not in use
;     TV_FLAG bit 0 clear => Lower screen not in use
;
;   Channel R / Custom channel:
;     A = 0
;     DE = entry in STRMS
;     HL = 0x1633
;     F = Z_FLAG|H_FLAG|PV_FLAG
;
;     FLAGS2 bit 4 clear => K channel not in use
;
;   Channel P:
;     A = 'P'
;     DE = 0x1b
;     HL = CHAN_P
;     F = Z_FLAG
;
;     FLAGS bit 1 set => Printer in use
;     FLAGS2 bit 4 clear => K channel not in use
;
;   Uninitialised stream (0x0000 in STRMS):
;     TODO

chan_open:
        ADD     A,A                       ; double the stream ($FF will become $FE etc.)
        ADD     A,$16                     ; add the offset to stream 0 from KSTATE
        LD      L,A                       ; result to L
        LD      H,$5C                     ; now form the address in STRMS area.
        LD      E,(HL)                    ; fetch low byte of CHANS offset
        INC     HL                        ; address next
        LD      D,(HL)                    ; fetch high byte of offset
        LD      A,D                       ; test that the stream is open.
        OR      E                         ; zero if closed.
        JR      NZ,1f                     ; forward to 1: if configured.

report_oa:
        RST     08H                       ; ERROR-1
        DEFB    $17                       ; Error Report: Invalid stream

; continue here if stream was open. Note that the offset is from CHANS
; to the second byte of the channel.

chan_op_1:
1:      DEC     DE                        ; reduce offset so it points to the channel.
        LD      HL,(CHANS)                ; fetch CHANS the location of the base of
                                          ; the channel information area
        ADD     HL,DE                     ; and add the offset to address the channel.
                                          ; and continue to set flags.

; -----------------
; Set channel flags
; -----------------
; This subroutine is used from ED-EDIT, str$ and read-in to reset the
; current channel when it has been temporarily altered.
;
; On entry:
;   HL = address in CHANS of channel to use
;   CHANS entry configured
;   If channel K, also:
;     [BORDCR] configured
;     [P_FLAG] configured
;   If channel S, also:
;     [ATTR_P] configured
;     [MASK_P] configured
;     [P_FLAG] configured
; On exit:
;   C = Channel letter ('K'/'S'/'P'/'R'/custom channel letter)
;   [CURCHL] = address in channel block (value passed in HL)
;   Channel K:
;     A = updated [P_FLAG] (temp bits cleared?)
;     DE = 0x06
;     HL = P_FLAG
;     F = S_FLAG|X5_FLAG
;
;     [ATTR_T] = [BORDCR]
;     [MASK_T] = 0x00
;     [P_FLAG] = temp bits cleared
;
;     FLAGS bit 1 clear => Printer not in use
;     FLAGS bit 5 clear => No new key
;     FLAGS2 bit 4 set => K channel in use
;     TV_FLAG bit 0 set => Lower screen in use
;
;   Channel S:
;     A = updated [P_FLAG] (perm bits copied to temp bits?)
;     DE = 0x12
;     HL = P_FLAG
;     F = S_FLAG|X5_FLAG|PV_FLAG
;
;     [ATTR_T] = [ATTR_P]
;     [MASK_T] = [MASK_P]
;     [P_FLAG] = perm bits copied to temp bits
;
;     FLAGS bit 1 clear => Printer not in use
;     FLAGS2 bit 4 clear => K channel not in use
;     TV_FLAG bit 0 clear => Lower screen not in use
;
;   Channel R / custom user channel:
;     A = 0
;     HL = 0x1633 (chn-cd-lu end table marker)
;     F = Z_FLAG|H_FLAG|PV_FLAG
;
;     FLAGS2 bit 4 clear => K channel not in use
;
;   Channel P:
;     A = 'P'
;     DE = 0x1b
;     HL = CHAN_P
;     F = Z_FLAG
;
;     FLAGS bit 1 set => Printer in use
;     FLAGS2 bit 4 clear => K channel not in use
;
;   Uninitialised stream (0x0000 in STRMS):
;     TODO

chan_flag:
        LD      (CURCHL),HL               ; set CURCHL system variable to the
                                          ; address in HL
        RES     4,(IY+(FLAGS2-C_IY))      ; update FLAGS2  - signal K channel not in use.
                                          ; Note: provides a default for channel 'R' or
                                          ; a custom user channel.
        INC     HL                        ; advance past
        INC     HL                        ; output routine.
        INC     HL                        ; advance past
        INC     HL                        ; input routine.
        LD      C,(HL)                    ; pick up the letter.
        LD      HL,chn_cd_lu              ; address: chn-cd-lu
        CALL    indexer                   ; routine INDEXER finds offset to a
                                          ; flag-setting routine.

        RET     NC                        ; but if the letter wasn't found in the
                                          ; table just return now, i.e. for channel 'R'
                                          ; or a custom user channel.
        LD      D,$00                     ; prepare to add
        LD      E,(HL)                    ; offset to E
        ADD     HL,DE                     ; add offset to location of offset to form
                                          ; address of routine

call_jump:
        JP      (HL)                      ; jump to the routine

; Footnote. calling any location that holds JP (HL) is the equivalent to
; a pseudo Z80 instruction CALL (HL). The ROM uses the instruction above.

; --------------------------
; Channel code look-up table
; --------------------------
; This table is used by the routine above to find one of the three
; flag setting routines below it.
; A zero end-marker is required as channel 'R' is not present.

chn_cd_lu:
        DEFB    'K'
        DEFB    (chan_k-$)                ; offset $06 to CHAN-K
        DEFB    'S'
        DEFB    (chan_s-$)                ; offset $12 to CHAN-S
        DEFB    'P'
        DEFB    (chan_p-$)                ; offset $1B to CHAN-P

        DEFB    $00                       ; end marker.

; --------------
; Channel K flag
; --------------
; routine to set flags for lower screen/keyboard channel.
; On entry:
; On exit:
;   A = updated [P_FLAG] (see below)
;   HL = P_FLAG
;   F = S_FLAG|X5_FLAG
;
;   FLAGS bit 1 clear => Printer not in use
;   FLAGS bit 5 clear => No new key
;   FLAGS2 bit 4 set => K channel in use
;   TV_FLAG bit 0 set => Lower screen in use
;
;   [ATTR_T] = [BORDCR]
;   [MASK_T] = 0x00
;   [P_FLAG] = temp bits cleared

chan_k:
        SET     0,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - signal lower screen in use
        RES     5,(IY+(FLAGS-C_IY))       ; update FLAGS    - signal no new key
        SET     4,(IY+(FLAGS2-C_IY))      ; update FLAGS2   - signal K channel in use
        JR      chan_s_1                  ; forward to CHAN-S-1 for indirect exit

; --------------
; Channel S flag
; --------------
; routine to set flags for upper screen channel.
; On entry:
; On exit:
;   A = updated [P_FLAG] (see below)
;   HL = P_FLAG
;   F = **I think**:
;     S_FLAG = bit 7 of [P_FLAG]
;     Z_FLAG is set if [P_FLAG] == 0
;     X5_FLAG = bit 5 of [P_FLAG]
;     H_FLAG is clear
;     X3_FLAG = bit 3 of [P_FLAG]
;     PV_FLAG is set if parity of [P_FLAG] even; otherwise clear
;     N_FLAG is clear
;     C_FLAG is clear
;
;   FLAGS bit 1 clear => Printer not in use
;   TV_FLAG bit 0 clear => Lower screen not in use
;
;   [ATTR_T] = [ATTR_P]
;   [MASK_T] = [MASK_P]
;   [P_FLAG] = temp bits copied from perm bits

chan_s:
        RES     0,(IY+(TV_FLAG-C_IY))     ; TV_FLAG  - signal main screen in use

; On entry:
; On exit:
;   A = updated [P_FLAG] (see below)
;   HL = P_FLAG
;   F = **I think**:
;     S_FLAG = bit 7 of [P_FLAG]
;     Z_FLAG is set if [P_FLAG] == 0
;     X5_FLAG = bit 5 of [P_FLAG]
;     H_FLAG is clear
;     X3_FLAG = bit 3 of [P_FLAG]
;     PV_FLAG is set if parity of [P_FLAG] even; otherwise clear
;     N_FLAG is clear
;     C_FLAG is clear
;
;   FLAGS bit 1 clear => Printer not in use
;
;   If bit 0 of TV_FLAG is set (lower screen in use):
;     [ATTR_T] = [BORDCR]
;     [MASK_T] = 0x00
;     [P_FLAG] = temp bits cleared
;
;   If bit 0 of TV_FLAG is clear (lower screen not in use):
;     [ATTR_T] = [ATTR_P]
;     [MASK_T] = [MASK_P]
;     [P_FLAG] = temp bits copied from perm bits

chan_s_1:
        RES     1,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal printer not in use
        JP      temps                     ; jump back to TEMPS and exit via that
                                          ; routine after setting temporary attributes.
; --------------
; Channel P flag
; --------------
; This routine sets a flag so that subsequent print related commands
; print to printer or update the relevant system variables.
; This status remains in force until reset by the routine above.
;
; On entry:
; On exit:
;   FLAGS bit 1 set => Printer in use

chan_p:
        SET     1,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal printer in use
        RET                               ; return

; -----------------------
; Just one space required
; -----------------------
; This routine is called once only to create a single space
; in workspace by ADD-CHAR. It is slightly quicker than using a RST 30H.
; There are several instances in the calculator where the sequence
; ld bc, 1; rst $30 could be replaced by a call to this routine but it
; only gives a saving of one byte each time.

one_space:
        LD      BC,$0001                  ; create space for a single character.

; ---------
; Make Room
; ---------
; This entry point is used to create BC spaces in various areas such as
; program area, variables area, workspace etc..
; The entire free RAM is available to each BASIC statement.
; On entry, HL addresses where the first location is to be created.
; Afterwards, HL will point to the location before this.

make_room:
        PUSH    HL                        ; save the address pointer.
        CALL    test_room                 ; routine TEST-ROOM checks if room
                                          ; exists and generates an error if not.
        POP     HL                        ; restore the address pointer.
        CALL    pointers                  ; routine POINTERS updates the
                                          ; dynamic memory location pointers.
                                          ; DE now holds the old value of STKEND.
        LD      HL,(STKEND)               ; fetch new STKEND the top destination.

        EX      DE,HL                     ; HL now addresses the top of the area to
                                          ; be moved up - old STKEND.
        LDDR                              ; the program, variables, etc are moved up.
        RET                               ; return with new area ready to be populated.
                                          ; HL points to location before new area,
                                          ; and DE to last of new locations.

; -----------------------------------------------
; Adjust pointers before making or reclaiming room
; -----------------------------------------------
; This routine is called by MAKE-ROOM to adjust upwards and by RECLAIM to
; adjust downwards the pointers within dynamic memory.
; The fourteen pointers to dynamic memory, starting with VARS and ending
; with STKEND, are updated adding BC if they are higher than the position
; in HL.
; The system variables are in no particular order except that STKEND, the first
; free location after dynamic memory must be the last encountered.

pointers:
        PUSH    AF                        ; preserve accumulator.
        PUSH    HL                        ; put pos pointer on stack.
        LD      HL,VARS                   ; address VARS the first of the
        LD      A,$0E                     ; fourteen variables to consider.

ptr_next:
        LD      E,(HL)                    ; fetch the low byte of the system variable.
        INC     HL                        ; advance address.
        LD      D,(HL)                    ; fetch high byte of the system variable.
        EX      (SP),HL                   ; swap pointer on stack with the variable
                                          ; pointer.
        AND     A                         ; prepare to subtract.
        SBC     HL,DE                     ; subtract variable address
        ADD     HL,DE                     ; and add back
        EX      (SP),HL                   ; swap pos with system variable pointer
        JR      NC,ptr_done               ; forward to PTR-DONE if var before pos

        PUSH    DE                        ; save system variable address.
        EX      DE,HL                     ; transfer to HL
        ADD     HL,BC                     ; add the offset
        EX      DE,HL                     ; back to DE
        LD      (HL),D                    ; load high byte
        DEC     HL                        ; move back
        LD      (HL),E                    ; load low byte
        INC     HL                        ; advance to high byte
        POP     DE                        ; restore old system variable address.

ptr_done:
        INC     HL                        ; address next system variable.
        DEC     A                         ; decrease counter.
        JR      NZ,ptr_next               ; back to PTR-NEXT if more.
        EX      DE,HL                     ; transfer old value of STKEND to HL.
                                          ; Note. this has always been updated.
        POP     DE                        ; pop the address of the position.

        POP     AF                        ; pop preserved accumulator.
        AND     A                         ; clear carry flag preparing to subtract.

        SBC     HL,DE                     ; subtract position from old stkend
        LD      B,H                       ; to give number of data bytes
        LD      C,L                       ; to be moved.
        INC     BC                        ; increment as we also copy byte at old STKEND.
        ADD     HL,DE                     ; recompute old stkend.
        EX      DE,HL                     ; transfer to DE.
        RET                               ; return.



; -------------------
; Collect line number
; -------------------
; This routine extracts a line number, at an address that has previously
; been found using LINE-ADDR, and it is entered at LINE-NO. If it encounters
; the program 'end-marker' then the previous line is used and if that
; should also be unacceptable then zero is used as it must be a direct
; command. The program end-marker is the variables end-marker $80, or
; if variables exist, then the first character of any variable name.

line_zero:
        DEFB    $00, $00                  ; dummy line number used for direct commands


line_no_a:
        EX      DE,HL                     ; fetch the previous line to HL and set
        LD      DE,line_zero              ; DE to LINE-ZERO should HL also fail.

; -> The Entry Point.

line_no:
        LD      A,(HL)                    ; fetch the high byte - max $2F
        AND     $C0                       ; mask off the invalid bits.
        JR      NZ,line_no_a              ; to LINE-NO-A if an end-marker.

        LD      D,(HL)                    ; reload the high byte.
        INC     HL                        ; advance address.
        LD      E,(HL)                    ; pick up the low byte.
        RET                               ; return from here.

; -------------------
; Handle reserve room
; -------------------
; This is a continuation of the restart BC-SPACES

reserve:
        LD      HL,(STKBOT)               ; STKBOT first location of calculator stack
        DEC     HL                        ; make one less than new location
        CALL    make_room                 ; routine MAKE-ROOM creates the room.
        INC     HL                        ; address the first new location
        INC     HL                        ; advance to second
        POP     BC                        ; restore old WORKSP
        LD      (WORKSP),BC               ; system variable WORKSP was perhaps
                                          ; changed by POINTERS routine.
        POP     BC                        ; restore count for return value.
        EX      DE,HL                     ; switch. DE = location after first new space
        INC     HL                        ; HL now location after new space
        RET                               ; return.

; ---------------------------
; Clear various editing areas
; ---------------------------
; This routine sets the editing area, workspace and calculator stack
; to their minimum configurations as at initialization and indeed this
; routine could have been relied on to perform that task.
; This routine uses HL only and returns with that register holding
; WORKSP/STKBOT/STKEND though no use is made of this. The routines also
; reset MEM to its usual place in the systems variable area should it
; have been relocated to a FOR-NEXT variable. The main entry point
; SET-MIN is called at the start of the MAIN-EXEC loop and prior to
; displaying an error.

set_min:
        LD      HL,(E_LINE)               ; fetch E_LINE
        LD      (HL),$0D                  ; insert carriage return
        LD      (K_CUR),HL                ; make K_CUR keyboard cursor point there.
        INC     HL                        ; next location
        LD      (HL),$80                  ; holds end-marker $80
        INC     HL                        ; next location becomes
        LD      (WORKSP),HL               ; start of WORKSP

; This entry point is used prior to input and prior to the execution,
; or parsing, of each statement.

set_work:
        LD      HL,(WORKSP)               ; fetch WORKSP value
        LD      (STKBOT),HL               ; and place in STKBOT

; This entry point is used to move the stack back to its normal place
; after temporary relocation during line entry and also from ERROR-3

set_stk:
        LD      HL,(STKBOT)               ; fetch STKBOT value
        LD      (STKEND),HL               ; and place in STKEND.

        PUSH    HL                        ; perhaps an obsolete entry point.
        LD      HL,MEMBOT                 ; normal location of MEM-0
        LD      (MEM),HL                  ; is restored to system variable MEM.
        POP     HL                        ; saved value not required.
        RET                               ; return.

; ------------------
; Reclaim edit-line?
; ------------------
; This seems to be legacy code from the ZX80/ZX81 as it is
; not used in this ROM.
; That task, in fact, is performed here by the dual-area routine CLEAR-SP.
; This routine is designed to deal with something that is known to be in the
; edit buffer and not workspace.
; On entry, HL must point to the end of the something to be deleted.

rec_edit:
        LD      DE,(E_LINE)               ; fetch start of edit line from E_LINE.
        JP      reclaim_1                 ; jump forward to RECLAIM-1.

; --------------------------
; The Table INDEXING routine
; --------------------------
; This routine is used to search two-byte hash tables for a character
; held in C, returning the address of the following offset byte.
; if it is known that the character is in the table e.g. for priorities,
; then the table requires no zero end-marker. If this is not known at the
; outset then a zero end-marker is required and carry is set to signal
; success.

indexer_1:
        INC     HL                        ; address the next pair of values.

; -> The Entry Point.

; On entry:
;   C = search key
;   HL = index table address
; On exit:
;   A = C if key found, otherwise 0
;   HL = address of value if found, otherwise address of table end marker
;   F = Carry | Zero if record found, otherwise Zero | Half-carry | Parity/Overflow

indexer:
        LD      A,(HL)                    ; fetch the first byte of pair
        AND     A                         ; is it the end-marker ?
        RET     Z                         ; return with carry clear if so.

        CP      C                         ; is it the required character ?
        INC     HL                        ; address next location.
        JR      NZ,indexer_1              ; back to INDEXER-1 if no match.

        SCF                               ; else set the carry flag.
        RET                               ; return with carry set

; --------------------------------
; The Channel and Streams Routines
; --------------------------------
; A channel is an input/output route to a hardware device
; and is identified to the system by a single letter e.g. 'K' for
; the keyboard. A channel can have an input and output route
; associated with it in which case it is bi-directional like
; the keyboard. Others like the upper screen 'S' are output
; only and the input routine usually points to a report message.
; Channels 'K' and 'S' are system channels and it would be inappropriate
; to close the associated streams so a mechanism is provided to
; re-attach them. When the re-attachment is no longer required, then
; closing these streams resets them as at initialization.
; The same also would have applied to channel 'R', the RS232 channel
; as that is used by the system. It's input stream seems to have been
; removed and it is not available to the user. However the channel could
; not be removed entirely as its output routine was used by the system.
; As a result of removing this channel, channel 'P', the printer is
; erroneously treated as a system channel.
; Ironically the tape streamer is not accessed through streams and
; channels.
; Early demonstrations of the Spectrum showed a single microdrive being
; controlled by this ROM. Adverts also said that the network and RS232
; were in this ROM. Channels 'M' and 'N' are user channels and have been
; removed successfully if, as seems vaguely possible, they existed.

; ---------------------
; Handle CLOSE# command
; ---------------------
; This command allows streams to be closed after use.
; Any temporary memory areas used by the stream would be reclaimed and
; finally flags set or reset if necessary.

close:
        CALL    str_data                  ; routine STR-DATA fetches parameter
                                          ; from calculator stack and gets the
                                          ; existing STRMS data pointer address in HL
                                          ; and stream offset from CHANS in BC.

                                          ; Note. this offset could be zero if the
                                          ; stream is already closed. A check for this
                                          ; should occur now and an error should be
                                          ; generated, for example,
                                          ; Report S 'Stream already closed'.

        CALL    close_2                   ; routine CLOSE-2 would perform any actions
                                          ; peculiar to that stream without disturbing
                                          ; data pointer to STRMS entry in HL.

        LD      BC,$0000                  ; the stream is to be blanked.
        LD      DE,$C000 + display_file-STRM_04
                                          ; the number of bytes from stream 4, STRM_04,
                                          ; to $10000
        EX      DE,HL                     ; transfer offset to HL, STRMS data pointer
                                          ; to DE.
        ADD     HL,DE                     ; add the offset to the data pointer.
        JR      C,close_1                 ; forward to CLOSE-1 if a non-system stream.
                                          ; i.e. higher than 3.

; proceed with a negative result.

        LD      BC,init_strm + 14         ; prepare the address of the byte after
                                          ; the initial stream data in ROM. (wait_key)
        ADD     HL,BC                     ; index into the data table with negative value.
        LD      C,(HL)                    ; low byte to C
        INC     HL                        ; address next.
        LD      B,(HL)                    ; high byte to B.

; and for streams 0 - 3 just enter the initial data back into the STRMS entry
; streams 0 - 2 can't be closed as they are shared by the operating system.
; -> for streams 4 - 15 then blank the entry.

close_1:
        EX      DE,HL                     ; address of stream to HL.
        LD      (HL),C                    ; place zero (or low byte).
        INC     HL                        ; next address.
        LD      (HL),B                    ; place zero (or high byte).
        RET                               ; return.

; ------------------
; CLOSE-2 Subroutine
; ------------------
; There is not much point in coming here.
; The purpose was once to find the offset to a special closing routine,
; in this ROM and within 256 bytes of the close stream look up table that
; would reclaim any buffers associated with a stream. At least one has been
; removed.

close_2:
        PUSH    HL                        ; * save address of stream data pointer
                                          ; in STRMS on the machine stack.
        LD      HL,(CHANS)                ; fetch CHANS address to HL
        ADD     HL,BC                     ; add the offset to address the second
                                          ; byte of the output routine hopefully.
        INC     HL                        ; step past
        INC     HL                        ; the input routine.
        INC     HL                        ; to address channel's letter
        LD      C,(HL)                    ; pick it up in C.
                                          ; Note. but if stream is already closed we
                                          ; get the value $10 (the byte preceding 'K').
        EX      DE,HL                     ; save the pointer to the letter in DE.
        LD      HL,cl_str_lu              ; address: cl-str-lu in ROM.
        CALL    indexer                   ; routine INDEXER uses the code to get
                                          ; the 8-bit offset from the current point to
                                          ; the address of the closing routine in ROM.
                                          ; Note. it won't find $10 there!
        LD      C,(HL)                    ; transfer the offset to C.
        LD      B,$00                     ; prepare to add.
        ADD     HL,BC                     ; add offset to point to the address of the
                                          ; routine that closes the stream.
                                          ; (and presumably removes any buffers that
                                          ; are associated with it.)
        JP      (HL)                      ; jump to that routine.

; --------------------------
; CLOSE stream look-up table
; --------------------------
; This table contains an entry for a letter found in the CHANS area.
; followed by an 8-bit displacement, from that byte's address in the
; table to the routine that performs any ancillary actions associated
; with closing the stream of that channel.
; The table doesn't require a zero end-marker as the letter has been
; picked up from a channel that has an open stream.

cl_str_lu:
        DEFB    'K'
        DEFB    close_str-$               ; offset 5 to CLOSE-STR
        DEFB    'S'
        DEFB    close_str-$               ; offset 3 to CLOSE-STR
        DEFB    'P'
        DEFB    close_str-$               ; offset 1 to CLOSE-STR


; ------------------------
; Close Stream Subroutines
; ------------------------
; The close stream routines in fact have no ancillary actions to perform
; which is not surprising with regard to 'K' and 'S'.

close_str:
        POP     HL                        ; * now just restore the stream data pointer
        RET                               ; in STRMS and return.

; -----------
; Stream data
; -----------
; This routine finds the data entry in the STRMS area for the specified
; stream which is passed on the calculator stack. It returns with HL
; pointing to this system variable and BC holding a displacement from
; the CHANS area to the second byte of the stream's channel. If BC holds
; zero, then that signifies that the stream is closed.

str_data:
        CALL    find_int1                 ; routine FIND-INT1 fetches parameter to A
        CP      $10                       ; is it less than 16d ?
        JR      C,str_data1               ; skip forward to STR-DATA1 if so.

report_ob:
        RST     08H                       ; ERROR-1
        DEFB    $17                       ; Error Report: Invalid stream

str_data1:
        ADD     A,$03                     ; add the offset for 3 system streams.
                                          ; range 00 - 15d becomes 3 - 18d.
        RLCA                              ; double as there are two bytes per
                                          ; stream - now 06 - 36d
        LD      HL,STRMS                  ; address STRMS - the start of the streams
                                          ; data area in system variables.
        LD      C,A                       ; transfer the low byte to A.
        LD      B,$00                     ; prepare to add offset.
        ADD     HL,BC                     ; add to address the data entry in STRMS.

; the data entry itself contains an offset from CHANS to the address of the
; stream

        LD      C,(HL)                    ; low byte of displacement to C.
        INC     HL                        ; address next.
        LD      B,(HL)                    ; high byte of displacement to B.
        DEC     HL                        ; step back to leave HL pointing to STRMS
                                          ; data entry.
        RET                               ; return with CHANS displacement in BC
                                          ; and address of stream data entry in HL.

; --------------------
; Handle OPEN# command
; --------------------
; Command syntax example: OPEN #5,"s"
; On entry the channel code entry is on the calculator stack with the next
; value containing the stream identifier. They have to swapped.

open:
        RST     28H                       ;; FP-CALC    ;s,c.
        DEFB    $01                       ;;exchange    ;c,s.
        DEFB    $38                       ;;end-calc

        CALL    str_data                  ; routine STR-DATA fetches the stream off
                                          ; the stack and returns with the CHANS
                                          ; displacement in BC and HL addressing
                                          ; the STRMS data entry.
        LD      A,B                       ; test for zero which
        OR      C                         ; indicates the stream is closed.
        JR      Z,open_1                  ; skip forward to OPEN-1 if so.

; if it is a system channel then it can re-attached.

        EX      DE,HL                     ; save STRMS address in DE.
        LD      HL,(CHANS)                ; fetch CHANS.
        ADD     HL,BC                     ; add the offset to address the second
                                          ; byte of the channel.
        INC     HL                        ; skip over the
        INC     HL                        ; input routine.
        INC     HL                        ; and address the letter.
        LD      A,(HL)                    ; pick up the letter.
        EX      DE,HL                     ; save letter pointer and bring back
                                          ; the STRMS pointer.

        CP      $4B                       ; is it 'K' ?
        JR      Z,open_1                  ; forward to OPEN-1 if so

        CP      $53                       ; is it 'S' ?
        JR      Z,open_1                  ; forward to OPEN-1 if so

        CP      $50                       ; is it 'P' ?
        JR      NZ,report_ob              ; back to REPORT-Ob if not.
                                          ; to report 'Invalid stream'.

; continue if one of the upper-case letters was found.
; and rejoin here from above if stream was closed.

open_1:
        CALL    open_2                    ; routine OPEN-2 opens the stream.

; it now remains to update the STRMS variable.

        LD      (HL),E                    ; insert or overwrite the low byte.
        INC     HL                        ; address high byte in STRMS.
        LD      (HL),D                    ; insert or overwrite the high byte.
        RET                               ; return.

; -----------------
; OPEN-2 Subroutine
; -----------------
; There is some point in coming here as, as well as once creating buffers,
; this routine also sets flags.

open_2:
        PUSH    HL                        ; * save the STRMS data entry pointer.
        CALL    stk_fetch                 ; routine STK-FETCH now fetches the
                                          ; parameters of the channel string.
                                          ; start in DE, length in BC.

        LD      A,B                       ; test that it is not
        OR      C                         ; the null string.
        JR      NZ,open_3                 ; skip forward to OPEN-3 with 1 character
                                          ; or more!

report_fb:
        RST     08H                       ; ERROR-1
        DEFB    $0E                       ; Error Report: Invalid file name

open_3:
        PUSH    BC                        ; save the length of the string.
        LD      A,(DE)                    ; pick up the first character.
                                          ; Note. if the second character is used to
                                          ; distinguish between a binary or text
                                          ; channel then it will be simply a matter
                                          ; of setting bit 7 of FLAGX.
        AND     $DF                       ; make it upper-case.
        LD      C,A                       ; place it in C.
        LD      HL,op_str_lu              ; address: op-str-lu is loaded.
        CALL    indexer                   ; routine INDEXER will search for letter.
        JR      NC,report_fb              ; back to REPORT-F if not found
                                          ; 'Invalid filename'

        LD      C,(HL)                    ; fetch the displacement to opening routine.
        LD      B,$00                     ; prepare to add.
        ADD     HL,BC                     ; now form address of opening routine.
        POP     BC                        ; restore the length of string.
        JP      (HL)                      ; now jump forward to the relevant routine.

; -------------------------
; OPEN stream look-up table
; -------------------------
; The open stream look-up table consists of matched pairs.
; The channel letter is followed by an 8-bit displacement to the
; associated stream-opening routine in this ROM.
; The table requires a zero end-marker as the letter has been
; provided by the user and not the operating system.

op_str_lu:
        DEFB    'K'
        DEFB    open_k-$                  ; $06 offset to OPEN-K
        DEFB    'S'
        DEFB    open_s-$                  ; $08 offset to OPEN-S
        DEFB    'P'
        DEFB    open_p-$                  ; $0A offset to OPEN-P

        DEFB    $00                       ; end-marker.

; ----------------------------
; The Stream Opening Routines.
; ----------------------------
; These routines would have opened any buffers associated with the stream
; before jumping forward to to OPEN-END with the displacement value in E
; and perhaps a modified value in BC. The strange pathing does seem to
; provide for flexibility in this respect.
;
; There is no need to open the printer buffer as it is there already
; even if you are still saving up for a ZX Printer or have moved onto
; something bigger. In any case it would have to be created after
; the system variables but apart from that it is a simple task
; and all but one of the ROM routines can handle a buffer in that position.
; (PR-ALL-6 would require an extra 3 bytes of code).
; However it wouldn't be wise to have two streams attached to the ZX Printer
; as you can now, so one assumes that if PR_CC_hi was non-zero then
; the OPEN-P routine would have refused to attach a stream if another
; stream was attached.

; Something of significance is being passed to these ghost routines in the
; second character. Strings 'RB', 'RT' perhaps or a drive/station number.
; The routine would have to deal with that and exit to OPEN_END with BC
; containing $0001 or more likely there would be an exit within the routine.
; Anyway doesn't matter, these routines are long gone.

; -----------------
; OPEN-K Subroutine
; -----------------
; Open Keyboard stream.

open_k:
        LD      E,$01                     ; 01 is offset to second byte of channel 'K'.
        JR      open_end                  ; forward to OPEN-END

; -----------------
; OPEN-S Subroutine
; -----------------
; Open Screen stream.

open_s:
        LD      E,$06                     ; 06 is offset to 2nd byte of channel 'S'
        JR      open_end                  ; to OPEN-END

; -----------------
; OPEN-P Subroutine
; -----------------
; Open Printer stream.

open_p:
        LD      E,$10                     ; 16d is offset to 2nd byte of channel 'P'

open_end:
        DEC     BC                        ; the stored length of 'K','S','P' or
                                          ; whatever is now tested. ??
        LD      A,B                       ; test now if initial or residual length
        OR      C                         ; is one character.
        JR      NZ,report_fb              ; to REPORT-Fb 'Invalid file name' if not.

        LD      D,A                       ; load D with zero to form the displacement
                                          ; in the DE register.
        POP     HL                        ; * restore the saved STRMS pointer.
        RET                               ; return to update STRMS entry thereby
                                          ; signaling stream is open.

; ----------------------------------------
; Handle CAT, ERASE, FORMAT, MOVE commands
; ----------------------------------------
; These just generate an error report as the ROM is 'incomplete'.
;
; Luckily this provides a mechanism for extending these in a shadow ROM
; but without the powerful mechanisms set up in this ROM.
; An instruction fetch on error_1 may page in a peripheral ROM,
; e.g. the Sinclair Interface 1 ROM, to handle these commands.
; However that wasn't the plan.
; Development of this ROM continued for another three months until the cost
; of replacing it and the manual became unfeasible.
; The ultimate power of channels and streams died at birth.

cat_etc:
        JR      report_ob                 ; to REPORT-Ob

; -----------------
; Perform AUTO-LIST
; -----------------
; This produces an automatic listing in the upper screen.

auto_list:
        LD      (LISTSP),SP               ; save stack pointer in LIST_SP
        LD      (IY+(TV_FLAG-C_IY)),$10   ; update TV_FLAG set bit 3
        CALL    cl_all                    ; routine CL-ALL.
        SET     0,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - signal lower screen in use

        LD      B,(IY+(DF_SZ-C_IY))       ; fetch DF_SZ to B.
        CALL    cl_line                   ; routine CL-LINE clears lower display
                                          ; preserving B.
        RES     0,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - signal main screen in use
        SET     0,(IY+(FLAGS2-C_IY))      ; update FLAGS2  - signal unnecessary to
                                          ; clear main screen.
        LD      HL,(E_PPC)                ; fetch E_PPC current edit line to HL.
        LD      DE,(S_TOP)                ; fetch S_TOP to DE, the current top line
                                          ; (initially zero)
        AND     A                         ; prepare for true subtraction.
        SBC     HL,DE                     ; subtract and
        ADD     HL,DE                     ; add back.
        JR      C,auto_l_2                ; to AUTO-L-2 if S_TOP higher than E_PPC
                                          ; to set S_TOP to E_PPC

        PUSH    DE                        ; save the top line number.
        CALL    line_addr                 ; routine LINE-ADDR gets address of E_PPC.
        LD      DE,$02C0                  ; prepare known number of characters in
                                          ; the default upper screen.
        EX      DE,HL                     ; offset to HL, program address to DE.
        SBC     HL,DE                     ; subtract high value from low to obtain
                                          ; negated result used in addition.
        EX      (SP),HL                   ; swap result with top line number on stack.
        CALL    line_addr                 ; routine LINE-ADDR  gets address of that
                                          ; top line in HL and next line in DE.
        POP     BC                        ; restore the result to balance stack.

auto_l_1:
        PUSH    BC                        ; save the result.
        CALL    next_one                  ; routine NEXT-ONE gets address in HL of
                                          ; line after auto-line (in DE).
        POP     BC                        ; restore result.
        ADD     HL,BC                     ; compute back.
        JR      C,auto_l_3                ; to AUTO-L-3 if line 'should' appear

        EX      DE,HL                     ; address of next line to HL.
        LD      D,(HL)                    ; get line
        INC     HL                        ; number
        LD      E,(HL)                    ; in DE.
        DEC     HL                        ; adjust back to start.
        LD      (S_TOP),DE                ; update S_TOP.
        JR      auto_l_1                  ; to AUTO-L-1 until estimate reached.

; ---

; the jump was to here if S_TOP was greater than E_PPC

auto_l_2:
        LD      (S_TOP),HL                ; make S_TOP the same as E_PPC.

; continue here with valid starting point from above or good estimate
; from computation

auto_l_3:
        LD      HL,(S_TOP)                ; fetch S_TOP line number to HL.
        CALL    line_addr                 ; routine LINE-ADDR gets address in HL.
                                          ; address of next in DE.
        JR      Z,auto_l_4                ; to AUTO-L-4 if line exists.

        EX      DE,HL                     ; else use address of next line.

auto_l_4:
        CALL    list_all                  ; routine LIST-ALL                >>>

; The return will be to here if no scrolling occurred

        RES     4,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG  - signal no auto listing.
        RET                               ; return.

; ------------
; Handle LLIST
; ------------
; A short form of LIST #3. The listing goes to stream 3 - default printer.

llist:
        LD      A,$03                     ; the usual stream for ZX Printer
        JR      list_1                    ; forward to LIST-1

; -----------
; Handle LIST
; -----------
; List to any stream.
; Note. While a starting line can be specified it is
; not possible to specify an end line.
; Just listing a line makes it the current edit line.

list:
        LD      A,$02                     ; default is stream 2 - the upper screen.

list_1:
        LD      (IY+(TV_FLAG-C_IY)),$00   ; the TV_FLAG is initialized with bit 0 reset
                                          ; indicating upper screen in use.
        CALL    syntax_z                  ; routine SYNTAX-Z - checking syntax ?
        CALL    NZ,chan_open              ; routine CHAN-OPEN if in run-time.

        RST     18H                       ; GET-CHAR
        CALL    str_alter                 ; routine STR-ALTER will alter if '#'.
        JR      C,list_4                  ; forward to LIST-4 not a '#' .


        RST     18H                       ; GET-CHAR
        CP      $3B                       ; is it ';' ?
        JR      Z,list_2                  ; skip to LIST-2 if so.

        CP      $2C                       ; is it ',' ?
        JR      NZ,list_3                 ; forward to LIST-3 if neither separator.

; we have, say,  LIST #15, and a number must follow the separator.

list_2:
        RST     20H                       ; NEXT-CHAR
        CALL    expt_1num                 ; routine EXPT-1NUM
        JR      list_5                    ; forward to LIST-5

; ---

; the branch was here with just LIST #3 etc.

list_3:
        CALL    use_zero                  ; routine USE-ZERO
        JR      list_5                    ; forward to LIST-5

; ---

; the branch was here with LIST

list_4:
        CALL    fetch_num                 ; routine FETCH-NUM checks if a number
                                          ; follows else uses zero.

list_5:
        CALL    check_end                 ; routine CHECK-END quits if syntax OK >>>

        CALL    find_int2                 ; routine FIND-INT2 fetches the number
                                          ; from the calculator stack in run-time.
        LD      A,B                       ; fetch high byte of line number and
        AND     $3F                       ; make less than $40 so that NEXT-ONE
                                          ; (from LINE-ADDR) doesn't lose context.
                                          ; Note. this is not satisfactory and the typo
                                          ; LIST 20000 will list an entirely different
                                          ; section than LIST 2000. Such typos are not
                                          ; available for checking if they are direct
                                          ; commands.

        LD      H,A                       ; transfer the modified
        LD      L,C                       ; line number to HL.
        LD      (E_PPC),HL                ; update E_PPC to new line number.
        CALL    line_addr                 ; routine LINE-ADDR gets the address of the
                                          ; line.

; This routine is called from AUTO-LIST

list_all:
        LD      E,$01                     ; signal current line not yet printed

list_all_2:
        CALL    out_line                  ; routine OUT-LINE outputs a BASIC line
                                          ; using PRINT-OUT and makes an early return
                                          ; when no more lines to print. >>>

        RST     10H                       ; PRINT-A prints the carriage return (in A)

        BIT     4,(IY+(TV_FLAG-C_IY))     ; test TV_FLAG  - automatic listing ?
        JR      Z,list_all_2              ; back to LIST-ALL-2 if not
                                          ; (loop exit is via OUT-LINE)

; continue here if an automatic listing required.

        LD      A,(DF_SZ)                 ; fetch DF_SZ lower display file size.
        SUB     (IY+(S_POSN_Y-C_IY))      ; A=[DF_SZ]-[S_POSN_Y]
        JR      NZ,list_all_2             ; back to LIST-ALL-2 if upper screen not full.

        XOR     E                         ; A contains zero, E contains one if the
                                          ; current edit line has not been printed
                                          ; or zero if it has (from OUT-LINE).
        RET     Z                         ; return if the screen is full and the line
                                          ; has been printed.

; continue with automatic listings if the screen is full and the current
; edit line is missing. OUT-LINE will scroll automatically.

        PUSH    HL                        ; save the pointer address.
        PUSH    DE                        ; save the E flag.
        LD      HL,S_TOP                  ; fetch S_TOP the rough estimate.
        CALL    ln_fetch                  ; routine LN-FETCH updates S_TOP with
                                          ; the number of the next line.
        POP     DE                        ; restore the E flag.
        POP     HL                        ; restore the address of the next line.
        JR      list_all_2                ; back to LIST-ALL-2.

; ------------------------
; Print a whole BASIC line
; ------------------------
; This routine prints a whole BASIC line and it is called
; from LIST-ALL to output the line to current channel
; and from ED-EDIT to 'sprint' the line to the edit buffer.

out_line:
        LD      BC,(E_PPC)                ; fetch E_PPC the current line which may be
                                          ; unchecked and not exist.
        CALL    cp_lines                  ; routine CP-LINES finds match or line after.
        LD      D,$3E                     ; prepare cursor '>' in D.
        JR      Z,out_line1               ; to OUT-LINE1 if matched or line after.

        LD      DE,$0000                  ; put zero in D, to suppress line cursor.
        RL      E                         ; pick up carry in E if line before current
                                          ; leave E zero if same or after.

out_line1:
        LD      (IY+(BREG-C_IY)),E        ; save flag in BREG which is spare.
        LD      A,(HL)                    ; get high byte of line number.
        CP      $40                       ; is it too high ($2F is maximum possible) ?
        POP     BC                        ; drop the return address and
        RET     NC                        ; make an early return if so >>>

        PUSH    BC                        ; save return address
        CALL    out_num_2                 ; routine OUT-NUM-2 to print addressed number
                                          ; with leading space.
        INC     HL                        ; skip low number byte.
        INC     HL                        ; and the two
        INC     HL                        ; length bytes.
        RES     0,(IY+(FLAGS-C_IY))       ; update FLAGS - signal leading space required.
        LD      A,D                       ; fetch the cursor.
        AND     A                         ; test for zero.
        JR      Z,out_line3               ; to OUT-LINE3 if zero.


        RST     10H                       ; PRINT-A prints '>' the current line cursor.

; this entry point is called from ED-COPY

out_line2:
        SET     0,(IY+(FLAGS-C_IY))       ; update FLAGS - suppress leading space.

out_line3:
        PUSH    DE                        ; save flag E for a return value.
        EX      DE,HL                     ; save HL address in DE.
        RES     2,(IY+(FLAGS2-C_IY))      ; update FLAGS2 - signal NOT in QUOTES.

        LD      HL,FLAGS                  ; point to FLAGS.
        RES     2,(HL)                    ; signal 'K' mode. (starts before keyword)
        BIT     5,(IY+(FLAGX-C_IY))       ; test FLAGX - input mode ?
        JR      Z,out_line4               ; forward to OUT-LINE4 if not.

        SET     2,(HL)                    ; signal 'L' mode. (used for input)

out_line4:
        LD      HL,(X_PTR)                ; fetch X_PTR - possibly the error pointer
                                          ; address.
        AND     A                         ; clear the carry flag.
        SBC     HL,DE                     ; test if an error address has been reached.
        JR      NZ,out_line5              ; forward to OUT-LINE5 if not.

        LD      A,$3F                     ; load A with '?' the error marker.
        CALL    out_flash                 ; routine OUT-FLASH to print flashing marker.

out_line5:
        CALL    out_curs                  ; routine OUT-CURS will print the cursor if
                                          ; this is the right position.
        EX      DE,HL                     ; restore address pointer to HL.
        LD      A,(HL)                    ; fetch the addressed character.
        CALL    number                    ; routine NUMBER skips a hidden floating
                                          ; point number if present.
        INC     HL                        ; now increment the pointer.
        CP      $0D                       ; is character end-of-line ?
        JR      Z,out_line6               ; to OUT-LINE6, if so, as line is finished.

        EX      DE,HL                     ; save the pointer in DE.
        CALL    out_char                  ; routine OUT-CHAR to output character/token.

        JR      out_line4                 ; back to OUT-LINE4 until entire line is done.

; ---

out_line6:
        POP     DE                        ; bring back the flag E, zero if current
                                          ; line printed else 1 if still to print.
        RET                               ; return with A holding $0D

; -------------------------
; Check for a number marker
; -------------------------
; this subroutine is called from two processes. while outputting BASIC lines
; and while searching statements within a BASIC line.
; during both, this routine will pass over an invisible number indicator
; and the five bytes floating-point number that follows it.
; Note that this causes floating point numbers to be stripped from
; the BASIC line when it is fetched to the edit buffer by OUT_LINE.
; the number marker also appears after the arguments of a DEF FN statement
; and may mask old 5-byte string parameters.

number:
        CP      $0E                       ; character fourteen ?
        RET     NZ                        ; return if not.

        INC     HL                        ; skip the character
        INC     HL                        ; and five bytes
        INC     HL                        ; following.
        INC     HL                        ;
        INC     HL                        ;
        INC     HL                        ;
        LD      A,(HL)                    ; fetch the following character
        RET                               ; for return value.

; --------------------------
; Print a flashing character
; --------------------------
; This subroutine is called from OUT-LINE to print a flashing error
; marker '?' or from the next routine to print a flashing cursor e.g. 'L'.
; However, this only gets called from OUT-LINE when printing the edit line
; or the input buffer to the lower screen so a direct call to print_out can
; be used, even though out-line outputs to other streams.
; In fact the alternate set is used for the whole routine.

out_flash:
        EXX                               ; switch in alternate set

        LD      HL,(ATTR_T)               ; fetch L = ATTR_T, H = MASK-T
        PUSH    HL                        ; save masks.
        RES     7,H                       ; reset flash mask bit so active.
        SET     7,L                       ; make attribute FLASH.
        LD      (ATTR_T),HL               ; resave ATTR_T and MASK-T

        LD      HL,P_FLAG                 ; address P_FLAG
        LD      D,(HL)                    ; fetch to D
        PUSH    DE                        ; and save.
        LD      (HL),$00                  ; clear inverse, over, ink/paper 9

        CALL    print_out                 ; routine PRINT-OUT outputs character
                                          ; without the need to vector via RST 10H.

        POP     HL                        ; pop P_FLAG to H.
        LD      (IY+(P_FLAG-C_IY)),H      ; and restore system variable P_FLAG.
        POP     HL                        ; restore temporary masks
        LD      (ATTR_T),HL               ; and restore system variables ATTR_T/MASK_T

        EXX                               ; switch back to main set
        RET                               ; return

; ----------------
; Print the cursor
; ----------------
; This routine is called before any character is output while outputting
; a BASIC line or the input buffer. This includes listing to a printer
; or screen, copying a BASIC line to the edit buffer and printing the
; input buffer or edit buffer to the lower screen. It is only in the
; latter two cases that it has any relevance and in the last case it
; performs another very important function also.

out_curs:
        LD      HL,(K_CUR)                ; fetch K_CUR the current cursor address
        AND     A                         ; prepare for true subtraction.
        SBC     HL,DE                     ; test against pointer address in DE and
        RET     NZ                        ; return if not at exact position.

; the value of MODE, maintained by KEY-INPUT, is tested and if non-zero
; then this value 'E' or 'G' will take precedence.

        LD      A,(MODE)                  ; fetch MODE  0='KLC', 1='E', 2='G'.
        RLC     A                         ; double the value and set flags.
        JR      Z,out_c_1                 ; to OUT-C-1 if still zero ('KLC').

        ADD     A,$43                     ; add 'C' - will become 'E' if originally 1
                                          ; or 'G' if originally 2.
        JR      out_c_2                   ; forward to OUT-C-2 to print.

; ---

; If mode was zero then, while printing a BASIC line, bit 2 of flags has been
; set if 'THEN' or ':' was encountered as a main character and reset otherwise.
; This is now used to determine if the 'K' cursor is to be printed but this
; transient state is also now transferred permanently to bit 3 of FLAGS
; to let the interrupt routine know how to decode the next key.

out_c_1:
        LD      HL,FLAGS                  ; Address FLAGS
        RES     3,(HL)                    ; signal 'K' mode initially.
        LD      A,$4B                     ; prepare letter 'K'.
        BIT     2,(HL)                    ; test FLAGS - was the
                                          ; previous main character ':' or 'THEN' ?
        JR      Z,out_c_2                 ; forward to OUT-C-2 if so to print.

        SET     3,(HL)                    ; signal 'L' mode to interrupt routine.
                                          ; Note. transient bit has been made permanent.
        INC     A                         ; augment from 'K' to 'L'.

        BIT     3,(IY+(FLAGS2-C_IY))      ; test FLAGS2 - consider caps lock ?
                                          ; which is maintained by KEY-INPUT.
        JR      Z,out_c_2                 ; forward to OUT-C-2 if not set to print.

        LD      A,$43                     ; alter 'L' to 'C'.

out_c_2:
        PUSH    DE                        ; save address pointer but OK as OUT-FLASH
                                          ; uses alternate set without RST 10H.

        CALL    out_flash                 ; routine OUT-FLASH to print.

        POP     DE                        ; restore and
        RET                               ; return.

; ----------------------------
; Get line number of next line
; ----------------------------
; These two subroutines are called while editing.
; This entry point is from ED-DOWN with HL addressing E_PPC
; to fetch the next line number.
; Also from AUTO-LIST with HL addressing S_TOP just to update S_TOP
; with the value of the next line number. It gets fetched but is discarded.
; These routines never get called while the editor is being used for input.

ln_fetch:
        LD      E,(HL)                    ; fetch low byte
        INC     HL                        ; address next
        LD      D,(HL)                    ; fetch high byte.
        PUSH    HL                        ; save system variable hi pointer.
        EX      DE,HL                     ; line number to HL,
        INC     HL                        ; increment as a starting point.
        CALL    line_addr                 ; routine LINE-ADDR gets address in HL.
        CALL    line_no                   ; routine LINE-NO gets line number in DE.
        POP     HL                        ; restore system variable hi pointer.

; This entry point is from the ED-UP with HL addressing E_PPC_hi

ln_store:
        BIT     5,(IY+(FLAGX-C_IY))       ; test FLAGX - input mode ?
        RET     NZ                        ; return if so.
                                          ; Note. above already checked by ED-UP/ED-DOWN.

        LD      (HL),D                    ; save high byte of line number.
        DEC     HL                        ; address lower
        LD      (HL),E                    ; save low byte of line number.
        RET                               ; return.

; -----------------------------------------
; Outputting numbers at start of BASIC line
; -----------------------------------------
; This routine entered at OUT-SP-NO is used to compute then output the first
; three digits of a 4-digit BASIC line printing a space if necessary.
; The line number, or residual part, is held in HL and the BC register
; holds a subtraction value -1000, -100 or -10.
; Note. for example line number 200 -
; space(out_char), 2(out_code), 0(out_char) final number always out-code.

out_sp_2:
        LD      A,E                       ; will be space if OUT-CODE not yet called.
                                          ; or $FF if spaces are suppressed.
                                          ; else $30 ('0').
                                          ; (from the first instruction at OUT-CODE)
                                          ; this guy is just too clever.
        AND     A                         ; test bit 7 of A.
        RET     M                         ; return if $FF, as leading spaces not
                                          ; required. This is set when printing line
                                          ; number and statement in MAIN-5.

        JR      out_char                  ; forward to exit via OUT-CHAR.

; ---

; -> the single entry point.

out_sp_no:
        XOR     A                         ; initialize digit to 0

out_sp_1:
        ADD     HL,BC                     ; add negative number to HL.
        INC     A                         ; increment digit
        JR      C,out_sp_1                ; back to OUT-SP-1 until no carry from
                                          ; the addition.

        SBC     HL,BC                     ; cancel the last addition
        DEC     A                         ; and decrement the digit.
        JR      Z,out_sp_2                ; back to OUT-SP-2 if it is zero.

        JP      out_code                  ; jump back to exit via OUT-CODE.    ->


; -------------------------------------
; Outputting characters in a BASIC line
; -------------------------------------
; This subroutine ...

out_char:
        CALL    numeric                   ; routine NUMERIC tests if it is a digit ?
        JR      NC,out_ch_3               ; to OUT-CH-3 to print digit without
                                          ; changing mode. Will be 'K' mode if digits
                                          ; are at beginning of edit line.

        CP      $21                       ; less than quote character ?
        JR      C,out_ch_3                ; to OUT-CH-3 to output controls and space.

        RES     2,(IY+(FLAGS-C_IY))       ; initialize FLAGS to 'K' mode and leave
                                          ; unchanged if this character would precede
                                          ; a keyword.

        CP      $CB                       ; is character 'THEN' token ?
        JR      Z,out_ch_3                ; to OUT-CH-3 to output if so.

        CP      $3A                       ; is it ':' ?
        JR      NZ,out_ch_1               ; to OUT-CH-1 if not statement separator
                                          ; to change mode back to 'L'.

        BIT     5,(IY+(FLAGX-C_IY))       ; FLAGX  - Input Mode ??
        JR      NZ,out_ch_2               ; to OUT-CH-2 if in input as no statements.
                                          ; Note. this check should seemingly be at
                                          ; the start. Commands seem inappropriate in
                                          ; INPUT mode and are rejected by the syntax
                                          ; checker anyway.
                                          ; unless INPUT LINE is being used.

        BIT     2,(IY+(FLAGS2-C_IY))      ; test FLAGS2 - is the ':' within quotes ?
        JR      Z,out_ch_3                ; to OUT-CH-3 if ':' is outside quoted text.

        JR      out_ch_2                  ; to OUT-CH-2 as ':' is within quotes

; ---

out_ch_1:
        CP      $22                       ; is it quote character '"'  ?
        JR      NZ,out_ch_2               ; to OUT-CH-2 with others to set 'L' mode.

        PUSH    AF                        ; save character.
        LD      A,(FLAGS2)                ; fetch FLAGS2.
        XOR     $04                       ; toggle the quotes flag.
        LD      (FLAGS2),A                ; update FLAGS2
        POP     AF                        ; and restore character.

out_ch_2:
        SET     2,(IY+(FLAGS-C_IY))       ; update FLAGS - signal L mode if the cursor
                                          ; is next.

out_ch_3:
        RST     10H                       ; PRINT-A vectors the character to
                                          ; channel 'S', 'K', 'R' or 'P'.
        RET                               ; return.

; -------------------------------------------
; Get starting address of line, or line after
; -------------------------------------------
; This routine is used often to get the address, in HL, of a BASIC line
; number supplied in HL, or failing that the address of the following line
; and the address of the previous line in DE.

line_addr:
        PUSH    HL                        ; save line number in HL register
        LD      HL,(PROG)                 ; fetch start of program from PROG
        LD      D,H                       ; transfer address to
        LD      E,L                       ; the DE register pair.

line_ad_1:
        POP     BC                        ; restore the line number to BC
        CALL    cp_lines                  ; routine CP-LINES compares with that
                                          ; addressed by HL
        RET     NC                        ; return if line has been passed or matched.
                                          ; if NZ, address of previous is in DE

        PUSH    BC                        ; save the current line number
        CALL    next_one                  ; routine NEXT-ONE finds address of next
                                          ; line number in DE, previous in HL.
        EX      DE,HL                     ; switch so next in HL
        JR      line_ad_1                 ; back to LINE-AD-1 for another comparison

; --------------------
; Compare line numbers
; --------------------
; This routine compares a line number supplied in BC with an addressed
; line number pointed to by HL.

cp_lines:
        LD      A,(HL)                    ; Load the high byte of line number and
        CP      B                         ; compare with that of supplied line number.
        RET     NZ                        ; return if yet to match (carry will be set).

        INC     HL                        ; address low byte of
        LD      A,(HL)                    ; number and pick up in A.
        DEC     HL                        ; step back to first position.
        CP      C                         ; now compare.
        RET                               ; zero set if exact match.
                                          ; carry set if yet to match.
                                          ; no carry indicates a match or
                                          ; next available BASIC line or
                                          ; program end marker.

; -------------------
; Find each statement
; -------------------
; The single entry point EACH-STMT is used to
; 1) To find the D'th statement in a line.
; 2) To find a token in held E.

not_used:
        INC     HL                        ;
        INC     HL                        ;
        INC     HL                        ;

; -> entry point.

each_stmt:
        LD      (CH_ADD),HL               ; save HL in CH_ADD
        LD      C,$00                     ; initialize quotes flag

each_s_1:
        DEC     D                         ; decrease statement count
        RET     Z                         ; return if zero


        RST     20H                       ; NEXT-CHAR
        CP      E                         ; is it the search token ?
        JR      NZ,each_s_3               ; forward to EACH-S-3 if not

        AND     A                         ; clear carry
        RET                               ; return signalling success.

; ---

each_s_2:
        INC     HL                        ; next address
        LD      A,(HL)                    ; next character

each_s_3:
        CALL    number                    ; routine NUMBER skips if number marker
        LD      (CH_ADD),HL               ; save in CH_ADD
        CP      $22                       ; is it quotes '"' ?
        JR      NZ,each_s_4               ; to EACH-S-4 if not

        DEC     C                         ; toggle bit 0 of C

each_s_4:
        CP      $3A                       ; is it ':'
        JR      Z,each_s_5                ; to EACH-S-5

        CP      $CB                       ; 'THEN'
        JR      NZ,each_s_6               ; to EACH-S-6

each_s_5:
        BIT     0,C                       ; is it in quotes
        JR      Z,each_s_1                ; to EACH-S-1 if not

each_s_6:
        CP      $0D                       ; end of line ?
        JR      NZ,each_s_2               ; to EACH-S-2

        DEC     D                         ; decrease the statement counter
                                          ; which should be zero else
                                          ; 'Statement Lost'.
        SCF                               ; set carry flag - not found
        RET                               ; return

; -----------------------------------------------------------------------
; Storage of variables. For full details - see chapter 24.
; ZX Spectrum BASIC Programming by Steven Vickers 1982.
; It is bits 7-5 of the first character of a variable that allow
; the six types to be distinguished. Bits 4-0 are the reduced letter.
; So any variable name is higher that $3F and can be distinguished
; also from the variables area end-marker $80.
;
; 76543210 meaning                               brief outline of format.
; -------- ------------------------              -----------------------
; 010      string variable.                      2 byte length + contents.
; 110      string array.                         2 byte length + contents.
; 100      array of numbers.                     2 byte length + contents.
; 011      simple numeric variable.              5 bytes.
; 101      variable length named numeric.        5 bytes.
; 111      for-next loop variable.               18 bytes.
; 10000000 the variables area end-marker.
;
; Note. any of the above seven will serve as a program end-marker.
;
; -----------------------------------------------------------------------

; ------------
; Get next one
; ------------
; This versatile routine is used to find the address of the next line
; in the program area or the next variable in the variables area.
; The reason one routine is made to handle two apparently unrelated tasks
; is that it can be called indiscriminately when merging a line or a
; variable.

next_one:
        PUSH    HL                        ; save the pointer address.
        LD      A,(HL)                    ; get first byte.
        CP      $40                       ; compare with upper limit for line numbers.
        JR      C,next_o_3                ; forward to NEXT-O-3 if within BASIC area.

; the continuation here is for the next variable unless the supplied
; line number was erroneously over 16383. see RESTORE command.

        BIT     5,A                       ; is it a string or an array variable ?
        JR      Z,next_o_4                ; forward to NEXT-O-4 to compute length.

        ADD     A,A                       ; test bit 6 for single-character variables.
        JP      M,next_o_1                ; forward to NEXT-O-1 if so

        CCF                               ; clear the carry for long-named variables.
                                          ; it remains set for for-next loop variables.

next_o_1:
        LD      BC,$0005                  ; set BC to 5 for floating point number
        JR      NC,next_o_2               ; forward to NEXT-O-2 if not a for/next
                                          ; variable.

        LD      C,$12                     ; set BC to eighteen locations.
                                          ; value, limit, step, line and statement.

; now deal with long-named variables

next_o_2:
        RLA                               ; test if character inverted. carry will also
                                          ; be set for single character variables
        INC     HL                        ; address next location.
        LD      A,(HL)                    ; and load character.
        JR      NC,next_o_2               ; back to NEXT-O-2 if not inverted bit.
                                          ; forward immediately with single character
                                          ; variable names.

        JR      next_o_5                  ; forward to NEXT-O-5 to add length of
                                          ; floating point number(s etc.).

; ---

; this branch is for line numbers.

next_o_3:
        INC     HL                        ; increment pointer to low byte of line no.

; strings and arrays rejoin here

next_o_4:
        INC     HL                        ; increment to address the length low byte.
        LD      C,(HL)                    ; transfer to C and
        INC     HL                        ; point to high byte of length.
        LD      B,(HL)                    ; transfer that to B
        INC     HL                        ; point to start of BASIC/variable contents.

; the three types of numeric variables rejoin here

next_o_5:
        ADD     HL,BC                     ; add the length to give address of next
                                          ; line/variable in HL.
        POP     DE                        ; restore previous address to DE.

; ------------------
; Difference routine
; ------------------
; This routine terminates the above routine and is also called from the
; start of the next routine to calculate the length to reclaim.

differ:
        AND     A                         ; prepare for true subtraction.
        SBC     HL,DE                     ; subtract the two pointers.
        LD      B,H                       ; transfer result
        LD      C,L                       ; to BC register pair.
        ADD     HL,DE                     ; add back
        EX      DE,HL                     ; and switch pointers
        RET                               ; return values are the length of area in BC,
                                          ; low pointer (previous) in HL,
                                          ; high pointer (next) in DE.

; -----------------------
; Handle reclaiming space
; -----------------------
;

reclaim_1:
        CALL    differ                    ; routine DIFFER immediately above

reclaim_2:
        PUSH    BC                        ;

        LD      A,B                       ;
        CPL                               ;
        LD      B,A                       ;
        LD      A,C                       ;
        CPL                               ;
        LD      C,A                       ;
        INC     BC                        ;

        CALL    pointers                  ; routine POINTERS
        EX      DE,HL                     ;
        POP     HL                        ;

        ADD     HL,DE                     ;
        PUSH    DE                        ;
        LDIR                              ; copy bytes

        POP     HL                        ;
        RET                               ;

; ----------------------------------------
; Read line number of line in editing area
; ----------------------------------------
; This routine reads a line number in the editing area returning the number
; in the BC register or zero if no digits exist before commands.
; It is called from LINE-SCAN to check the syntax of the digits.
; It is called from MAIN-3 to extract the line number in preparation for
; inclusion of the line in the BASIC program area.
;
; Interestingly the calculator stack is moved from its normal place at the
; end of dynamic memory to an adequate area within the system variables area.
; This ensures that in a low memory situation, that valid line numbers can
; be extracted without raising an error and that memory can be reclaimed
; by deleting lines. If the stack was in its normal place then a situation
; arises whereby the Spectrum becomes locked with no means of reclaiming space.

e_line_no:
        LD      HL,(E_LINE)               ; load HL from system variable E_LINE.

        DEC     HL                        ; decrease so that NEXT_CHAR can be used
                                          ; without skipping the first digit.

        LD      (CH_ADD),HL               ; store in the system variable CH_ADD.

        RST     20H                       ; NEXT-CHAR skips any noise and white-space
                                          ; to point exactly at the first digit.

        LD      HL,MEMBOT                 ; use MEM-0 as a temporary calculator stack
                                          ; an overhead of three locations are needed.
        LD      (STKEND),HL               ; set new STKEND.

        CALL    int_to_fp                 ; routine INT-TO-FP will read digits till
                                          ; a non-digit found.
        CALL    fp_to_bc                  ; routine FP-TO-BC will retrieve number
                                          ; from stack at membot.
        JR      C,e_l_1                   ; forward to E-L-1 if overflow i.e. > 65535.
                                          ; 'Nonsense in BASIC'

        LD      HL,-10000                 ; load HL with value -10000
        ADD     HL,BC                     ; add to line number in BC

e_l_1:
        JP      C,report_c                ; to REPORT-C 'Nonsense in BASIC' if over.
                                          ; Note. As ERR_SP points to ED_ERROR
                                          ; the report is never produced although
                                          ; the RST 08H will update X_PTR leading to
                                          ; the error marker being displayed when
                                          ; the ED_LOOP is reiterated.
                                          ; in fact, since it is immediately
                                          ; cancelled, any report will do.

; a line in the range 0 - 9999 has been entered.

        JP      set_stk                   ; jump back to SET-STK to set the calculator
                                          ; stack back to its normal place and exit
                                          ; from there.

; ---------------------------------
; Report and line number outputting
; ---------------------------------
; Entry point OUT-NUM-1 is used by the Error Reporting code to print
; the line number and later the statement number held in BC.
; If the statement was part of a direct command then -2 is used as a
; dummy line number so that zero will be printed in the report.
; This routine is also used to print the exponent of E-format numbers.
;
; Entry point OUT-NUM-2 is used from OUT-LINE to output the line number
; addressed by HL with leading spaces if necessary.

out_num_1:
        PUSH    DE                        ; save the
        PUSH    HL                        ; registers.
        XOR     A                         ; set A to zero.
        BIT     7,B                       ; is the line number minus two ?
        JR      NZ,out_num_4              ; forward to OUT-NUM-4 if so to print zero
                                          ; for a direct command.

        LD      H,B                       ; transfer the
        LD      L,C                       ; number to HL.
        LD      E,$FF                     ; signal 'no leading zeros'.
        JR      out_num_3                 ; forward to continue at OUT-NUM-3

; ---

; from OUT-LINE - HL addresses line number.

out_num_2:
        PUSH    DE                        ; save flags
        LD      D,(HL)                    ; high byte to D
        INC     HL                        ; address next
        LD      E,(HL)                    ; low byte to E
        PUSH    HL                        ; save pointer
        EX      DE,HL                     ; transfer number to HL
        LD      E,$20                     ; signal 'output leading spaces'

out_num_3:
        LD      BC,-1000                  ; value -1000
        CALL    out_sp_no                 ; routine OUT-SP-NO outputs space or number
        LD      BC,-100                   ; value -100
        CALL    out_sp_no                 ; routine OUT-SP-NO
        LD      C,-10                     ; value -10 ( B is still $FF )
        CALL    out_sp_no                 ; routine OUT-SP-NO
        LD      A,L                       ; remainder to A.

out_num_4:
        CALL    out_code                  ; routine OUT-CODE for final digit.
                                          ; else report code zero wouldn't get
                                          ; printed.
        POP     HL                        ; restore the
        POP     DE                        ; registers and
        RET                               ; return.


;***************************************************
;** Part 7. BASIC LINE AND COMMAND INTERPRETATION **
;***************************************************

; ----------------
; The offset table
; ----------------
; The BASIC interpreter has found a command code $CE - $FF
; which is then reduced to range $00 - $31 and added to the base address
; of this table to give the address of an offset which, when added to
; the offset therein, gives the location in the following parameter table
; where a list of class codes, separators and addresses relevant to the
; command exists.

offst_tbl:
        DEFB    p_def_fn - $              ; B1 offset to Address: P-DEF-FN
        DEFB    p_cat - $                 ; CB offset to Address: P-CAT
        DEFB    p_format - $              ; BC offset to Address: P-FORMAT
        DEFB    p_move- $                 ; BF offset to Address: P-MOVE
        DEFB    p_erase - $               ; C4 offset to Address: P-ERASE
        DEFB    p_open- $                 ; AF offset to Address: P-OPEN
        DEFB    p_close - $               ; B4 offset to Address: P-CLOSE
        DEFB    p_merge - $               ; 93 offset to Address: P-MERGE
        DEFB    p_verify - $              ; 91 offset to Address: P-VERIFY
        DEFB    p_beep- $                 ; 92 offset to Address: P-BEEP
        DEFB    p_circle - $              ; 95 offset to Address: P-CIRCLE
        DEFB    p_ink - $                 ; 98 offset to Address: P-INK
        DEFB    p_paper - $               ; 98 offset to Address: P-PAPER
        DEFB    p_flash - $               ; 98 offset to Address: P-FLASH
        DEFB    p_bright - $              ; 98 offset to Address: P-BRIGHT
        DEFB    p_inverse - $             ; 98 offset to Address: P-INVERSE
        DEFB    p_over- $                 ; 98 offset to Address: P-OVER
        DEFB    p_out - $                 ; 98 offset to Address: P-OUT
        DEFB    p_lprint - $              ; 7F offset to Address: P-LPRINT
        DEFB    p_llist - $               ; 81 offset to Address: P-LLIST
        DEFB    p_stop- $                 ; 2E offset to Address: P-STOP
        DEFB    p_read- $                 ; 6C offset to Address: P-READ
        DEFB    p_data- $                 ; 6E offset to Address: P-DATA
        DEFB    p_restore - $             ; 70 offset to Address: P-RESTORE
        DEFB    p_new - $                 ; 48 offset to Address: P-NEW
        DEFB    p_border - $              ; 94 offset to Address: P-BORDER
        DEFB    p_cont- $                 ; 56 offset to Address: P-CONT
        DEFB    p_dim - $                 ; 3F offset to Address: P-DIM
        DEFB    p_rem - $                 ; 41 offset to Address: P-REM
        DEFB    p_for - $                 ; 2B offset to Address: P-FOR
        DEFB    p_go_to - $               ; 17 offset to Address: P-GO-TO
        DEFB    p_go_sub - $              ; 1F offset to Address: P-GO-SUB
        DEFB    p_input - $               ; 37 offset to Address: P-INPUT
        DEFB    p_load- $                 ; 77 offset to Address: P-LOAD
        DEFB    p_list- $                 ; 44 offset to Address: P-LIST
        DEFB    p_let - $                 ; 0F offset to Address: P-LET
        DEFB    p_pause - $               ; 59 offset to Address: P-PAUSE
        DEFB    p_next- $                 ; 2B offset to Address: P-NEXT
        DEFB    p_poke- $                 ; 43 offset to Address: P-POKE
        DEFB    p_print - $               ; 2D offset to Address: P-PRINT
        DEFB    p_plot- $                 ; 51 offset to Address: P-PLOT
        DEFB    p_run - $                 ; 3A offset to Address: P-RUN
        DEFB    p_save- $                 ; 6D offset to Address: P-SAVE
        DEFB    p_random - $              ; 42 offset to Address: P-RANDOM
        DEFB    p_if - $                  ; 0D offset to Address: P-IF
        DEFB    p_cls - $                 ; 49 offset to Address: P-CLS
        DEFB    p_draw- $                 ; 5C offset to Address: P-DRAW
        DEFB    p_clear - $               ; 44 offset to Address: P-CLEAR
        DEFB    p_return - $              ; 15 offset to Address: P-RETURN
        DEFB    p_copy- $                 ; 5D offset to Address: P-COPY


; -------------------------------
; The parameter or "Syntax" table
; -------------------------------
; For each command there exists a variable list of parameters.
; If the character is greater than a space it is a required separator.
; If less, then it is a command class in the range 00 - 0B.
; Note that classes 00, 03 and 05 will fetch the addresses from this table.
; Some classes e.g. 07 and 0B have the same address in all invocations
; and the command is re-computed from the low-byte of the parameter address.
; Some e.g. 02 are only called once so a call to the command is made from
; within the class routine rather than holding the address within the table.
; Some class routines check syntax entirely and some leave this task for the
; command itself.
; Others for example CIRCLE (x,y,z) check the first part (x,y) using the
; class routine and the final part (,z) within the command.
; The last few commands appear to have been added in a rush but their syntax
; is rather simple e.g. MOVE "M1","M2"

p_let:
        DEFB    $01                       ; Class-01 - A variable is required.
        DEFB    $3D                       ; Separator:  '='
        DEFB    $02                       ; Class-02 - An expression, numeric or string,
                                          ; must follow.

p_go_to:
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    go_to                     ; Address: go_to; Address: GO-TO

p_if:
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $CB                       ; Separator:  'THEN'
        DEFB    $05                       ; Class-05 - Variable syntax checked
                                          ; by routine.
        DEFW    if                        ; Address: if; Address: IF

p_go_sub:
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    go_sub                    ; Address: go_sub; Address: GO-SUB

p_stop:
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    stop                      ; Address: stop; Address: STOP

p_return:
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    return                    ; Address: return; Address: RETURN

p_for:
        DEFB    $04                       ; Class-04 - A single character variable must
                                          ; follow.
        DEFB    $3D                       ; Separator:  '='
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $CC                       ; Separator:  'TO'
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $05                       ; Class-05 - Variable syntax checked
                                          ; by routine.
        DEFW    for                       ; Address: for; Address: FOR

p_next:
        DEFB    $04                       ; Class-04 - A single character variable must
                                          ; follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    next                      ; Address: next; Address: NEXT

p_print:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    print                     ; Address: print; Address: PRINT

p_input:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    input                     ; Address: input; Address: INPUT

p_dim:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    dim                       ; Address: dim; Address: DIM

p_rem:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    rem                       ; Address: rem; Address: REM

p_new:
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    new                       ; Address: new; Address: NEW

p_run:
        DEFB    $03                       ; Class-03 - A numeric expression may follow
                                          ; else default to zero.
        DEFW    run                       ; Address: run; Address: RUN

p_list:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    list                      ; Address: list; Address: LIST

p_poke:
        DEFB    $08                       ; Class-08 - Two comma-separated numeric
                                          ; expressions required.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    poke                      ; Address: poke; Address: POKE

p_random:
        DEFB    $03                       ; Class-03 - A numeric expression may follow
                                          ; else default to zero.
        DEFW    randomize                 ; Address: randomize; Address: RANDOMIZE

p_cont:
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    continue                  ; Address: continue; Address: CONTINUE

p_clear:
        DEFB    $03                       ; Class-03 - A numeric expression may follow
                                          ; else default to zero.
        DEFW    clear                     ; Address: clear; Address: CLEAR

p_cls:
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    cls                       ; Address: cls; Address: CLS

p_plot:
        DEFB    $09                       ; Class-09 - Two comma-separated numeric
                                          ; expressions required with optional colour
                                          ; items.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    plot                      ; Address: plot; Address: PLOT

p_pause:
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    pause                     ; Address: pause; Address: PAUSE

p_read:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    read                      ; Address: read; Address: READ

p_data:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    data                      ; Address: data; Address: DATA

p_restore:
        DEFB    $03                       ; Class-03 - A numeric expression may follow
                                          ; else default to zero.
        DEFW    restore                   ; Address: restore; Address: RESTORE

p_draw:
        DEFB    $09                       ; Class-09 - Two comma-separated numeric
                                          ; expressions required with optional colour
                                          ; items.
        DEFB    $05                       ; Class-05 - Variable syntax checked
                                          ; by routine.
        DEFW    draw                      ; Address: draw; Address: DRAW

p_copy:
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    copy                      ; Address: copy; Address: COPY

p_lprint:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    lprint                    ; Address: lprint; Address: LPRINT

p_llist:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    llist                     ; Address: llist; Address: LLIST

p_save:
        DEFB    $0B                       ; Class-0B - Offset address converted to tape
                                          ; command.

p_load:
        DEFB    $0B                       ; Class-0B - Offset address converted to tape
                                          ; command.

p_verify:
        DEFB    $0B                       ; Class-0B - Offset address converted to tape
                                          ; command.

p_merge:
        DEFB    $0B                       ; Class-0B - Offset address converted to tape
                                          ; command.

p_beep:
        DEFB    $08                       ; Class-08 - Two comma-separated numeric
                                          ; expressions required.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    beep                      ; Address: beep; Address: BEEP

p_circle:
        DEFB    $09                       ; Class-09 - Two comma-separated numeric
                                          ; expressions required with optional colour
                                          ; items.
        DEFB    $05                       ; Class-05 - Variable syntax checked
                                          ; by routine.
        DEFW    circle                    ; Address: circle; Address: CIRCLE

p_ink:
        DEFB    $07                       ; Class-07 - Offset address is converted to
                                          ; colour code.

p_paper:
        DEFB    $07                       ; Class-07 - Offset address is converted to
                                          ; colour code.

p_flash:
        DEFB    $07                       ; Class-07 - Offset address is converted to
                                          ; colour code.

p_bright:
        DEFB    $07                       ; Class-07 - Offset address is converted to
                                          ; colour code.

p_inverse:
        DEFB    $07                       ; Class-07 - Offset address is converted to
                                          ; colour code.

p_over:
        DEFB    $07                       ; Class-07 - Offset address is converted to
                                          ; colour code.

p_out:
        DEFB    $08                       ; Class-08 - Two comma-separated numeric
                                          ; expressions required.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    cout                      ; Address: cout; Address: OUT

p_border:
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    border                    ; Address: border; Address: BORDER

p_def_fn:
        DEFB    $05                       ; Class-05 - Variable syntax checked entirely
                                          ; by routine.
        DEFW    def_fn                    ; Address: def_fn; Address: DEF-FN

p_open:
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $2C                       ; Separator:  ','          see Footnote *
        DEFB    $0A                       ; Class-0A - A string expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    open                      ; Address: open; Address: OPEN

p_close:
        DEFB    $06                       ; Class-06 - A numeric expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    close                     ; Address: close; Address: CLOSE

p_format:
        DEFB    $0A                       ; Class-0A - A string expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    cat_etc                   ; Address: cat_etc; Address: CAT-ETC

p_move:
        DEFB    $0A                       ; Class-0A - A string expression must follow.
        DEFB    $2C                       ; Separator:  ','
        DEFB    $0A                       ; Class-0A - A string expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    cat_etc                   ; Address: cat_etc; Address: CAT-ETC

p_erase:
        DEFB    $0A                       ; Class-0A - A string expression must follow.
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    cat_etc                   ; Address: cat_etc; Address: CAT-ETC

p_cat:
        DEFB    $00                       ; Class-00 - No further operands.
        DEFW    cat_etc                   ; Address: cat_etc; Address: CAT-ETC

; * Note that a comma is required as a separator with the OPEN command
; but the Interface 1 programmers relaxed this allowing ';' as an
; alternative for their channels creating a confusing mixture of
; allowable syntax as it is this ROM which opens or re-opens the
; normal channels.

; -------------------------------
; Main parser (BASIC interpreter)
; -------------------------------
; This routine is called once from MAIN-2 when the BASIC line is to
; be entered or re-entered into the Program area and the syntax
; requires checking.

line_scan:
        RES     7,(IY+(FLAGS-C_IY))       ; update FLAGS - signal checking syntax
        CALL    e_line_no                 ; routine E-LINE-NO              >>
                                          ; fetches the line number if in range.

        XOR     A                         ; clear the accumulator.
        LD      (SUBPPC),A                ; set statement number SUBPPC to zero.
        DEC     A                         ; set accumulator to $FF.
        LD      (ERR_NR),A                ; set ERR_NR to 'OK' - 1.
        JR      stmt_l_1                  ; forward to continue at STMT-L-1.

; --------------
; Statement loop
; --------------
;
;

stmt_loop:
        RST     20H                       ; NEXT-CHAR

; -> the entry point from above or LINE-RUN
stmt_l_1:
        CALL    set_work                  ; routine SET-WORK clears workspace etc.

        INC     (IY+(SUBPPC-C_IY))        ; increment statement number SUBPPC
        JP      M,report_c                ; to REPORT-C to raise
                                          ; 'Nonsense in BASIC' if over 127.

        RST     18H                       ; GET-CHAR

        LD      B,$00                     ; set B to zero for later indexing.
                                          ; early so any other reason ???

        CP      $0D                       ; is character carriage return ?
                                          ; i.e. an empty statement.
        JR      Z,line_end                ; forward to LINE-END if so.

        CP      $3A                       ; is it statement end marker ':' ?
                                          ; i.e. another type of empty statement.
        JR      Z,stmt_loop               ; back to STMT-LOOP if so.

        LD      HL,stmt_ret               ; address: STMT-RET
        PUSH    HL                        ; is now pushed as a return address
        LD      C,A                       ; transfer the current character to C.

; advance CH_ADD to a position after command and test if it is a command.

        RST     20H                       ; NEXT-CHAR to advance pointer
        LD      A,C                       ; restore current character
        SUB     $CE                       ; subtract 'DEF FN' - first command
        JP      C,report_c                ; jump to REPORT-C if less than a command
                                          ; raising
                                          ; 'Nonsense in BASIC'

        LD      C,A                       ; put the valid command code back in C.
                                          ; register B is zero.
        LD      HL,offst_tbl              ; address: offst-tbl
        ADD     HL,BC                     ; index into table with one of 50 commands.
        LD      C,(HL)                    ; pick up displacement to syntax table entry.
        ADD     HL,BC                     ; add to address the relevant entry.
        JR      get_param                 ; forward to continue at GET-PARAM

; ----------------------
; The main scanning loop
; ----------------------
; not documented properly
;

scan_loop:
        LD      HL,(T_ADDR)               ; fetch temporary address from T_ADDR
                                          ; during subsequent loops.

; -> the initial entry point with HL addressing start of syntax table entry.

get_param:
        LD      A,(HL)                    ; pick up the parameter.
        INC     HL                        ; address next one.
        LD      (T_ADDR),HL               ; save pointer in system variable T_ADDR

        LD      BC,scan_loop              ; address: SCAN-LOOP
        PUSH    BC                        ; is now pushed on stack as looping address.
        LD      C,A                       ; store parameter in C.
        CP      $20                       ; is it greater than ' '  ?
        JR      NC,separator              ; forward to SEPARATOR to check that correct
                                          ; separator appears in statement if so.

        LD      HL,class_tbl              ; address: class-tbl.
        LD      B,$00                     ; prepare to index into the class table.
        ADD     HL,BC                     ; index to find displacement to routine.
        LD      C,(HL)                    ; displacement to BC
        ADD     HL,BC                     ; add to address the CLASS routine.
        PUSH    HL                        ; push the address on the stack.

        RST     18H                       ; GET-CHAR - HL points to place in statement.

        DEC     B                         ; reset the zero flag - the initial state
                                          ; for all class routines.

        RET                               ; and make an indirect jump to routine
                                          ; and then SCAN-LOOP (also on stack).

; Note. one of the class routines will eventually drop the return address
; off the stack breaking out of the above seemingly endless loop.

; ----------------
; Verify separator
; ----------------
; This routine is called once to verify that the mandatory separator
; present in the parameter table is also present in the correct
; location following the command. For example, the 'THEN' token after
; the 'IF' token and expression.

separator:
        RST     18H                       ; GET-CHAR
        CP      C                         ; does it match the character in C ?
        JP      NZ,report_c               ; jump forward to REPORT-C if not
                                          ; 'Nonsense in BASIC'.

        RST     20H                       ; NEXT-CHAR advance to next character
        RET                               ; return.

; ------------------------------
; Come here after interpretation
; ------------------------------
;
;

stmt_ret:
        CALL    break_key                 ; routine BREAK-KEY is tested after every
                                          ; statement.
        JR      C,stmt_r_1                ; step forward to STMT-R-1 if not pressed.

report_l:
        RST     08H                       ; ERROR-1
        DEFB    $14                       ; Error Report: BREAK into program

stmt_r_1:
        CALL    statement_patch           ; Spectrum 128 patch
        NOP

        JR      NZ,stmt_next              ; forward to STMT-NEXT if a program line.

        LD      HL,(NEWPPC)               ; fetch line number from NEWPPC
        BIT     7,H                       ; will be set if minus two - direct command(s)
        JR      Z,line_new                ; forward to LINE-NEW if a jump is to be
                                          ; made to a new program line/statement.

; --------------------
; Run a direct command
; --------------------
; A direct command is to be run or, if continuing from above,
; the next statement of a direct command is to be considered.

line_run:
        LD      HL,-2                     ; The dummy value minus two
        LD      (PPC),HL                  ; is set/reset as line number in PPC.
        LD      HL,(WORKSP)               ; point to end of line + 1 - WORKSP.
        DEC     HL                        ; now point to $80 end-marker.
        LD      DE,(E_LINE)               ; address the start of line E_LINE.
        DEC     DE                        ; now location before - for GET-CHAR.
        LD      A,(NSPPC)                 ; load statement to A from NSPPC.
        JR      next_line                 ; forward to NEXT-LINE.

; ------------------------------
; Find start address of new line
; ------------------------------
; The branch was to here if a jump is to made to a new line number
; and statement.
; That is the previous statement was a GO TO, GO SUB, RUN, RETURN, NEXT etc..

line_new:
        CALL    line_addr                 ; routine LINE-ADDR gets address of line
                                          ; returning zero flag set if line found.
        LD      A,(NSPPC)                 ; fetch new statement from NSPPC
        JR      Z,line_use                ; forward to LINE-USE if line matched.

; continue as must be a direct command.

        AND     A                         ; test statement which should be zero
        JR      NZ,report_n               ; forward to REPORT-N if not.
                                          ; 'Statement lost'

;

        LD      B,A                       ; save statement in B. ?
        LD      A,(HL)                    ; fetch high byte of line number.
        AND     $C0                       ; test if using direct command
                                          ; a program line is less than $3F
        LD      A,B                       ; retrieve statement.
                                          ; (we can assume it is zero).
        JR      Z,line_use                ; forward to LINE-USE if was a program line

; Alternatively a direct statement has finished correctly.

report_0:
        RST     08H                       ; ERROR-1
        DEFB    $FF                       ; Error Report: OK

; ------------------
; Handle REM command
; ------------------
; The REM command routine.
; The return address STMT-RET is dropped and the rest of line ignored.

rem:
        POP     BC                        ; drop return address STMT-RET and
                                          ; continue ignoring rest of line.

; ------------
; End of line?
; ------------
;
;

line_end:
        CALL    syntax_z                  ; routine SYNTAX-Z  (UNSTACK-Z?)
        RET     Z                         ; return if checking syntax.

        LD      HL,(NXTLIN)               ; fetch NXTLIN to HL.
        LD      A,$C0                     ; test against the
        AND     (HL)                      ; system limit $3F.
        RET     NZ                        ; return if more as must be
                                          ; end of program.
                                          ; (or direct command)

        XOR     A                         ; set statement to zero.

; and continue to set up the next following line and then consider this new one.

; ---------------------
; General line checking
; ---------------------
; The branch was here from LINE-NEW if BASIC is branching.
; or a continuation from above if dealing with a new sequential line.
; First make statement zero number one leaving others unaffected.

line_use:
        CP      $01                       ; will set carry if zero.
        ADC     A,$00                     ; add in any carry.

        LD      D,(HL)                    ; high byte of line number to D.
        INC     HL                        ; advance pointer.
        LD      E,(HL)                    ; low byte of line number to E.
        LD      (PPC),DE                  ; set system variable PPC.

        INC     HL                        ; advance pointer.
        LD      E,(HL)                    ; low byte of line length to E.
        INC     HL                        ; advance pointer.
        LD      D,(HL)                    ; high byte of line length to D.

        EX      DE,HL                     ; swap pointer to DE before
        ADD     HL,DE                     ; adding to address the end of line.
        INC     HL                        ; advance to start of next line.

; -----------------------------
; Update NEXT LINE but consider
; previous line or edit line.
; -----------------------------
; The pointer will be the next line if continuing from above or to
; edit line end-marker ($80) if from LINE-RUN.

next_line:
        LD      (NXTLIN),HL               ; store pointer in system variable NXTLIN

        EX      DE,HL                     ; bring back pointer to previous or edit line
        LD      (CH_ADD),HL               ; and update CH_ADD with character address.

        LD      D,A                       ; store statement in D.
        LD      E,$00                     ; set E to zero to suppress token searching
                                          ; if EACH-STMT is to be called.
        LD      (IY+(NSPPC-C_IY)),$FF     ; set statement NSPPC to $FF signalling
                                          ; no jump to be made.
        DEC     D                         ; decrement and test statement
        LD      (IY+(SUBPPC-C_IY)),D      ; set SUBPPC to decremented statement number.
        JP      Z,stmt_loop               ; to STMT-LOOP if result zero as statement is
                                          ; at start of line and address is known.

        INC     D                         ; else restore statement.
        CALL    each_stmt                 ; routine EACH-STMT finds the D'th statement
                                          ; address as E does not contain a token.
        JR      Z,stmt_next               ; forward to STMT-NEXT if address found.

report_n:
        RST     08H                       ; ERROR-1
        DEFB    $16                       ; Error Report: Statement lost

; -----------------
; End of statement?
; -----------------
; This combination of routines is called from 20 places when
; the end of a statement should have been reached and all preceding
; syntax is in order.

check_end:
        CALL    syntax_z                  ; routine SYNTAX-Z
        RET     NZ                        ; return immediately in runtime

        POP     BC                        ; drop address of calling routine.
        POP     BC                        ; drop address STMT-RET.
                                          ; and continue to find next statement.

; --------------------
; Go to next statement
; --------------------
; Acceptable characters at this point are carriage return and ':'.
; If so go to next statement which in the first case will be on next line.

stmt_next:
        CALL    next_stmt_patch           ; Spectrum 128 patch

        JR      Z,line_end                ; back to LINE-END if so.

        CP      $3A                       ; is it ':' ?
        JP      Z,stmt_loop               ; jump back to STMT-LOOP to consider
                                          ; further statements

        JP      report_c                  ; jump to REPORT-C with any other character
                                          ; 'Nonsense in BASIC'.

; Note. the two-byte sequence 'rst 08; defb $0b' could replace the above jp.

; -------------------
; Command class table
; -------------------
;

class_tbl:
        DEFB    class_00 - $              ; 0F offset to Address: CLASS-00
        DEFB    class_01 - $              ; 1D offset to Address: CLASS-01
        DEFB    class_02 - $              ; 4B offset to Address: CLASS-02
        DEFB    class_03 - $              ; 09 offset to Address: CLASS-03
        DEFB    class_04 - $              ; 67 offset to Address: CLASS-04
        DEFB    class_05 - $              ; 0B offset to Address: CLASS-05
        DEFB    class_06 - $              ; 7B offset to Address: CLASS-06
        DEFB    class_07 - $              ; 8E offset to Address: CLASS-07
        DEFB    class_08 - $              ; 71 offset to Address: CLASS-08
        DEFB    class_09 - $              ; B4 offset to Address: CLASS-09
        DEFB    class_0a - $              ; 81 offset to Address: CLASS-0A
        DEFB    class_0b - $              ; CF offset to Address: CLASS-0B


; --------------------------------
; Command classes---00, 03, and 05
; --------------------------------
; class-03 e.g RUN or RUN 200   ;  optional operand
; class-00 e.g CONTINUE         ;  no operand
; class-05 e.g PRINT            ;  variable syntax checked by routine

class_03:
        CALL    fetch_num                 ; routine FETCH-NUM

class_00:

        CP      A                         ; reset zero flag.

; if entering here then all class routines are entered with zero reset.

class_05:
        POP     BC                        ; drop address SCAN-LOOP.
        CALL    Z,check_end               ; if zero set then call routine CHECK-END >>>
                                          ; as should be no further characters.

        EX      DE,HL                     ; save HL to DE.
        LD      HL,(T_ADDR)               ; fetch T_ADDR
        LD      C,(HL)                    ; fetch low byte of routine
        INC     HL                        ; address next.
        LD      B,(HL)                    ; fetch high byte of routine.
        EX      DE,HL                     ; restore HL from DE
        PUSH    BC                        ; push the address
        RET                               ; and make an indirect jump to the command.

; --------------------------------
; Command classes---01, 02, and 04
; --------------------------------
; class-01  e.g LET A = 2*3     ; a variable is reqd

; This class routine is also called from INPUT and READ to find the
; destination variable for an assignment.

class_01:
        CALL    look_vars                 ; routine LOOK-VARS returns carry set if not
                                          ; found in runtime.

; ----------------------
; Variable in assignment
; ----------------------
;
;

var_a_1:
        LD      (IY+(FLAGX-C_IY)),$00     ; set FLAGX to zero
        JR      NC,var_a_2                ; forward to VAR-A-2 if found or checking
                                          ; syntax.

        SET     1,(IY+(FLAGX-C_IY))       ; FLAGX  - Signal a new variable
        JR      NZ,var_a_3                ; to VAR-A-3 if not assigning to an array
                                          ; e.g. LET a$(3,3) = "X"

report_2:
        RST     08H                       ; ERROR-1
        DEFB    $01                       ; Error Report: Variable not found

var_a_2:
        CALL    Z,stk_var                 ; routine STK-VAR considers a subscript/slice
        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS  - Numeric or string result ?
        JR      NZ,var_a_3                ; to VAR-A-3 if numeric

        XOR     A                         ; default to array/slice - to be retained.
        CALL    syntax_z                  ; routine SYNTAX-Z
        CALL    NZ,stk_fetch              ; routine STK-FETCH is called in runtime
                                          ; may overwrite A with 1.
        LD      HL,FLAGX                  ; address system variable FLAGX
        OR      (HL)                      ; set bit 0 if simple variable to be reclaimed
        LD      (HL),A                    ; update FLAGX
        EX      DE,HL                     ; start of string/subscript to DE

var_a_3:
        LD      (STRLEN),BC               ; update STRLEN
        LD      (DEST),HL                 ; and DEST of assigned string.
        RET                               ; return.

; -------------------------------------------------
; class-02 e.g. LET a = 1 + 1   ; an expression must follow

class_02:
        POP     BC                        ; drop return address SCAN-LOOP
        CALL    val_fet_1                 ; routine VAL-FET-1 is called to check
                                          ; expression and assign result in runtime
        CALL    check_end                 ; routine CHECK-END checks nothing else
                                          ; is present in statement.
        RET                               ; Return

; -------------
; Fetch a value
; -------------
;
;

val_fet_1:
        LD      A,(FLAGS)                 ; initial FLAGS to A

val_fet_2:
        PUSH    AF                        ; save A briefly
        CALL    scanning                  ; routine SCANNING evaluates expression.
        POP     AF                        ; restore A
        LD      D,(IY+(FLAGS-C_IY))       ; post-SCANNING FLAGS to D
        XOR     D                         ; xor the two sets of flags
        AND     $40                       ; pick up bit 6 of xored FLAGS should be zero
        JR      NZ,report_c               ; forward to REPORT-C if not zero
                                          ; 'Nonsense in BASIC' - results don't agree.

        BIT     7,D                       ; test FLAGS - is syntax being checked ?
        JP      NZ,let                    ; jump forward to LET to make the assignment
                                          ; in runtime.

        RET                               ; but return from here if checking syntax.

; ------------------
; Command class---04
; ------------------
; class-04 e.g. FOR i            ; a single character variable must follow

class_04:
        CALL    look_vars                 ; routine LOOK-VARS
        PUSH    AF                        ; preserve flags.
        LD      A,C                       ; fetch type - should be 011xxxxx
        OR      $9F                       ; combine with 10011111.
        INC     A                         ; test if now $FF by incrementing.
        JR      NZ,report_c               ; forward to REPORT-C if result not zero.

        POP     AF                        ; else restore flags.
        JR      var_a_1                   ; back to VAR-A-1


; --------------------------------
; Expect numeric/string expression
; --------------------------------
; This routine is used to get the two coordinates of STRING$, ATTR and POINT.
; It is also called from PRINT-ITEM to get the two numeric expressions that
; follow the AT ( in PRINT AT, INPUT AT).

next_2num:
        RST     20H                       ; NEXT-CHAR advance past 'AT' or '('.

; --------
; class-08 e.g POKE 65535,2     ; two numeric expressions separated by comma
class_08:
expt_2num:
        CALL    expt_1num                 ; routine EXPT-1NUM is called for first
                                          ; numeric expression
        CP      $2C                       ; is character ',' ?
        JR      NZ,report_c               ; to REPORT-C if not required separator.
                                          ; 'Nonsense in BASIC'.

        RST     20H                       ; NEXT-CHAR

; ->
;  class-06  e.g. GOTO a*1000   ; a numeric expression must follow
class_06:
expt_1num:
        CALL    scanning                  ; routine SCANNING
        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS  - Numeric or string result ?
        RET     NZ                        ; return if result is numeric.

report_c:
        RST     08H                       ; ERROR-1
        DEFB    $0B                       ; Error Report: Nonsense in BASIC

; ---------------------------------------------------------------
; class-0A e.g. ERASE "????"    ; a string expression must follow.
;                               ; these only occur in unimplemented commands
;                               ; although the routine expt-exp is called
;                               ; from SAVE-ETC

class_0a:
expt_exp:
        CALL    scanning                  ; routine SCANNING
        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS  - Numeric or string result ?
        RET     Z                         ; return if string result.

        JR      report_c                  ; back to REPORT-C if numeric.

; ---------------------
; Set permanent colours
; class 07
; ---------------------
; class-07 e.g PAPER 6          ; a single class for a collection of
;                               ; similar commands. Clever.
;
; Note. these commands should ensure that current channel is 'S'

class_07:
        BIT     7,(IY+(FLAGS-C_IY))       ; test FLAGS - checking syntax only ?
        RES     0,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG - signal main screen in use
        CALL    NZ,temps                  ; routine TEMPS is called in runtime.
        POP     AF                        ; drop return address SCAN-LOOP
        LD      A,(T_ADDR)                ; T_ADDR_lo to accumulator.
                                          ; points to '$07' entry + 1
                                          ; e.g. for INK points to $EC now

; Note if you move alter the syntax table next line may have to be altered.

; Note. For ZASM assembler replace following expression with SUB $13.

        SUB     (p_ink-$D8)&$FF           ; convert $EB to $D8 ('INK') etc.
                                          ; ( is SUB $13 in standard ROM )

        CALL    co_temp_4                 ; routine CO-TEMP-4
        CALL    check_end                 ; routine CHECK-END check that nothing else
                                          ; in statement.

; return here in runtime.

        LD      HL,(ATTR_T)               ; pick up ATTR_T and MASK_T
        LD      (ATTR_P),HL               ; and store in ATTR_P and MASK_P
        LD      HL,P_FLAG                 ; point to P_FLAG.
        LD      A,(HL)                    ; pick up in A
        RLCA                              ; rotate to left
        XOR     (HL)                      ; combine with HL
        AND     $AA                       ; 10101010
        XOR     (HL)                      ; only permanent bits affected
        LD      (HL),A                    ; reload into P_FLAG.
        RET                               ; return.

; ------------------
; Command class---09
; ------------------
; e.g. PLOT PAPER 0; 128,88     ; two coordinates preceded by optional
;                               ; embedded colour items.
;
; Note. this command should ensure that current channel is actually 'S'.

class_09:
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,cl_09_1                 ; forward to CL-09-1 if checking syntax.

        RES     0,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG - signal main screen in use
        CALL    temps                     ; routine TEMPS is called.
        LD      HL,MASK_T                 ; point to MASK_T
        LD      A,(HL)                    ; fetch mask to accumulator.
        OR      $F8                       ; or with 11111000 paper/bright/flash 8
        LD      (HL),A                    ; mask back to MASK_T system variable.
        RES     6,(IY+(P_FLAG-C_IY))      ; reset P_FLAG  - signal NOT PAPER 9 ?

        RST     18H                       ; GET-CHAR

cl_09_1:
        CALL    co_temp_2                 ; routine CO-TEMP-2 deals with any embedded
                                          ; colour items.
        JR      expt_2num                 ; exit via EXPT-2NUM to check for x,y.

; Note. if either of the numeric expressions contain STR$ then the flag setting
; above will be undone when the channel flags are reset during STR$.
; e.g.
; 10 BORDER 3 : PLOT VAL STR$ 128, VAL STR$ 100
; credit John Elliott.

; ------------------
; Command class---0B
; ------------------
; Again a single class for four commands.
; This command just jumps back to SAVE-ETC to handle the four tape commands.
; The routine itself works out which command has called it by examining the
; address in T_ADDR_lo. Note therefore that the syntax table has to be
; located where these and other sequential command addresses are not split
; over a page boundary.

class_0b:
        JP      save_etc                  ; jump way back to SAVE-ETC

; --------------
; Fetch a number
; --------------
; This routine is called from CLASS-03 when a command may be followed by
; an optional numeric expression e.g. RUN. If the end of statement has
; been reached then zero is used as the default.
; Also called from LIST-4.

fetch_num:
        CP      $0D                       ; is character a carriage return ?
        JR      Z,use_zero                ; forward to USE-ZERO if so

        CP      $3A                       ; is it ':' ?
        JR      NZ,expt_1num              ; forward to EXPT-1NUM if not.
                                          ; else continue and use zero.

; ----------------
; Use zero routine
; ----------------
; This routine is called four times to place the value zero on the
; calculator stack as a default value in runtime.

use_zero:
        CALL    syntax_z                  ; routine SYNTAX-Z  (UNSTACK-Z?)
        RET     Z                         ;

        RST     28H                       ;; FP-CALC
        DEFB    $A0                       ;;stk-zero       ;0.
        DEFB    $38                       ;;end-calc

        RET                               ; return.

; -------------------
; Handle STOP command
; -------------------
; Command Syntax: STOP
; One of the shortest and least used commands. As with 'OK' not an error.

stop:
        RST     08H                       ; ERROR-1
        DEFB    $08                       ; Error Report: STOP statement

; -----------------
; Handle IF command
; -----------------
; e.g. IF score>100 THEN PRINT "You Win"
; The parser has already checked the expression the result of which is on
; the calculator stack. The presence of the 'THEN' separator has also been
; checked and CH-ADD points to the command after THEN.
;

if:
        POP     BC                        ; drop return address - STMT-RET
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,if_1                    ; forward to IF-1 if checking syntax
                                          ; to check syntax of PRINT "You Win"


        RST     28H                       ;; FP-CALC    score>100 (1=TRUE 0=FALSE)
        DEFB    $02                       ;;delete      .
        DEFB    $38                       ;;end-calc

        EX      DE,HL                     ; make HL point to deleted value
        CALL    test_zero                 ; routine TEST-ZERO
        JP      C,line_end                ; jump to LINE-END if FALSE (0)

if_1:
        JP      stmt_l_1                  ; to STMT-L-1, if true (1) to execute command
                                          ; after 'THEN' token.

; ------------------
; Handle FOR command
; ------------------
; e.g. FOR i = 0 TO 1 STEP 0.1
; Using the syntax tables, the parser has already checked for a start and
; limit value and also for the intervening separator.
; the two values v,l are on the calculator stack.
; CLASS-04 has also checked the variable and the name is in STRLEN_lo.
; The routine begins by checking for an optional STEP.

for:
        CP      $CD                       ; is there a 'STEP' ?
        JR      NZ,f_use_1                ; to F-USE-1 if not to use 1 as default.

        RST     20H                       ; NEXT-CHAR
        CALL    expt_1num                 ; routine EXPT-1NUM
        CALL    check_end                 ; routine CHECK-END
        JR      f_reorder                 ; to F-REORDER

; ---

f_use_1:
        CALL    check_end                 ; routine CHECK-END

        RST     28H                       ;; FP-CALC      v,l.
        DEFB    $A1                       ;;stk-one       v,l,1=s.
        DEFB    $38                       ;;end-calc


f_reorder:
        RST     28H                       ;; FP-CALC       v,l,s.
        DEFB    $C0                       ;;st-mem-0       v,l,s.
        DEFB    $02                       ;;delete         v,l.
        DEFB    $01                       ;;exchange       l,v.
        DEFB    $E0                       ;;get-mem-0      l,v,s.
        DEFB    $01                       ;;exchange       l,s,v.
        DEFB    $38                       ;;end-calc

        CALL    let                       ; routine LET assigns the initial value v to
                                          ; the variable altering type if necessary.
        LD      (MEM),HL                  ; The system variable MEM is made to point to
                                          ; the variable instead of its normal
                                          ; location MEMBOT
        DEC     HL                        ; point to single-character name
        LD      A,(HL)                    ; fetch name
        SET     7,(HL)                    ; set bit 7 at location
        LD      BC,$0006                  ; add six to HL
        ADD     HL,BC                     ; to address where limit should be.
        RLCA                              ; test bit 7 of original name.
        JR      C,f_l_s                   ; forward to F-L-S if already a FOR/NEXT
                                          ; variable

        LD      C,$0D                     ; otherwise an additional 13 bytes are needed.
                                          ; 5 for each value, two for line number and
                                          ; 1 byte for looping statement.
        CALL    make_room                 ; routine MAKE-ROOM creates them.
        INC     HL                        ; make HL address limit.

f_l_s:
        PUSH    HL                        ; save position.

        RST     28H                       ;; FP-CALC         l,s.
        DEFB    $02                       ;;delete           l.
        DEFB    $02                       ;;delete           .
        DEFB    $38                       ;;end-calc
                                          ; DE points to STKEND, l.

        POP     HL                        ; restore variable position
        EX      DE,HL                     ; swap pointers
        LD      C,$0A                     ; ten bytes to move
        LDIR                              ; Copy 'deleted' values to variable.
        LD      HL,(PPC)                  ; Load with current line number from PPC
        EX      DE,HL                     ; exchange pointers.
        LD      (HL),E                    ; save the looping line
        INC     HL                        ; in the next
        LD      (HL),D                    ; two locations.
        LD      D,(IY+(SUBPPC-C_IY))      ; fetch statement from SUBPPC system variable.
        INC     D                         ; increment statement.
        INC     HL                        ; and pointer
        LD      (HL),D                    ; and store the looping statement.
                                          ;
        CALL    next_loop                 ; routine NEXT-LOOP considers an initial
        RET     NC                        ; iteration. Return to STMT-RET if a loop is
                                          ; possible to execute next statement.

; no loop is possible so execution continues after the matching 'NEXT'

        LD      B,(IY+(STRLEN-C_IY))      ; get single-character name from STRLEN_lo
        LD      HL,(PPC)                  ; get the current line from PPC
        LD      (NEWPPC),HL               ; and store it in NEWPPC
        LD      A,(SUBPPC)                ; fetch current statement from SUBPPC
        NEG                               ; Negate as counter decrements from zero
                                          ; initially and we are in the middle of a
                                          ; line.
        LD      D,A                       ; Store result in D.
        LD      HL,(CH_ADD)               ; get current address from CH_ADD
        LD      E,$F3                     ; search will be for token 'NEXT'

f_loop:
        PUSH    BC                        ; save variable name.
        LD      BC,(NXTLIN)               ; fetch NXTLIN
        CALL    look_prog                 ; routine LOOK-PROG searches for 'NEXT' token.
        LD      (NXTLIN),BC               ; update NXTLIN
        POP     BC                        ; and fetch the letter
        JR      C,report_i                ; forward to REPORT-I if the end of program
                                          ; was reached by LOOK-PROG.
                                          ; 'FOR without NEXT'

        RST     20H                       ; NEXT-CHAR fetches character after NEXT
        OR      $20                       ; ensure it is upper-case.
        CP      B                         ; compare with FOR variable name
        JR      Z,f_found                 ; forward to F-FOUND if it matches.

; but if no match i.e. nested FOR/NEXT loops then continue search.

        RST     20H                       ; NEXT-CHAR
        JR      f_loop                    ; back to F-LOOP

; ---


f_found:
        RST     20H                       ; NEXT-CHAR
        LD      A,$01                     ; subtract the negated counter from 1
        SUB     D                         ; to give the statement after the NEXT
        LD      (NSPPC),A                 ; set system variable NSPPC
        RET                               ; return to STMT-RET to branch to new
                                          ; line and statement. ->
; ---

report_i:
        RST     08H                       ; ERROR-1
        DEFB    $11                       ; Error Report: FOR without NEXT

; ---------
; LOOK-PROG
; ---------
; Find DATA, DEF FN or NEXT.
; This routine searches the program area for one of the above three keywords.
; On entry, HL points to start of search area.
; The token is in E, and D holds a statement count, decremented from zero.

look_prog:
        LD      A,(HL)                    ; fetch current character
        CP      $3A                       ; is it ':' a statement separator ?
        JR      Z,look_p_2                ; forward to LOOK-P-2 if so.

; The starting point was PROG - 1 or the end of a line.

look_p_1:
        INC     HL                        ; increment pointer to address
        LD      A,(HL)                    ; the high byte of line number
        AND     $C0                       ; test for program end marker $80 or a
                                          ; variable
        SCF                               ; Set Carry Flag
        RET     NZ                        ; return with carry set if at end
                                          ; of program.           ->

        LD      B,(HL)                    ; high byte of line number to B
        INC     HL                        ;
        LD      C,(HL)                    ; low byte to C.
        LD      (NEWPPC),BC               ; set system variable NEWPPC.
        INC     HL                        ;
        LD      C,(HL)                    ; low byte of line length to C.
        INC     HL                        ;
        LD      B,(HL)                    ; high byte to B.
        PUSH    HL                        ; save address
        ADD     HL,BC                     ; add length to position.
        LD      B,H                       ; and save result
        LD      C,L                       ; in BC.
        POP     HL                        ; restore address.
        LD      D,$00                     ; initialize statement counter to zero.

look_p_2:
        PUSH    BC                        ; save address of next line
        CALL    each_stmt                 ; routine EACH-STMT searches current line.
        POP     BC                        ; restore address.
        RET     NC                        ; return if match was found. ->

        JR      look_p_1                  ; back to LOOK-P-1 for next line.

; -------------------
; Handle NEXT command
; -------------------
; e.g. NEXT i
; The parameter tables have already evaluated the presence of a variable

next:
        BIT     1,(IY+(FLAGX-C_IY))       ; test FLAGX - handling a new variable ?
        JP      NZ,report_2               ; jump back to REPORT-2 if so
                                          ; 'Variable not found'

; now test if found variable is a simple variable uninitialized by a FOR.

        LD      HL,(DEST)                 ; load address of variable from DEST
        BIT     7,(HL)                    ; is it correct type ?
        JR      Z,report_1                ; forward to REPORT-1 if not
                                          ; 'NEXT without FOR'

        INC     HL                        ; step past variable name
        LD      (MEM),HL                  ; and set MEM to point to three 5-byte values
                                          ; value, limit, step.

        RST     28H                       ;; FP-CALC     add step and re-store
        DEFB    $E0                       ;;get-mem-0    v.
        DEFB    $E2                       ;;get-mem-2    v,s.
        DEFB    $0F                       ;;addition     v+s.
        DEFB    $C0                       ;;st-mem-0     v+s.
        DEFB    $02                       ;;delete       .
        DEFB    $38                       ;;end-calc

        CALL    next_loop                 ; routine NEXT-LOOP tests against limit.
        RET     C                         ; return if no more iterations possible.

        LD      HL,(MEM)                  ; find start of variable contents from MEM.
        LD      DE,$000F                  ; add 3*5 to
        ADD     HL,DE                     ; address the looping line number
        LD      E,(HL)                    ; low byte to E
        INC     HL                        ;
        LD      D,(HL)                    ; high byte to D
        INC     HL                        ; address looping statement
        LD      H,(HL)                    ; and store in H
        EX      DE,HL                     ; swap registers
        JP      go_to_2                   ; exit via GO-TO-2 to execute another loop.

; ---

report_1:
        RST     08H                       ; ERROR-1
        DEFB    $00                       ; Error Report: NEXT without FOR


; -----------------
; Perform NEXT loop
; -----------------
; This routine is called from the FOR command to test for an initial
; iteration and from the NEXT command to test for all subsequent iterations.
; the system variable MEM addresses the variable's contents which, in the
; latter case, have had the step, possibly negative, added to the value.

next_loop:
        RST     28H                       ;; FP-CALC
        DEFB    $E1                       ;;get-mem-1        l.
        DEFB    $E0                       ;;get-mem-0        l,v.
        DEFB    $E2                       ;;get-mem-2        l,v,s.
        DEFB    $36                       ;;less-0           l,v,(1/0) negative step ?
        DEFB    $00                       ;;jump-true        l,v.(1/0)

        DEFB    $02                       ;;to next_1, NEXT-1 if step negative

        DEFB    $01                       ;;exchange         v,l.

next_1:
        DEFB    $03                       ;;subtract         l-v OR v-l.
        DEFB    $37                       ;;greater-0        (1/0)
        DEFB    $00                       ;;jump-true        .

        DEFB    $04                       ;;to next_2, NEXT-2 if no more iterations.

        DEFB    $38                       ;;end-calc         .

        AND     A                         ; clear carry flag signalling another loop.
        RET                               ; return

; ---

next_2:
        DEFB    $38                       ;;end-calc         .

        SCF                               ; set carry flag signalling looping exhausted.
        RET                               ; return


; -------------------
; Handle READ command
; -------------------
; e.g. READ a, b$, c$(1000 TO 3000)
; A list of comma-separated variables is assigned from a list of
; comma-separated expressions.
; As it moves along the first list, the character address CH_ADD is stored
; in X_PTR while CH_ADD is used to read the second list.

read_3:
        RST     20H                       ; NEXT-CHAR

; -> Entry point.
read:
        CALL    class_01                  ; routine CLASS-01 checks variable.
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,read_2                  ; forward to READ-2 if checking syntax


        RST     18H                       ; GET-CHAR
        LD      (X_PTR),HL                ; save character position in X_PTR.
        LD      HL,(DATADD)               ; load HL with Data Address DATADD, which is
                                          ; the start of the program or the address
                                          ; after the last expression that was read or
                                          ; the address of the line number of the
                                          ; last RESTORE command.
        LD      A,(HL)                    ; fetch character
        CP      $2C                       ; is it a comma ?
        JR      Z,read_1                  ; forward to READ-1 if so.

; else all data in this statement has been read so look for next DATA token

        LD      E,$E4                     ; token 'DATA'
        CALL    look_prog                 ; routine LOOK-PROG
        JR      NC,read_1                 ; forward to READ-1 if DATA found

; else report the error.

report_e:
        RST     08H                       ; ERROR-1
        DEFB    $0D                       ; Error Report: Out of DATA

read_1:
        CALL    temp_ptr1                 ; routine TEMP-PTR1 advances updating CH_ADD
                                          ; with new DATADD position.
        CALL    val_fet_1                 ; routine VAL-FET-1 assigns value to variable
                                          ; checking type match and adjusting CH_ADD.

        RST     18H                       ; GET-CHAR fetches adjusted character position
        LD      (DATADD),HL               ; store back in DATADD
        LD      HL,(X_PTR)                ; fetch X_PTR  the original READ CH_ADD
        LD      (IY+(X_PTR_hi-C_IY)),$00  ; now nullify X_PTR_hi
        CALL    temp_ptr2                 ; routine TEMP-PTR2 restores READ CH_ADD

read_2:
        RST     18H                       ; GET-CHAR
        CP      $2C                       ; is it ',' indicating more variables to read ?
        JR      Z,read_3                  ; back to READ-3 if so

        CALL    check_end                 ; routine CHECK-END
        RET                               ; return from here in runtime to STMT-RET.

; -------------------
; Handle DATA command
; -------------------
; In runtime this 'command' is passed by but the syntax is checked when such
; a statement is found while parsing a line.
; e.g. DATA 1, 2, "text", score-1, a$(location, room, object), FN r(49),
;         wages - tax, TRUE, The meaning of life

data:
        CALL    syntax_z                  ; routine SYNTAX-Z to check status
        JR      NZ,data_2                 ; forward to DATA-2 if in runtime

data_1:
        CALL    scanning                  ; routine SCANNING to check syntax of
                                          ; expression
        CP      $2C                       ; is it a comma ?
        CALL    NZ,check_end              ; routine CHECK-END checks that statement
                                          ; is complete. Will make an early exit if
                                          ; so. >>>
        RST     20H                       ; NEXT-CHAR
        JR      data_1                    ; back to DATA-1

; ---

data_2:
        LD      A,$E4                     ; set token to 'DATA' and continue into
                                          ; the the PASS-BY routine.


; ----------------------------------
; Check statement for DATA or DEF FN
; ----------------------------------
; This routine is used to backtrack to a command token and then
; forward to the next statement in runtime.

pass_by:
        LD      B,A                       ; Give BC enough space to find token.
        CPDR                              ; Compare decrement and repeat. (Only use).
                                          ; Work backwards till keyword is found which
                                          ; is start of statement before any quotes.
                                          ; HL points to location before keyword.
        LD      DE,$0200                  ; count 1+1 statements, dummy value in E to
                                          ; inhibit searching for a token.
        JP      each_stmt                 ; to EACH-STMT to find next statement

; -----------------------------------------------------------------------
; A General Note on Invalid Line Numbers.
; =======================================
; One of the revolutionary concepts of Sinclair BASIC was that it supported
; virtual line numbers. That is the destination of a GO TO, RESTORE etc. need
; not exist. It could be a point before or after an actual line number.
; Zero suffices for a before but the after should logically be infinity.
; Since the maximum actual line limit is 9999 then the system limit, 16383
; when variables kick in, would serve fine as a virtual end point.
; However, ironically, only the LOAD command gets it right. It will not
; autostart a program that has been saved with a line higher than 16383.
; All the other commands deal with the limit unsatisfactorily.
; LIST, RUN, GO TO, GO SUB and RESTORE have problems and the latter may
; crash the machine when supplied with an inappropriate virtual line number.
; This is puzzling as very careful consideration must have been given to
; this point when the new variable types were allocated their masks and also
; when the routine NEXT-ONE was successfully re-written to reflect this.
; An enigma.
; -------------------------------------------------------------------------

; ----------------------
; Handle RESTORE command
; ----------------------
; The restore command sets the system variable for the data address to
; point to the location before the supplied line number or first line
; thereafter.
; This alters the position where subsequent READ commands look for data.
; Note. If supplied with inappropriate high numbers the system may crash
; in the LINE-ADDR routine as it will pass the program/variables end-marker
; and then lose control of what it is looking for - variable or line number.
; - observation, Steven Vickers, 1984, Pitman.

restore:
        CALL    find_int2                 ; routine FIND-INT2 puts integer in BC.
                                          ; Note. B should be checked against limit $3F
                                          ; and an error generated if higher.

; this entry point is used from RUN command with BC holding zero

rest_run:
        LD      H,B                       ; transfer the line
        LD      L,C                       ; number to the HL register.
        CALL    line_addr                 ; routine LINE-ADDR to fetch the address.
        DEC     HL                        ; point to the location before the line.
        LD      (DATADD),HL               ; update system variable DATADD.
        RET                               ; return to STMT-RET (or RUN)

; ------------------------
; Handle RANDOMIZE command
; ------------------------
; This command sets the SEED for the RND function to a fixed value.
; With the parameter zero, a random start point is used depending on
; how long the computer has been switched on.

randomize:
        CALL    find_int2                 ; routine FIND-INT2 puts parameter in BC.
        LD      A,B                       ; test this
        OR      C                         ; for zero.
        JR      NZ,rand_1                 ; forward to RAND-1 if not zero.

        LD      BC,(FRAMES)               ; use the lower two bytes at FRAMES1.

rand_1:
        LD      (SEED),BC                 ; place in SEED system variable.
        RET                               ; return to STMT-RET

; -----------------------
; Handle CONTINUE command
; -----------------------
; The CONTINUE command transfers the OLD (but incremented) values of
; line number and statement to the equivalent "NEW VALUE" system variables
; by using the last part of GO TO and exits indirectly to STMT-RET.

continue:
        LD      HL,(OLDPPC)               ; fetch OLDPPC line number.
        LD      D,(IY+(OSPPC-C_IY))       ; fetch OSPPC statement.
        JR      go_to_2                   ; forward to GO-TO-2

; --------------------
; Handle GO TO command
; --------------------
; The GO TO command routine is also called by GO SUB and RUN routines
; to evaluate the parameters of both commands.
; It updates the system variables used to fetch the next line/statement.
; It is at STMT-RET that the actual change in control takes place.
; Unlike some BASICs the line number need not exist.
; Note. the high byte of the line number is incorrectly compared with $F0
; instead of $3F. This leads to commands with operands greater than 32767
; being considered as having been run from the editing area and the
; error report 'Statement Lost' is given instead of 'OK'.
; - Steven Vickers, 1984.

go_to:
        CALL    find_int2                 ; routine FIND-INT2 puts operand in BC
        LD      H,B                       ; transfer line
        LD      L,C                       ; number to HL.
        LD      D,$00                     ; set statement to 0 - first.
        LD      A,H                       ; compare high byte only
        CP      $F0                       ; to $F0 i.e. 61439 in full.
        JR      NC,report_bb              ; forward to REPORT-B if above.

; This call entry point is used to update the system variables e.g. by RETURN.

go_to_2:
        LD      (NEWPPC),HL               ; save line number in NEWPPC
        LD      (IY+(NSPPC-C_IY)),D       ; and statement in NSPPC
        RET                               ; to STMT-RET (or GO-SUB command)

; ------------------
; Handle OUT command
; ------------------
; Syntax has been checked and the two comma-separated values are on the
; calculator stack.

cout:
        CALL    two_param                 ; routine TWO-PARAM fetches values
                                          ; to BC and A.
        OUT     (C),A                     ; perform the operation.
        RET                               ; return to STMT-RET.

; -------------------
; Handle POKE command
; -------------------
; This routine alters a single byte in the 64K address space.
; Happily no check is made as to whether ROM or RAM is addressed.
; Sinclair BASIC requires no poking of system variables.

poke:
        CALL    two_param                 ; routine TWO-PARAM fetches values
                                          ; to BC and A.
        LD      (BC),A                    ; load memory location with A.
        RET                               ; return to STMT-RET.

; ------------------------------------
; Fetch two  parameters from calculator stack
; ------------------------------------
; This routine fetches a byte and word from the calculator stack
; producing an error if either is out of range.

two_param:
        CALL    fp_to_a                   ; routine FP-TO-A
        JR      C,report_bb               ; forward to REPORT-B if overflow occurred

        JR      Z,two_p_1                 ; forward to TWO-P-1 if positive

        NEG                               ; negative numbers are made positive

two_p_1:
        PUSH    AF                        ; save the value
        CALL    find_int2                 ; routine FIND-INT2 gets integer to BC
        POP     AF                        ; restore the value
        RET                               ; return

; -------------
; Find integers
; -------------
; The first of these routines fetches a 8-bit integer (range 0-255) from the
; calculator stack to the accumulator and is used for colours, streams,
; durations and coordinates.
; The second routine fetches 16-bit integers to the BC register pair
; and is used to fetch command and function arguments involving line numbers
; or memory addresses and also array subscripts and tab arguments.
; ->

find_int1:
        CALL    fp_to_a                   ; routine FP-TO-A
        JR      find_i_1                  ; forward to FIND-I-1 for common exit routine.

; ---

; ->

find_int2:
        CALL    fp_to_bc                  ; routine FP-TO-BC

find_i_1:
        JR      C,report_bb               ; to REPORT-Bb with overflow.

        RET     Z                         ; return if positive.


report_bb:
        RST     08H                       ; ERROR-1
        DEFB    $0A                       ; Error Report: Integer out of range

; ------------------
; Handle RUN command
; ------------------
; This command runs a program starting at an optional line.
; It performs a 'RESTORE 0' then CLEAR

run:
        CALL    go_to                     ; routine GO-TO puts line number in
                                          ; system variables.
        LD      BC,$0000                  ; prepare to set DATADD to first line.
        CALL    rest_run                  ; routine REST-RUN does the 'restore'.
                                          ; Note BC still holds zero.
        JR      clear_run                 ; forward to CLEAR-RUN to clear variables
                                          ; without disturbing RAMTOP and
                                          ; exit indirectly to STMT-RET

; --------------------
; Handle CLEAR command
; --------------------
; This command reclaims the space used by the variables.
; It also clears the screen and the GO SUB stack.
; With an integer expression, it sets the uppermost memory
; address within the BASIC system.
; "Contrary to the manual, CLEAR doesn't execute a RESTORE" -
; Steven Vickers, Pitman Pocket Guide to the Spectrum, 1984.

clear:
        CALL    find_int2                 ; routine FIND-INT2 fetches to BC.

clear_run:
        LD      A,B                       ; test for
        OR      C                         ; zero.
        JR      NZ,clear_1                ; skip to CLEAR-1 if not zero.

        LD      BC,(RAMTOP)               ; use the existing value of RAMTOP if zero.

clear_1:
        PUSH    BC                        ; save ramtop value.

        LD      DE,(VARS)                 ; fetch VARS
        LD      HL,(E_LINE)               ; fetch E_LINE
        DEC     HL                        ; adjust to point at variables end-marker.
        CALL    reclaim_1                 ; routine RECLAIM-1 reclaims the space used by
                                          ; the variables.
        CALL    cls                       ; routine CLS to clear screen.
        LD      HL,(STKEND)               ; fetch STKEND the start of free memory.
        LD      DE,$0032                  ; allow for another 50 bytes.
        ADD     HL,DE                     ; add the overhead to HL.

        POP     DE                        ; restore the ramtop value.
        SBC     HL,DE                     ; if HL is greater than the value then jump
        JR      NC,report_m               ; forward to REPORT-M
                                          ; 'RAMTOP no good'

        LD      HL,(P_RAMT)               ; now P-RAMT ($7FFF on 16K RAM machine)
        AND     A                         ; exact this time.
        SBC     HL,DE                     ; new ramtop must be lower or the same.
        JR      NC,clear_2                ; skip to CLEAR-2 if in actual RAM.

report_m:
        RST     08H                       ; ERROR-1
        DEFB    $15                       ; Error Report: RAMTOP no good

clear_2:
        EX      DE,HL                     ; transfer ramtop value to HL.
        LD      (RAMTOP),HL               ; update system variable RAMTOP.
        POP     DE                        ; pop the return address STMT-RET.
        POP     BC                        ; pop the Error Address.
        LD      (HL),$3E                  ; now put the GO SUB end-marker at RAMTOP.
        DEC     HL                        ; leave a location beneath it.
        LD      SP,HL                     ; initialize the machine stack pointer.
        PUSH    BC                        ; push the error address.
        LD      (ERR_SP),SP               ; make ERR_SP point to location.
        EX      DE,HL                     ; put STMT-RET in HL.
        JP      (HL)                      ; and go there directly.

; ---------------------
; Handle GO SUB command
; ---------------------
; The GO SUB command diverts BASIC control to a new line number
; in a very similar manner to GO TO but
; the current line number and current statement + 1
; are placed on the GO SUB stack as a RETURN point.

go_sub:
        POP     DE                        ; drop the address STMT-RET
        LD      H,(IY+(SUBPPC-C_IY))      ; fetch statement from SUBPPC and
        INC     H                         ; increment it
        EX      (SP),HL                   ; swap - error address to HL,
                                          ; H (statement) at top of stack,
                                          ; L (unimportant) beneath.
        INC     SP                        ; adjust to overwrite unimportant byte
        LD      BC,(PPC)                  ; fetch the current line number from PPC
        PUSH    BC                        ; and PUSH onto GO SUB stack.
                                          ; the empty machine-stack can be rebuilt
        PUSH    HL                        ; push the error address.
        LD      (ERR_SP),SP               ; make system variable ERR_SP point to it.
        PUSH    DE                        ; push the address STMT-RET.
        CALL    go_to                     ; call routine GO-TO to update the system
                                          ; variables NEWPPC and NSPPC.
                                          ; then make an indirect exit to STMT-RET via
        LD      BC,$0014                  ; a 20-byte overhead memory check.

; ----------------------
; Check available memory
; ----------------------
; This routine is used on many occasions when extending a dynamic area
; upwards or the GO SUB stack downwards.

test_room:
        LD      HL,(STKEND)               ; fetch STKEND
        ADD     HL,BC                     ; add the supplied test value
        JR      C,report_4                ; forward to REPORT-4 if over $FFFF

        EX      DE,HL                     ; was less so transfer to DE
        LD      HL,$0050                  ; test against another 80 bytes
        ADD     HL,DE                     ; anyway
        JR      C,report_4                ; forward to REPORT-4 if this passes $FFFF

        SBC     HL,SP                     ; if less than the machine stack pointer
        RET     C                         ; then return - OK.

report_4:
        LD      L,$03                     ; prepare 'Out of Memory'
        JP      error_3                   ; jump back to ERROR-3 at error_3
                                          ; Note. this error can't be trapped at error_1

; ------------------------------
; THE 'FREE MEMORY' USER ROUTINE
; ------------------------------
; This routine is not used by the ROM but allows users to evaluate
; approximate free memory with PRINT 65536 - USR 7962.

free_mem:
        LD      BC,$0000                  ; allow no overhead.

        CALL    test_room                 ; routine TEST-ROOM.

        LD      B,H                       ; transfer the result
        LD      C,L                       ; to the BC register.
        RET                               ; the USR function returns value of BC.

; --------------------
; THE 'RETURN' COMMAND
; --------------------
; As with any command, there are two values on the machine stack at the time
; it is invoked.  The machine stack is below the GOSUB stack.  Both grow
; downwards, the machine stack by two bytes, the GOSUB stack by 3 bytes.
; The highest location is a statement byte followed by a two-byte line number.

return:
        POP     BC                        ; drop the address STMT-RET.
        POP     HL                        ; now the error address.
        POP     DE                        ; now a possible BASIC return line.
        LD      A,D                       ; the high byte $00 - $27 is
        CP      $3E                       ; compared with the traditional end-marker $3E.
        JR      Z,report_7                ; forward to REPORT-7 with a match.
                                          ; 'RETURN without GOSUB'

; It was not the end-marker so a single statement byte remains at the base of
; the calculator stack. It can't be popped off.

        DEC     SP                        ; adjust stack pointer to create room for two
                                          ; bytes.
        EX      (SP),HL                   ; statement to H, error address to base of
                                          ; new machine stack.
        EX      DE,HL                     ; statement to D,  BASIC line number to HL.
        LD      (ERR_SP),SP               ; adjust ERR_SP to point to new stack pointer
        PUSH    BC                        ; now re-stack the address STMT-RET
        JP      go_to_2                   ; to GO-TO-2 to update statement and line
                                          ; system variables and exit indirectly to the
                                          ; address just pushed on stack.

; ---

report_7:
        PUSH    DE                        ; replace the end-marker.
        PUSH    HL                        ; now restore the error address
                                          ; as will be required in a few clock cycles.

        RST     08H                       ; ERROR-1
        DEFB    $06                       ; Error Report: RETURN without GOSUB

; --------------------
; Handle PAUSE command
; --------------------
; The pause command takes as its parameter the number of interrupts
; for which to wait. PAUSE 50 pauses for about a second.
; PAUSE 0 pauses indefinitely.
; Both forms can be finished by pressing a key.

pause:
        CALL    find_int2                 ; routine FIND-INT2 puts value in BC

pause_1:
        HALT                              ; wait for interrupt.
        DEC     BC                        ; decrease counter.
        LD      A,B                       ; test if
        OR      C                         ; result is zero.
        JR      Z,pause_end               ; forward to PAUSE-END if so.

        LD      A,B                       ; test if
        AND     C                         ; now $FFFF
        INC     A                         ; that is, initially zero.
        JR      NZ,pause_2                ; skip forward to PAUSE-2 if not.

        INC     BC                        ; restore counter to zero.

pause_2:
        BIT     5,(IY+(FLAGS-C_IY))       ; test FLAGS - has a new key been pressed ?
        JR      Z,pause_1                 ; back to PAUSE-1 if not.

pause_end:
        RES     5,(IY+(FLAGS-C_IY))       ; update FLAGS - signal no new key
        RET                               ; and return.

; -------------------
; Check for BREAK key
; -------------------
; This routine is called from COPY-LINE, when interrupts are disabled,
; to test if BREAK (SHIFT - SPACE) is being pressed.
; It is also called at STMT-RET after every statement.

break_key:
        LD      A,$7F                     ; Input address: $7FFE
        IN      A,($FE)                   ; read lower right keys
        RRA                               ; rotate bit 0 - SPACE
        RET     C                         ; return if not reset

        LD      A,$FE                     ; Input address: $FEFE
        IN      A,($FE)                   ; read lower left keys
        RRA                               ; rotate bit 0 - SHIFT
        RET                               ; carry will be set if not pressed.
                                          ; return with no carry if both keys
                                          ; pressed.

; ---------------------
; Handle DEF FN command
; ---------------------
; e.g DEF FN r$(a$,a) = a$(a TO )
; this 'command' is ignored in runtime but has its syntax checked
; during line-entry.

def_fn:
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,def_fn_1                ; forward to DEF-FN-1 if parsing

        LD      A,$CE                     ; else load A with 'DEF FN' and
        JP      pass_by                   ; jump back to PASS-BY

; ---

; continue here if checking syntax.

def_fn_1:
        SET      6,(IY+(FLAGS-C_IY))      ; set FLAGS  - Assume numeric result
        CALL    alpha                     ; call routine ALPHA
        JR      NC,def_fn_4               ; if not then to DEF-FN-4 to jump to
                                          ; 'Nonsense in BASIC'


        RST     20H                       ; NEXT-CHAR
        CP      $24                       ; is it '$' ?
        JR      NZ,def_fn_2               ; to DEF-FN-2 if not as numeric.

        RES     6,(IY+(FLAGS-C_IY))       ; set FLAGS  - Signal string result

        RST     20H                       ; get NEXT-CHAR

def_fn_2:
        CP      $28                       ; is it '(' ?
        JR      NZ,def_fn_7               ; to DEF-FN-7 'Nonsense in BASIC'


        RST     20H                       ; NEXT-CHAR
        CP      $29                       ; is it ')' ?
        JR      Z,def_fn_6                ; to DEF-FN-6 if null argument

def_fn_3:
        CALL    alpha                     ; routine ALPHA checks that it is the expected
                                          ; alphabetic character.

def_fn_4:
        JP      NC,report_c               ; to REPORT-C  if not
                                          ; 'Nonsense in BASIC'.

        EX      DE,HL                     ; save pointer in DE

        RST     20H                       ; NEXT-CHAR re-initializes HL from CH_ADD
                                          ; and advances.
        CP      $24                       ; '$' ? is it a string argument.
        JR      NZ,def_fn_5               ; forward to DEF-FN-5 if not.

        EX      DE,HL                     ; save pointer to '$' in DE

        RST     20H                       ; NEXT-CHAR re-initializes HL and advances

def_fn_5:
        EX      DE,HL                     ; bring back pointer.
        LD      BC,$0006                  ; the function requires six hidden bytes for
                                          ; each parameter passed.
                                          ; The first byte will be $0E
                                          ; then 5-byte numeric value
                                          ; or 5-byte string pointer.

        CALL    make_room                 ; routine MAKE-ROOM creates space in program
                                          ; area.

        INC     HL                        ; adjust HL (set by LDDR)
        INC     HL                        ; to point to first location.
        LD      (HL),$0E                  ; insert the 'hidden' marker.

; Note. these invisible storage locations hold nothing meaningful for the
; moment. They will be used every time the corresponding function is
; evaluated in runtime.
; Now consider the following character fetched earlier.

        CP      $2C                       ; is it ',' ? (more than one parameter)
        JR      NZ,def_fn_6               ; to DEF-FN-6 if not


        RST     20H                       ; else NEXT-CHAR
        JR      def_fn_3                  ; and back to DEF-FN-3

; ---

def_fn_6:
        CP      $29                       ; should close with a ')'
        JR      NZ,def_fn_7               ; to DEF-FN-7 if not
                                          ; 'Nonsense in BASIC'


        RST     20H                       ; get NEXT-CHAR
        CP      $3D                       ; is it '=' ?
        JR      NZ,def_fn_7               ; to DEF-FN-7 if not 'Nonsense...'


        RST     20H                       ; address NEXT-CHAR
        LD      A,(FLAGS)                 ; get FLAGS which has been set above
        PUSH    AF                        ; and preserve

        CALL    scanning                  ; routine SCANNING checks syntax of expression
                                          ; and also sets flags.

        POP     AF                        ; restore previous flags
        XOR     (IY+(FLAGS-C_IY))         ; xor with FLAGS - bit 6 should be same
                                          ; therefore will be reset.
        AND     $40                       ; isolate bit 6.

def_fn_7:
        JP      NZ,report_c               ; jump back to REPORT-C if the expected result
                                          ; is not the same type.
                                          ; 'Nonsense in BASIC'

        CALL    check_end                 ; routine CHECK-END will return early if
                                          ; at end of statement and move onto next
                                          ; else produce error report. >>>

                                          ; There will be no return to here.

; -------------------------------
; Returning early from subroutine
; -------------------------------
; All routines are capable of being run in two modes - syntax checking mode
; and runtime mode.  This routine is called often to allow a routine to return
; early if checking syntax.

unstack_z:
        CALL    syntax_z                  ; routine SYNTAX-Z sets zero flag if syntax
                                          ; is being checked.

        POP     HL                        ; drop the return address.
        RET      Z                        ; return to previous call in chain if checking
                                          ; syntax.

        JP      (HL)                      ; jump to return address as BASIC program is
                                          ; actually running.

; ---------------------
; Handle LPRINT command
; ---------------------
; A simple form of 'PRINT #3' although it can output to 16 streams.
; Probably for compatibility with other BASICs particularly ZX81 BASIC.
; An extra UDG might have been better.

lprint:
        LD      A,$03                     ; the printer channel
        JR      print_1                   ; forward to PRINT-1

; ---------------------
; Handle PRINT commands
; ---------------------
; The Spectrum's main stream output command.
; The default stream is stream 2 which is normally the upper screen
; of the computer. However the stream can be altered in range 0 - 15.

print:
        LD      A,$02                     ; the stream for the upper screen.

; The LPRINT command joins here.

print_1:
        CALL    syntax_z                  ; routine SYNTAX-Z checks if program running
        CALL    NZ,chan_open              ; routine CHAN-OPEN if so
        CALL    temps                     ; routine TEMPS sets temporary colours.
        CALL    print_2                   ; routine PRINT-2 - the actual item
        CALL    check_end                 ; routine CHECK-END gives error if not at end
                                          ; of statement
        RET                               ; and return >>>

; ------------------------------------
; this subroutine is called from above
; and also from INPUT.

print_2:
        RST     18H                       ; GET-CHAR gets printable character
        CALL    pr_end_z                  ; routine PR-END-Z checks if more printing
        JR      Z,print_4                 ; to PRINT-4 if not     e.g. just 'PRINT :'

; This tight loop deals with combinations of positional controls and
; print items. An early return can be made from within the loop
; if the end of a print sequence is reached.

print_3:
        CALL    pr_posn_1                 ; routine PR-POSN-1 returns zero if more
                                          ; but returns early at this point if
                                          ; at end of statement!
                                          ;
        JR      Z,print_3                 ; to PRINT-3 if consecutive positioners

        CALL    pr_item_1                 ; routine PR-ITEM-1 deals with strings etc.
        CALL    pr_posn_1                 ; routine PR-POSN-1 for more position codes
        JR      Z,print_3                 ; loop back to PRINT-3 if so

print_4:
        CP      $29                       ; return now if this is ')' from input-item.
                                          ; (see INPUT.)
        RET     Z                         ; or continue and print carriage return in
                                          ; runtime

; ---------------------
; Print carriage return
; ---------------------
; This routine which continues from above prints a carriage return
; in run-time. It is also called once from PRINT-POSN.

print_cr:
        CALL    unstack_z                 ; routine UNSTACK-Z

        LD      A,$0D                     ; prepare a carriage return

        RST     10H                       ; PRINT-A
        RET                               ; return


; -----------
; Print items
; -----------
; This routine deals with print items as in
; PRINT AT 10,0;"The value of A is ";a
; It returns once a single item has been dealt with as it is part
; of a tight loop that considers sequences of positional and print items

pr_item_1:
        RST     18H                       ; GET-CHAR
        CP      $AC                       ; is character 'AT' ?
        JR      NZ,pr_item_2              ; forward to PR-ITEM-2 if not.

        CALL    next_2num                 ; routine NEXT-2NUM  check for two comma
                                          ; separated numbers placing them on the
                                          ; calculator stack in runtime.
        CALL    unstack_z                 ; routine UNSTACK-Z quits if checking syntax.

        CALL    stk_to_bc                 ; routine STK-TO-BC get the numbers in B and C.
        LD      A,$16                     ; prepare the 'at' control.
        JR      pr_at_tab                 ; forward to PR-AT-TAB to print the sequence.

; ---

pr_item_2:
        CP      $AD                       ; is character 'TAB' ?
        JR      NZ,pr_item_3              ; to PR-ITEM-3 if not


        RST     20H                       ; NEXT-CHAR to address next character
        CALL    expt_1num                 ; routine EXPT-1NUM
        CALL    unstack_z                 ; routine UNSTACK-Z quits if checking syntax.

        CALL    find_int2                 ; routine FIND-INT2 puts integer in BC.
        LD      A,$17                     ; prepare the 'tab' control.

pr_at_tab:
        RST     10H                       ; PRINT-A outputs the control

        LD      A,C                       ; first value to A
        RST     10H                       ; PRINT-A outputs it.

        LD      A,B                       ; second value
        RST     10H                       ; PRINT-A

        RET                               ; return - item finished >>>

; ---

; Now consider paper 2; #2; a$

pr_item_3:
        CALL    co_temp_3                 ; routine CO-TEMP-3 will print any colour
        RET     NC                        ; items - return if success.

        CALL    str_alter                 ; routine STR-ALTER considers new stream
        RET     NC                        ; return if altered.

        CALL    scanning                  ; routine SCANNING now to evaluate expression
        CALL    unstack_z                 ; routine UNSTACK-Z if not runtime.

        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS  - Numeric or string result ?
        CALL    Z,stk_fetch               ; routine STK-FETCH if string.
                                          ; note no flags affected.
        JP      NZ,print_fp               ; to PRINT-FP to print if numeric >>>

; It was a string expression - start in DE, length in BC
; Now enter a loop to print it

pr_string:
        LD      A,B                       ; this tests if the
        OR      C                         ; length is zero and sets flag accordingly.
        DEC     BC                        ; this doesn't but decrements counter.
        RET     Z                         ; return if zero.

        LD      A,(DE)                    ; fetch character.
        INC     DE                        ; address next location.

        RST     10H                       ; PRINT-A.

        JR      pr_string                 ; loop back to PR-STRING.

; ---------------
; End of printing
; ---------------
; This subroutine returns zero if no further printing is required
; in the current statement.
; The first terminator is found in  escaped input items only,
; the others in print_items.

pr_end_z:
        CP      $29                       ; is character a ')' ?
        RET     Z                         ; return if so -        e.g. INPUT (p$); a$

pr_st_end:
        CP      $0D                       ; is it a carriage return ?
        RET     Z                         ; return also -         e.g. PRINT a

        CP      $3A                       ; is character a ':' ?
        RET                               ; return - zero flag will be set if so.
                                          ;                       e.g. PRINT a :

; --------------
; Print position
; --------------
; This routine considers a single positional character ';', ',', '''

pr_posn_1:
        RST     18H                       ; GET-CHAR
        CP      $3B                       ; is it ';' ?
                                          ; i.e. print from last position.
        JR      Z,pr_posn_3               ; forward to PR-POSN-3 if so.
                                          ; i.e. do nothing.

        CP      $2C                       ; is it ',' ?
                                          ; i.e. print at next tabstop.
        JR      NZ,pr_posn_2              ; forward to PR-POSN-2 if anything else.

        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,pr_posn_3               ; forward to PR-POSN-3 if checking syntax.

        LD      A,$06                     ; prepare the 'comma' control character.

        RST     10H                       ; PRINT-A  outputs to current channel in
                                          ; run-time.

        JR      pr_posn_3                 ; skip to PR-POSN-3.

; ---

; check for newline.

pr_posn_2:
        CP      $27                       ; is character a "'" ? (newline)
        RET     NZ                        ; return if no match              >>>

        CALL    print_cr                  ; routine PRINT-CR outputs a carriage return
                                          ; in runtime only.

pr_posn_3:
        RST     20H                       ; NEXT-CHAR to A.
        CALL    pr_end_z                  ; routine PR-END-Z checks if at end.
        JR      NZ,pr_posn_4              ; to PR-POSN-4 if not.

        POP     BC                        ; drop return address if at end.

pr_posn_4:
        CP      A                         ; reset the zero flag.
        RET                               ; and return to loop or quit.

; ------------
; Alter stream
; ------------
; This routine is called from PRINT ITEMS above, and also LIST as in
; LIST #15

str_alter:
        CP      $23                       ; is character '#' ?
        SCF                               ; set carry flag.
        RET     NZ                        ; return if no match.


        RST      20H                      ; NEXT-CHAR
        CALL    expt_1num                 ; routine EXPT-1NUM gets stream number
        AND     A                         ; prepare to exit early with carry reset
        CALL    unstack_z                 ; routine UNSTACK-Z exits early if parsing
        CALL    find_int1                 ; routine FIND-INT1 gets number off stack
        CP      $10                       ; must be range 0 - 15 decimal.
        JP      NC,report_oa              ; jump back to REPORT-Oa if not
                                          ; 'Invalid stream'.

        CALL    chan_open                 ; routine CHAN-OPEN
        AND     A                         ; clear carry - signal item dealt with.
        RET                               ; return

; --------------------
; Handle INPUT command
; --------------------
; This command
;

input:
        CALL    syntax_z                  ; routine SYNTAX-Z to check if in runtime.
        JR      Z,input_1                 ; forward to INPUT-1 if checking syntax.

        LD      A,$01                     ; select channel 'K' the keyboard for input.
        CALL    chan_open                 ; routine CHAN-OPEN opens it.
        CALL    cls_lower                 ; routine CLS-LOWER clears the lower screen
                                          ; and sets DF_SZ to two.

input_1:
        LD      (IY+(TV_FLAG-C_IY)),$01   ; update TV_FLAG - signal lower screen in use
                                          ; ensuring that the correct set of system
                                          ; variables are updated and that the border
                                          ; colour is used.

        CALL    in_item_1                 ; routine IN-ITEM-1 to handle the input.

        CALL    check_end                 ; routine CHECK-END will make an early exit
                                          ; if checking syntax. >>>

; keyboard input has been made and it remains to adjust the upper
; screen in case the lower two lines have been extended upwards.

        LD      BC,(S_POSN_X)             ; B=[S_POSN_Y], C=[S_POSN_X]
        LD      A,(DF_SZ)                 ; fetch DF_SZ the display file size of
                                          ; the lower screen.
        CP      B                         ; test that lower screen does not overlap
        JR      C,input_2                 ; forward to INPUT-2 if not.

; the two screens overlap so adjust upper screen.

        LD      C,$21                     ; set column of upper screen to leftmost.
        LD      B,A                       ; and line to one above lower screen.
                                          ; continue forward to update upper screen
                                          ; print position.

input_2:
        LD      (S_POSN_X),BC             ; set S_POSN_{X,Y} update upper screen line/column.
        LD      A,$19                     ; subtract from twenty five
        SUB     B                         ; the new line number.
        LD      (SCR_CT),A                ; and place result in SCR_CT - scroll count.
        RES     0,(IY+(TV_FLAG-C_IY))     ; update TV_FLAG - signal main screen in use.
        CALL    cl_set                    ; routine CL-SET sets the print position
                                          ; system variables for the upper screen.
        JP      cls_lower                 ; jump back to CLS-LOWER and make
                                          ; an indirect exit >>.

; ---------------------
; INPUT ITEM subroutine
; ---------------------
; This subroutine deals with the input items and print items.
; from  the current input channel.
; It is only called from the above INPUT routine but was obviously
; once called from somewhere else in another context.

in_item_1:
        CALL    pr_posn_1                 ; routine PR-POSN-1 deals with a single
                                          ; position item at each call.
        JR      Z,in_item_1               ; back to IN-ITEM-1 until no more in a
                                          ; sequence.

        CP      $28                       ; is character '(' ?
        JR      NZ,in_item_2              ; forward to IN-ITEM-2 if not.

; any variables within braces will be treated as part, or all, of the prompt
; instead of being used as destination variables.

        RST     20H                       ; NEXT-CHAR
        CALL    print_2                   ; routine PRINT-2 to output the dynamic
                                          ; prompt.

        RST     18H                       ; GET-CHAR
        CP      $29                       ; is character a matching ')' ?
        JP      NZ,report_c               ; jump back to REPORT-C if not.
                                          ; 'Nonsense in BASIC'.

        RST     20H                       ; NEXT-CHAR
        JP      in_next_2                 ; forward to IN-NEXT-2

; ---

in_item_2:
        CP      $CA                       ; is the character the token 'LINE' ?
        JR      NZ,in_item_3              ; forward to IN-ITEM-3 if not.

        RST     20H                       ; NEXT-CHAR - variable must come next.
        CALL    class_01                  ; routine CLASS-01 returns destination
                                          ; address of variable to be assigned.
                                          ; or generates an error if no variable
                                          ; at this position.

        SET     7,(IY+(FLAGX-C_IY))       ; update FLAGX  - signal handling INPUT LINE
        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS  - numeric or string result ?
        JP      NZ,report_c               ; jump back to REPORT-C if not string
                                          ; 'Nonsense in BASIC'.

        JR      in_prompt                 ; forward to IN-PROMPT to set up workspace.

; ---

; the jump was here for other variables.

in_item_3:
        CALL     alpha                    ; routine ALPHA checks if character is
                                          ; a suitable variable name.
        JP      NC,in_next_1              ; forward to IN-NEXT-1 if not

        CALL    class_01                  ; routine CLASS-01 returns destination
                                          ; address of variable to be assigned.
        RES     7,(IY+(FLAGX-C_IY))       ; update FLAGX  - signal not INPUT LINE.

in_prompt:
        CALL    syntax_z                  ; routine SYNTAX-Z
        JP      Z,in_next_2               ; forward to IN-NEXT-2 if checking syntax.

        CALL    set_work                  ; routine SET-WORK clears workspace.
        LD      HL,FLAGX                  ; point to system variable FLAGX
        RES     6,(HL)                    ; signal string result.
        SET     5,(HL)                    ; signal in Input Mode for editor.
        LD      BC,$0001                  ; initialize space required to one for
                                          ; the carriage return.
        BIT     7,(HL)                    ; test FLAGX - INPUT LINE in use ?
        JR      NZ,in_pr_2                ; forward to IN-PR-2 if so as that is
                                          ; all the space that is required.

        LD      A,(FLAGS)                 ; load accumulator from FLAGS
        AND     $40                       ; mask to test BIT 6 of FLAGS and clear
                                          ; the other bits in A.
                                          ; numeric result expected ?
        JR      NZ,in_pr_1                ; forward to IN-PR-1 if so

        LD      C,$03                     ; increase space to three bytes for the
                                          ; pair of surrounding quotes.

in_pr_1:
        OR      (HL)                      ; if numeric result, set bit 6 of FLAGX.
        LD      (HL),A                    ; and update system variable

in_pr_2:
        RST     30H                       ; BC-SPACES opens 1 or 3 bytes in workspace
        LD      (HL),$0D                  ; insert carriage return at last new location.
        LD      A,C                       ; fetch the length, one or three.
        RRCA                              ; lose bit 0.
        RRCA                              ; test if quotes required.
        JR      NC,in_pr_3                ; forward to IN-PR-3 if not.

        LD      A,$22                     ; load the '"' character
        LD      (DE),A                    ; place quote in first new location at DE.
        DEC     HL                        ; decrease HL - from carriage return.
        LD      (HL),A                    ; and place a quote in second location.

in_pr_3:
        LD      (K_CUR),HL                ; set keyboard cursor K_CUR to HL
        BIT     7,(IY+(FLAGX-C_IY))       ; test FLAGX  - is this INPUT LINE ??
        JR      NZ,in_var_3               ; forward to IN-VAR-3 if so as input will
                                          ; be accepted without checking its syntax.

        LD      HL,(CH_ADD)               ; fetch CH_ADD
        PUSH    HL                        ; and save on stack.
        LD      HL,(ERR_SP)               ; fetch ERR_SP
        PUSH    HL                        ; and save on stack

in_var_1:
        LD      HL,in_var_1               ; address: IN-VAR-1 - this address
        PUSH    HL                        ; is saved on stack to handle errors.
        BIT     4,(IY+(FLAGS2-C_IY))      ; test FLAGS2  - is K channel in use ?
        JR      Z,in_var_2                ; forward to IN-VAR-2 if not using the
                                          ; keyboard for input. (??)

        LD      (ERR_SP),SP               ; set ERR_SP to point to IN-VAR-1 on stack.

in_var_2:
        LD      HL,(WORKSP)               ; set HL to WORKSP - start of workspace.
        CALL    remove_fp                 ; routine REMOVE-FP removes floating point
                                          ; forms when looping in error condition.
        LD      (IY+(ERR_NR-C_IY)),$FF    ; set ERR_NR to 'OK' cancelling the error.
                                          ; but X_PTR causes flashing error marker
                                          ; to be displayed at each call to the editor.
        CALL    editor                    ; routine EDITOR allows input to be entered
                                          ; or corrected if this is second time around.

; if we pass to next then there are no system errors

        RES     7,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal checking syntax
        CALL    in_assign                 ; routine IN-ASSIGN checks syntax using
                                          ; the VAL-FET-2 and powerful SCANNING routines.
                                          ; any syntax error and its back to IN-VAR-1.
                                          ; but with the flashing error marker showing
                                          ; where the error is.
                                          ; Note. the syntax of string input has to be
                                          ; checked as the user may have removed the
                                          ; bounding quotes or escaped them as with
                                          ; "hat" + "stand" for example.
; proceed if syntax passed.

        JR      in_var_4                  ; jump forward to IN-VAR-4

; ---

; the jump was to here when using INPUT LINE.

in_var_3:
        CALL    editor                    ; routine EDITOR is called for input

; when ENTER received rejoin other route but with no syntax check.

; INPUT and INPUT LINE converge here.

in_var_4:
        LD      (IY+(K_CUR_hi-C_IY)),$00  ; set K_CUR_hi to a low value so that the cursor
                                          ; no longer appears in the input line.

        CALL    in_chan_k                 ; routine IN-CHAN-K tests if the keyboard
                                          ; is being used for input.
        JR      NZ,in_var_5               ; forward to IN-VAR-5 if using another input
                                          ; channel.

; continue here if using the keyboard.

        CALL    ed_copy                   ; routine ED-COPY overprints the edit line
                                          ; to the lower screen. The only visible
                                          ; affect is that the cursor disappears.
                                          ; if you're inputting more than one item in
                                          ; a statement then that becomes apparent.

        LD      BC,(ECHO_E_X)             ; fetch line and column from ECHO_E
        CALL    cl_set                    ; routine CL-SET sets S-POSNL to those
                                          ; values.

; if using another input channel rejoin here.

in_var_5:
        LD      HL,FLAGX                  ; point HL to FLAGX
        RES     5,(HL)                    ; signal not in input mode
        BIT     7,(HL)                    ; is this INPUT LINE ?
        RES     7,(HL)                    ; cancel the bit anyway.
        JR      NZ,in_var_6               ; forward to IN-VAR-6 if INPUT LINE.

        POP     HL                        ; drop the looping address
        POP     HL                        ; drop the the address of previous
                                          ; error handler.
        LD      (ERR_SP),HL               ; set ERR_SP to point to it.
        POP     HL                        ; drop original CH_ADD which points to
                                          ; INPUT command in BASIC line.
        LD      (X_PTR),HL                ; save in X_PTR while input is assigned.
        SET     7,(IY+(FLAGS-C_IY))       ; update FLAGS - Signal running program
        CALL    in_assign                 ; routine IN-ASSIGN is called again
                                          ; this time the variable will be assigned
                                          ; the input value without error.
                                          ; Note. the previous example now
                                          ; becomes "hatstand"

        LD      HL,(X_PTR)                ; fetch stored CH_ADD value from X_PTR.
        LD      (IY+(X_PTR_hi-C_IY)),$00  ; set X_PTR_hi so that iy is no longer relevant.
        LD      (CH_ADD),HL               ; put restored value back in CH_ADD
        JR      in_next_2                 ; forward to IN-NEXT-2 to see if anything
                                          ; more in the INPUT list.

; ---

; the jump was to here with INPUT LINE only

in_var_6:
        LD      HL,(STKBOT)               ; STKBOT points to the end of the input.
        LD      DE,(WORKSP)               ; WORKSP points to the beginning.
        SCF                               ; prepare for true subtraction.
        SBC     HL,DE                     ; subtract to get length
        LD      B,H                       ; transfer it to
        LD      C,L                       ; the BC register pair.
        CALL    stk_sto_string            ; routine STK-STO-$ stores parameters on
                                          ; the calculator stack.
        CALL    let                       ; routine LET assigns it to destination.
        JR      in_next_2                 ; forward to IN-NEXT-2 as print items
                                          ; not allowed with INPUT LINE.
                                          ; Note. that "hat" + "stand" will, for
                                          ; example, be unchanged as also would
                                          ; 'PRINT "Iris was here"'.

; ---

; the jump was to here when ALPHA found more items while looking for
; a variable name.

in_next_1:
        CALL    pr_item_1                 ; routine PR-ITEM-1 considers further items.

in_next_2:
        CALL    pr_posn_1                 ; routine PR-POSN-1 handles a position item.
        JP      Z,in_item_1               ; jump back to IN-ITEM-1 if the zero flag
                                          ; indicates more items are present.

        RET                               ; return.

; ---------------------------
; INPUT ASSIGNMENT Subroutine
; ---------------------------
; This subroutine is called twice from the INPUT command when normal
; keyboard input is assigned. On the first occasion syntax is checked
; using SCANNING. The final call with the syntax flag reset is to make
; the assignment.

in_assign:
        LD      HL,(WORKSP)               ; fetch WORKSP start of input
        LD      (CH_ADD),HL               ; set CH_ADD to first character

        RST     18H                       ; GET-CHAR ignoring leading white-space.
        CP      $E2                       ; is it 'STOP'
        JR      Z,in_stop                 ; forward to IN-STOP if so.

        LD      A,(FLAGX)                 ; load accumulator from FLAGX
        CALL    val_fet_2                 ; routine VAL-FET-2 makes assignment
                                          ; or goes through the motions if checking
                                          ; syntax. SCANNING is used.

        RST     18H                       ; GET-CHAR
        CP      $0D                       ; is it carriage return ?
        RET     Z                         ; return if so
                                          ; either syntax is OK
                                          ; or assignment has been made.

; if another character was found then raise an error.
; User doesn't see report but the flashing error marker
; appears in the lower screen.

report_cb:
        RST     08H                       ; ERROR-1
        DEFB    $0B                       ; Error Report: Nonsense in BASIC

in_stop:
        CALL    syntax_z                  ; routine SYNTAX-Z (UNSTACK-Z?)
        RET     Z                         ; return if checking syntax
                                          ; as user wouldn't see error report.
                                          ; but generate visible error report
                                          ; on second invocation.

report_h:
        RST     08H                       ; ERROR-1
        DEFB    $10                       ; Error Report: STOP in INPUT

; ------------------
; Test for channel K
; ------------------
; This subroutine is called once from the keyboard
; INPUT command to check if the input routine in
; use is the one for the keyboard.

in_chan_k:
        LD      HL,(CURCHL)               ; fetch address of current channel CURCHL
        INC     HL                        ;
        INC     HL                        ; advance past
        INC     HL                        ; input and
        INC     HL                        ; output streams
        LD      A,(HL)                    ; fetch the channel identifier.
        CP      $4B                       ; test for 'K'
        RET                               ; return with zero set if keyboard is use.

; --------------------
; Colour Item Routines
; --------------------
;
; These routines have 3 entry points -
; 1) CO-TEMP-2 to handle a series of embedded Graphic colour items.
; 2) CO-TEMP-3 to handle a single embedded print colour item.
; 3) CO TEMP-4 to handle a colour command such as FLASH 1
;
; "Due to a bug, if you bring in a peripheral channel and later use a colour
;  statement, colour controls will be sent to it by mistake." - Steven Vickers
;  Pitman Pocket Guide, 1984.
;
; To be fair, this only applies if the last channel was other than 'K', 'S'
; or 'P', which are all that are supported by this ROM, but if that last
; channel was a microdrive file, network channel etc. then
; PAPER 6; CLS will not turn the screen yellow and
; CIRCLE INK 2; 128,88,50 will not draw a red circle.
;
; This bug does not apply to embedded PRINT items as it is quite permissible
; to mix stream altering commands and colour items.
; The fix therefore would be to ensure that CLASS-07 and CLASS-09 make
; channel 'S' the current channel when not checking syntax.
; -----------------------------------------------------------------

co_temp_1:
        RST     20H                       ; NEXT-CHAR

; -> Entry point from CLASS-09. Embedded Graphic colour items.
; e.g. PLOT INK 2; PAPER 8; 128,88
; Loops till all colour items output, finally addressing the coordinates.

co_temp_2:
        CALL    co_temp_3                 ; routine CO-TEMP-3 to output colour control.
        RET     C                         ; return if nothing more to output. ->


        RST     18H                       ; GET-CHAR
        CP      $2C                       ; is it ',' separator ?
        JR      Z,co_temp_1               ; back if so to CO-TEMP-1

        CP      $3B                       ; is it ';' separator ?
        JR      Z,co_temp_1               ; back to CO-TEMP-1 for more.

        JP      report_c                  ; to REPORT-C (REPORT-Cb is within range)
                                          ; 'Nonsense in BASIC'

; -------------------
; CO-TEMP-3
; -------------------
; -> this routine evaluates and outputs a colour control and parameter.
; It is called from above and also from PR-ITEM-3 to handle a single embedded
; print item e.g. PRINT PAPER 6; "Hi". In the latter case, the looping for
; multiple items is within the PR-ITEM routine.
; It is quite permissible to send these to any stream.

co_temp_3:
        CP      $D9                       ; is it 'INK' ?
        RET     C                         ; return if less.

        CP      $DF                       ; compare with 'OUT'
        CCF                               ; Complement Carry Flag
        RET     C                         ; return if greater than 'OVER', $DE.

        PUSH    AF                        ; save the colour token.

        RST     20H                       ; address NEXT-CHAR
        POP     AF                        ; restore token and continue.

; -> this entry point used by CLASS-07. e.g. the command PAPER 6.

co_temp_4:
        SUB     $C9                       ; reduce to control character $10 (INK)
                                          ; thru $15 (OVER).
        PUSH    AF                        ; save control.
        CALL    expt_1num                 ; routine EXPT-1NUM stacks addressed
                                          ; parameter on calculator stack.
        POP     AF                        ; restore control.
        AND     A                         ; clear carry

        CALL    unstack_z                 ; routine UNSTACK-Z returns if checking syntax.

        PUSH    AF                        ; save again
        CALL    find_int1                 ; routine FIND-INT1 fetches parameter to A.
        LD      D,A                       ; transfer now to D
        POP     AF                        ; restore control.

        RST     10H                       ; PRINT-A outputs the control to current
                                          ; channel.
        LD      A,D                       ; transfer parameter to A.

        RST     10H                       ; PRINT-A outputs parameter.
        RET                               ; return. ->

; -------------------------------------------------------------------------
;
;         {fl}{br}{   paper   }{  ink    }    The temporary colour attributes
;          ___ ___ ___ ___ ___ ___ ___ ___    system variable.
; ATTR_T  |   |   |   |   |   |   |   |   |
;         |   |   |   |   |   |   |   |   |
; 23695   |___|___|___|___|___|___|___|___|
;           7   6   5   4   3   2   1   0
;
;
;         {fl}{br}{   paper   }{  ink    }    The temporary mask used for
;          ___ ___ ___ ___ ___ ___ ___ ___    transparent colours. Any bit
; MASK_T  |   |   |   |   |   |   |   |   |   that is 1 shows that the
;         |   |   |   |   |   |   |   |   |   corresponding attribute is
; 23696   |___|___|___|___|___|___|___|___|   taken not from ATTR-T but from
;           7   6   5   4   3   2   1   0     what is already on the screen.
;
;
;         {paper9 }{ ink9 }{ inv1 }{ over1}   The print flags. Even bits are
;          ___ ___ ___ ___ ___ ___ ___ ___    temporary flags. The odd bits
; P_FLAG  |   |   |   |   |   |   |   |   |   are the permanent flags.
;         | p | t | p | t | p | t | p | t |
; 23697   |___|___|___|___|___|___|___|___|
;           7   6   5   4   3   2   1   0
;
; -----------------------------------------------------------------------

; ------------------------------------
;  The colour system variable handler.
; ------------------------------------
; This is an exit branch from PO-1-OPER, PO-2-OPER
; A holds control $10 (INK) to $15 (OVER)
; D holds parameter 0-9 for ink/paper 0,1 or 8 for bright/flash,
; 0 or 1 for over/inverse.

co_temp_5:
        SUB     $11                       ; reduce range $FF-$04
        ADC     A,$00                     ; add in carry if INK
        JR      Z,co_temp_7               ; forward to CO-TEMP-7 with INK and PAPER.

        SUB     $02                       ; reduce range $FF-$02
        ADC     A,$00                     ; add carry if FLASH
        JR      Z,co_temp_c               ; forward to CO-TEMP-C with FLASH and BRIGHT.

        CP      $01                       ; is it 'INVERSE' ?
        LD      A,D                       ; fetch parameter for INVERSE/OVER
        LD      B,$01                     ; prepare OVER mask setting bit 0.
        JR      NZ,co_temp_6              ; forward to CO-TEMP-6 if OVER

        RLCA                              ; shift bit 0
        RLCA                              ; to bit 2
        LD      B,$04                     ; set bit 2 of mask for inverse.

co_temp_6:
        LD      C,A                       ; save the A
        LD      A,D                       ; re-fetch parameter
        CP      $02                       ; is it less than 2
        JR      NC,report_k               ; to REPORT-K if not 0 or 1.
                                          ; 'Invalid colour'.

        LD      A,C                       ; restore A
        LD      HL,P_FLAG                 ; address system variable P_FLAG
        JR      co_change                 ; forward to exit via routine CO-CHANGE

; ---

; the branch was here with INK/PAPER and carry set for INK.

co_temp_7:
        LD      A,D                       ; fetch parameter
        LD      B,$07                     ; set ink mask 00000111
        JR      C,co_temp_8               ; forward to CO-TEMP-8 with INK

        RLCA                              ; shift bits 0-2
        RLCA                              ; to
        RLCA                              ; bits 3-5
        LD      B,$38                     ; set paper mask 00111000

; both paper and ink rejoin here

co_temp_8:
        LD      C,A                       ; value to C
        LD      A,D                       ; fetch parameter
        CP      $0A                       ; is it less than 10d ?
        JR      C,co_temp_9               ; forward to CO-TEMP-9 if so.

; ink 10 etc. is not allowed.

report_k:
        RST     08H                       ; ERROR-1
        DEFB    $13                       ; Error Report: Invalid colour

co_temp_9:
        LD      HL,ATTR_T                 ; address system variable ATTR_T initially.
        CP      $08                       ; compare with 8
        JR      C,co_temp_b               ; forward to CO-TEMP-B with 0-7.

        LD      A,(HL)                    ; fetch temporary attribute as no change.
        JR      Z,co_temp_a               ; forward to CO-TEMP-A with INK/PAPER 8

; it is either ink 9 or paper 9 (contrasting)

        OR      B                         ; or with mask to make white
        CPL                               ; make black and change other to dark
        AND     $24                       ; 00100100
        JR      Z,co_temp_a               ; forward to CO-TEMP-A if black and
                                          ; originally light.

        LD      A,B                       ; else just use the mask (white)

co_temp_a:
        LD      C,A                       ; save A in C

co_temp_b:
        LD      A,C                       ; load colour to A
        CALL    co_change                 ; routine CO-CHANGE addressing ATTR-T

        LD      A,$07                     ; put 7 in accumulator
        CP      D                         ; compare with parameter
        SBC     A,A                       ; $00 if 0-7, $FF if 8
        CALL    co_change                 ; routine CO-CHANGE addressing MASK-T
                                          ; mask returned in A.

; now consider P-FLAG.

        RLCA                              ; 01110000 or 00001110
        RLCA                              ; 11100000 or 00011100
        AND     $50                       ; 01000000 or 00010000  (AND 01010000)
        LD      B,A                       ; transfer to mask
        LD      A,$08                     ; load A with 8
        CP      D                         ; compare with parameter
        SBC     A,A                       ; $FF if was 9,  $00 if 0-8
                                          ; continue while addressing P-FLAG
                                          ; setting bit 4 if ink 9
                                          ; setting bit 6 if paper 9

; -----------------------
; Handle change of colour
; -----------------------
; This routine addresses a system variable ATTR_T, MASK_T or P-FLAG in HL.
; colour value in A, mask in B.

co_change:
        XOR     (HL)                      ; impress bits specified
        AND     B                         ; by mask
        XOR     (HL)                      ; on system variable.
        LD      (HL),A                    ; update system variable.
        INC     HL                        ; address next location.
        LD      A,B                       ; put current value of mask in A
        RET                               ; return.

; ---

; the branch was here with flash and bright

co_temp_c:
        SBC     A,A                       ; set zero flag for bright.
        LD      A,D                       ; fetch original parameter 0,1 or 8
        RRCA                              ; rotate bit 0 to bit 7
        LD      B,$80                     ; mask for flash 10000000
        JR      NZ,co_temp_d              ; forward to CO-TEMP-D if flash

        RRCA                              ; rotate bit 7 to bit 6
        LD      B,$40                     ; mask for bright 01000000

co_temp_d:
        LD      C,A                       ; store value in C
        LD      A,D                       ; fetch parameter
        CP      $08                       ; compare with 8
        JR      Z,co_temp_e               ; forward to CO-TEMP-E if 8

        CP      $02                       ; test if 0 or 1
        JR      NC,report_k               ; back to REPORT-K if not
                                          ; 'Invalid colour'

co_temp_e:
        LD      A,C                       ; value to A
        LD      HL,ATTR_T                 ; address ATTR_T
        CALL    co_change                 ; routine CO-CHANGE addressing ATTR_T
        LD      A,C                       ; fetch value
        RRCA                              ; for flash8/bright8 complete
        RRCA                              ; rotations to put set bit in
        RRCA                              ; bit 7 (flash) bit 6 (bright)
        JR      co_change                 ; back to CO-CHANGE addressing MASK_T
                                          ; and indirect return.

; ---------------------
; Handle BORDER command
; ---------------------
; Command syntax example: BORDER 7
; This command routine sets the border to one of the eight colours.
; The colours used for the lower screen are based on this.

border:
        CALL    find_int1                 ; routine FIND-INT1
        CP      $08                       ; must be in range 0 (black) to 7 (white)
        JR      NC,report_k               ; back to REPORT-K if not
                                          ; 'Invalid colour'.

        OUT     ($FE),A                   ; outputting to port effects an immediate
                                          ; change.
        RLCA                              ; shift the colour to
        RLCA                              ; the paper bits setting the
        RLCA                              ; ink colour black.
        BIT     5,A                       ; is the number light coloured ?
                                          ; i.e. in the range green to white.
        JR      NZ,border_1               ; skip to BORDER-1 if so

        XOR     $07                       ; make the ink white.

border_1:
        LD      (BORDCR),A                ; update BORDCR with new paper/ink
        RET                               ; return.

; -----------------
; Get pixel address
; -----------------
;
;

pixel_addr:
        LD      A,$AF                     ; load with 175 decimal.
        SUB     B                         ; subtract the y value.
        JP      C,report_bc               ; jump forward to REPORT-Bc if greater.
                                          ; 'Integer out of range'

; the high byte is derived from Y only.
; the first 3 bits are always 010
; the next 2 bits denote in which third of the screen the byte is.
; the last 3 bits denote in which of the 8 scan lines within a third
; the byte is located. There are 24 discrete values.


        LD      B,A                       ; the line number from top of screen to B.
        AND     A                         ; clear carry (already clear)
        RRA                               ;                     0xxxxxxx
        SCF                               ; set carry flag
        RRA                               ;                     10xxxxxx
        AND     A                         ; clear carry flag
        RRA                               ;                     010xxxxx

        XOR     B                         ;
        AND     $F8                       ; keep the top 5 bits 11111000
        XOR     B                         ;                     010xxbbb
        LD      H,A                       ; transfer high byte to H.

; the low byte is derived from both X and Y.

        LD      A,C                       ; the x value 0-255.
        RLCA                              ;
        RLCA                              ;
        RLCA                              ;
        XOR     B                         ; the y value
        AND     $C7                       ; apply mask             11000111
        XOR     B                         ; restore unmasked bits  xxyyyxxx
        RLCA                              ; rotate to              xyyyxxxx
        RLCA                              ; required position.     yyyxxxxx
        LD      L,A                       ; low byte to L.

; finally form the pixel position in A.

        LD      A,C                       ; x value to A
        AND     $07                       ; mod 8
        RET                               ; return

; ----------------
; Point Subroutine
; ----------------
; The point subroutine is called from s-point via the scanning functions
; table.

point_sub:
        CALL    stk_to_bc                 ; routine STK-TO-BC
        CALL    pixel_addr                ; routine PIXEL-ADD finds address of pixel.
        LD      B,A                       ; pixel position to B, 0-7.
        INC     B                         ; increment to give rotation count 1-8.
        LD      A,(HL)                    ; fetch byte from screen.

point_lp:
        RLCA                              ; rotate and loop back
        DJNZ    point_lp                  ; to POINT-LP until pixel at right.

        AND      $01                      ; test to give zero or one.
        JP      stack_a                   ; jump forward to STACK-A to save result.

; -------------------
; Handle PLOT command
; -------------------
; Command Syntax example: PLOT 128,88
;

plot:
        CALL    stk_to_bc                 ; routine STK-TO-BC
        CALL    plot_sub                  ; routine PLOT-SUB
        JP      temps                     ; to TEMPS

; -------------------
; The Plot subroutine
; -------------------
; A screen byte holds 8 pixels so it is necessary to rotate a mask
; into the correct position to leave the other 7 pixels unaffected.
; However all 64 pixels in the character cell take any embedded colour
; items.
; A pixel can be reset (inverse 1), toggled (over 1), or set ( with inverse
; and over switches off). With both switches on, the byte is simply put
; back on the screen though the colours may change.

plot_sub:
        LD      (COORDS_X),BC             ; store new x/y values in COORDS
        CALL    pixel_addr                ; routine PIXEL-ADD gets address in HL,
                                          ; count from left 0-7 in B.
        LD      B,A                       ; transfer count to B.
        INC     B                         ; increase 1-8.
        LD      A,$FE                     ; 11111110 in A.

plot_loop:
        RRCA                              ; rotate mask.
        DJNZ    plot_loop                 ; to PLOT-LOOP until B circular rotations.

        LD      B,A                       ; load mask to B
        LD      A,(HL)                    ; fetch screen byte to A

        LD      C,(IY+(P_FLAG-C_IY))      ; P_FLAG to C
        BIT     0,C                       ; is it to be OVER 1 ?
        JR      NZ,pl_tst_in              ; forward to PL-TST-IN if so.

; was over 0

        AND     B                         ; combine with mask to blank pixel.

pl_tst_in:
        BIT     2,C                       ; is it inverse 1 ?
        JR      NZ,plot_end               ; to PLOT-END if so.

        XOR     B                         ; switch the pixel
        CPL                               ; restore other 7 bits

plot_end:
        LD      (HL),A                    ; load byte to the screen.
        JP      po_attr                   ; exit to PO-ATTR to set colours for cell.

; ------------------------------
; Put two numbers in BC register
; ------------------------------
;
;

stk_to_bc:
        CALL    stk_to_a                  ; routine STK-TO-A
        LD      B,A                       ;
        PUSH    BC                        ;
        CALL    stk_to_a                  ; routine STK-TO-A
        LD      E,C                       ;
        POP     BC                        ;
        LD      D,C                       ;
        LD      C,A                       ;
        RET                               ;

; -----------------------
; Put stack in A register
; -----------------------
; This routine puts the last value on the calculator stack into the accumulator
; deleting the last value.

stk_to_a:
        CALL    fp_to_a                   ; routine FP-TO-A compresses last value into
                                          ; accumulator. e.g. PI would become 3.
                                          ; zero flag set if positive.
        JP      C,report_bc               ; jump forward to REPORT-Bc if >= 255.5.

        LD      C,$01                     ; prepare a positive sign byte.
        RET     Z                         ; return if FP-TO-BC indicated positive.

        LD      C,$FF                     ; prepare negative sign byte and
        RET                               ; return.


; ---------------------
; Handle CIRCLE command
; ---------------------
;
; syntax has been partly checked using the class for draw command.

circle:
        RST     18H                       ; GET-CHAR
        CP      $2C                       ; is it required comma ?
        JP      NZ,report_c               ; jump to REPORT-C if not


        RST     20H                       ; NEXT-CHAR
        CALL    expt_1num                 ; routine EXPT-1NUM fetches radius
        CALL    check_end                 ; routine CHECK-END will return here if
                                          ; nothing follows command.

        RST     28H                       ;; FP-CALC
        DEFB    $2A                       ;;abs           ; make radius positive
        DEFB    $3D                       ;;re-stack      ; in full floating point form
        DEFB    $38                       ;;end-calc

        LD      A,(HL)                    ; fetch first floating point byte
        CP      $81                       ; compare to one
        JR      NC,c_r_gre_1              ; forward to C-R-GRE-1 if circle radius
                                          ; is greater than one.


        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete        ; delete the radius from stack.
        DEFB    $38                       ;;end-calc

        JR      plot                      ; to PLOT to just plot x,y.

; ---


c_r_gre_1:
        RST     28H                       ;; FP-CALC      ; x, y, r
        DEFB    $A3                       ;;stk-pi/2      ; x, y, r, pi/2.
        DEFB    $38                       ;;end-calc

        LD      (HL),$83                  ;               ; x, y, r, 2*PI

        RST     28H                       ;; FP-CALC
        DEFB    $C5                       ;;st-mem-5      ; store 2*PI in mem-5
        DEFB    $02                       ;;delete        ; x, y, z.
        DEFB    $38                       ;;end-calc

        CALL    cd_prms1                  ; routine CD-PRMS1
        PUSH    BC                        ;

        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate
        DEFB    $E1                       ;;get-mem-1
        DEFB    $04                       ;;multiply
        DEFB    $38                       ;;end-calc

        LD      A,(HL)                    ;
        CP      $80                       ;
        JR      NC,c_arc_ge1              ; to C-ARC-GE1


        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        POP     BC                        ;
        JP      plot                      ; JUMP to PLOT

; ---


c_arc_ge1:
        RST     28H                       ;; FP-CALC
        DEFB    $C2                       ;;st-mem-2
        DEFB    $01                       ;;exchange
        DEFB    $C0                       ;;st-mem-0
        DEFB    $02                       ;;delete
        DEFB    $03                       ;;subtract
        DEFB    $01                       ;;exchange
        DEFB    $E0                       ;;get-mem-0
        DEFB    $0F                       ;;addition
        DEFB    $C0                       ;;st-mem-0
        DEFB    $01                       ;;exchange
        DEFB    $31                       ;;duplicate
        DEFB    $E0                       ;;get-mem-0
        DEFB    $01                       ;;exchange
        DEFB    $31                       ;;duplicate
        DEFB    $E0                       ;;get-mem-0
        DEFB    $A0                       ;;stk-zero
        DEFB    $C1                       ;;st-mem-1
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        INC     (IY+(MEMBOT_0a-C_IY))     ; MEM-2-1st
        CALL     find_int1                ; routine FIND-INT1
        LD      L,A                       ;
        PUSH    HL                        ;
        CALL    find_int1                 ; routine FIND-INT1
        POP     HL                        ;
        LD      H,A                       ;
        LD      (COORDS_X),HL             ; COORDS
        POP     BC                        ;
        JP      drw_steps                 ; to DRW-STEPS


; -------------------
; Handle DRAW command
; -------------------
;
;

draw:
        RST     18H                       ; GET-CHAR
        CP      $2C                       ;
        JR      Z,dr_3_prms               ; to DR-3-PRMS

        CALL    check_end                 ; routine CHECK-END
        JP      line_draw                 ; to LINE-DRAW

; ---

dr_3_prms:
        RST     20H                       ; NEXT-CHAR
        CALL    expt_1num                 ; routine EXPT-1NUM
        CALL    check_end                 ; routine CHECK-END

        RST     28H                       ;; FP-CALC
        DEFB    $C5                       ;;st-mem-5
        DEFB    $A2                       ;;stk-half
        DEFB    $04                       ;;multiply
        DEFB    $1F                       ;;sin
        DEFB    $31                       ;;duplicate
        DEFB    $30                       ;;not
        DEFB    $30                       ;;not
        DEFB    $00                       ;;jump-true

        DEFB    $06                       ;;to dr_sin_nz, DR-SIN-NZ

        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        JP      line_draw                 ; to LINE-DRAW

; ---

dr_sin_nz:
        DEFB    $C0                       ;;st-mem-0
        DEFB    $02                       ;;delete
        DEFB    $C1                       ;;st-mem-1
        DEFB    $02                       ;;delete
        DEFB    $31                       ;;duplicate
        DEFB    $2A                       ;;abs
        DEFB    $E1                       ;;get-mem-1
        DEFB    $01                       ;;exchange
        DEFB    $E1                       ;;get-mem-1
        DEFB    $2A                       ;;abs
        DEFB    $0F                       ;;addition
        DEFB    $E0                       ;;get-mem-0
        DEFB    $05                       ;;division
        DEFB    $2A                       ;;abs
        DEFB    $E0                       ;;get-mem-0
        DEFB    $01                       ;;exchange
        DEFB    $3D                       ;;re-stack
        DEFB    $38                       ;;end-calc

        LD      A,(HL)                    ;
        CP      $81                       ;
        JR      NC,dr_prms                ; to DR-PRMS


        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        JP      line_draw                 ; to LINE-DRAW

; ---

dr_prms:
        CALL    cd_prms1                  ; routine CD-PRMS1
        PUSH    BC                        ;

        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete
        DEFB    $E1                       ;;get-mem-1
        DEFB    $01                       ;;exchange
        DEFB    $05                       ;;division
        DEFB    $C1                       ;;st-mem-1
        DEFB    $02                       ;;delete
        DEFB    $01                       ;;exchange
        DEFB    $31                       ;;duplicate
        DEFB    $E1                       ;;get-mem-1
        DEFB    $04                       ;;multiply
        DEFB    $C2                       ;;st-mem-2
        DEFB    $02                       ;;delete
        DEFB    $01                       ;;exchange
        DEFB    $31                       ;;duplicate
        DEFB    $E1                       ;;get-mem-1
        DEFB    $04                       ;;multiply
        DEFB    $E2                       ;;get-mem-2
        DEFB    $E5                       ;;get-mem-5
        DEFB    $E0                       ;;get-mem-0
        DEFB    $03                       ;;subtract
        DEFB    $A2                       ;;stk-half
        DEFB    $04                       ;;multiply
        DEFB    $31                       ;;duplicate
        DEFB    $1F                       ;;sin
        DEFB    $C5                       ;;st-mem-5
        DEFB    $02                       ;;delete
        DEFB    $20                       ;;cos
        DEFB    $C0                       ;;st-mem-0
        DEFB    $02                       ;;delete
        DEFB    $C2                       ;;st-mem-2
        DEFB    $02                       ;;delete
        DEFB    $C1                       ;;st-mem-1
        DEFB    $E5                       ;;get-mem-5
        DEFB    $04                       ;;multiply
        DEFB    $E0                       ;;get-mem-0
        DEFB    $E2                       ;;get-mem-2
        DEFB    $04                       ;;multiply
        DEFB    $0F                       ;;addition
        DEFB    $E1                       ;;get-mem-1
        DEFB    $01                       ;;exchange
        DEFB    $C1                       ;;st-mem-1
        DEFB    $02                       ;;delete
        DEFB    $E0                       ;;get-mem-0
        DEFB    $04                       ;;multiply
        DEFB    $E2                       ;;get-mem-2
        DEFB    $E5                       ;;get-mem-5
        DEFB    $04                       ;;multiply
        DEFB    $03                       ;;subtract
        DEFB    $C2                       ;;st-mem-2
        DEFB    $2A                       ;;abs
        DEFB    $E1                       ;;get-mem-1
        DEFB    $2A                       ;;abs
        DEFB    $0F                       ;;addition
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        LD      A,(DE)                    ;
        CP       $81                      ;
        POP     BC                        ;
        JP      C,line_draw               ; to LINE-DRAW

        PUSH    BC                        ;

        RST     28H                       ;; FP-CALC
        DEFB    $01                       ;;exchange
        DEFB    $38                       ;;end-calc

        LD      A,(COORDS_X)              ; COORDS-x
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $C0                       ;;st-mem-0
        DEFB    $0F                       ;;addition
        DEFB    $01                       ;;exchange
        DEFB    $38                       ;;end-calc

        LD      A,(COORDS_Y)              ; COORDS-y
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $C5                       ;;st-mem-5
        DEFB    $0F                       ;;addition
        DEFB    $E0                       ;;get-mem-0
        DEFB    $E5                       ;;get-mem-5
        DEFB    $38                       ;;end-calc

        POP     BC                        ;

drw_steps:
        DEC     B                         ;
        JR      Z,arc_end                 ; to ARC-END

        JR      arc_start                 ; to ARC-START

; ---


arc_loop:
        RST     28H                       ;; FP-CALC
        DEFB    $E1                       ;;get-mem-1
        DEFB    $31                       ;;duplicate
        DEFB    $E3                       ;;get-mem-3
        DEFB    $04                       ;;multiply
        DEFB    $E2                       ;;get-mem-2
        DEFB    $E4                       ;;get-mem-4
        DEFB    $04                       ;;multiply
        DEFB    $03                       ;;subtract
        DEFB    $C1                       ;;st-mem-1
        DEFB    $02                       ;;delete
        DEFB    $E4                       ;;get-mem-4
        DEFB    $04                       ;;multiply
        DEFB    $E2                       ;;get-mem-2
        DEFB    $E3                       ;;get-mem-3
        DEFB    $04                       ;;multiply
        DEFB    $0F                       ;;addition
        DEFB    $C2                       ;;st-mem-2
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

arc_start:
        PUSH    BC                        ;

        RST     28H                       ;; FP-CALC
        DEFB    $C0                       ;;st-mem-0
        DEFB    $02                       ;;delete
        DEFB    $E1                       ;;get-mem-1
        DEFB    $0F                       ;;addition
        DEFB    $31                       ;;duplicate
        DEFB    $38                       ;;end-calc

        LD      A,(COORDS_X)              ; COORDS-x
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $03                       ;;subtract
        DEFB    $E0                       ;;get-mem-0
        DEFB    $E2                       ;;get-mem-2
        DEFB    $0F                       ;;addition
        DEFB    $C0                       ;;st-mem-0
        DEFB    $01                       ;;exchange
        DEFB    $E0                       ;;get-mem-0
        DEFB    $38                       ;;end-calc

        LD      A,(COORDS_Y)              ; COORDS-y
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $03                       ;;subtract
        DEFB    $38                       ;;end-calc

        CALL    draw_line                 ; routine DRAW-LINE
        POP     BC                        ;
        DJNZ    arc_loop                  ; to ARC-LOOP


arc_end:
        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete
        DEFB    $02                       ;;delete
        DEFB    $01                       ;;exchange
        DEFB    $38                       ;;end-calc

        LD      A,(COORDS_X)              ; COORDS-x
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $03                       ;;subtract
        DEFB    $01                       ;;exchange
        DEFB    $38                       ;;end-calc

        LD      A,(COORDS_Y)              ; COORDS-y
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $03                       ;;subtract
        DEFB    $38                       ;;end-calc

line_draw:
        CALL    draw_line                 ; routine DRAW-LINE
        JP      temps                     ; to TEMPS


; ------------------
; Initial parameters
; ------------------
;
;

cd_prms1:
        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate
        DEFB    $28                       ;;sqr
        DEFB    $34                       ;;stk-data
        DEFB    $32                       ;;Exponent: $82, Bytes: 1
        DEFB    $00                       ;;(+00,+00,+00)
        DEFB    $01                       ;;exchange
        DEFB    $05                       ;;division
        DEFB    $E5                       ;;get-mem-5
        DEFB    $01                       ;;exchange
        DEFB    $05                       ;;division
        DEFB    $2A                       ;;abs
        DEFB    $38                       ;;end-calc

        CALL    fp_to_a                   ; routine FP-TO-A
        JR      C,use_252                 ; to USE-252

        AND     $FC                       ;
        ADD     A,$04                     ;
        JR      NC,draw_save              ; to DRAW-SAVE

use_252:
        LD      A,$FC                     ;

draw_save:
        PUSH    AF                        ;
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $E5                       ;;get-mem-5
        DEFB    $01                       ;;exchange
        DEFB    $05                       ;;division
        DEFB    $31                       ;;duplicate
        DEFB    $1F                       ;;sin
        DEFB    $C4                       ;;st-mem-4
        DEFB    $02                       ;;delete
        DEFB    $31                       ;;duplicate
        DEFB    $A2                       ;;stk-half
        DEFB    $04                       ;;multiply
        DEFB    $1F                       ;;sin
        DEFB    $C1                       ;;st-mem-1
        DEFB    $01                       ;;exchange
        DEFB    $C0                       ;;st-mem-0
        DEFB    $02                       ;;delete
        DEFB    $31                       ;;duplicate
        DEFB    $04                       ;;multiply
        DEFB    $31                       ;;duplicate
        DEFB    $0F                       ;;addition
        DEFB    $A1                       ;;stk-one
        DEFB    $03                       ;;subtract
        DEFB    $1B                       ;;negate
        DEFB    $C3                       ;;st-mem-3
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        POP     BC                        ;
        RET                               ;

; ------------
; Line drawing
; ------------
;
;

draw_line:
        CALL    stk_to_bc                 ; routine STK-TO-BC
        LD      A,C                       ;
        CP      B                         ;
        JR      NC,dl_x_ge_y              ; to DL-X-GE-Y

        LD      L,C                       ;
        PUSH    DE                        ;
        XOR     A                         ;
        LD      E,A                       ;
        JR      dl_larger                 ; to DL-LARGER

; ---

dl_x_ge_y:
        OR      C                         ;
        RET     Z                         ;

        LD      L,B                       ;
        LD      B,C                       ;
        PUSH    DE                        ;
        LD      D,$00                     ;

dl_larger:
        LD      H,B                       ;
        LD      A,B                       ;
        RRA                               ;

d_l_loop:
        ADD     A,L                       ;
        JR      C,d_l_diag                ; to D-L-DIAG

        CP      H                         ;
        JR      C,d_l_hr_vt               ; to D-L-HR-VT

d_l_diag:
        SUB     H                         ;
        LD      C,A                       ;
        EXX                               ;
        POP     BC                        ;
        PUSH    BC                        ;
        JR      d_l_step                  ; to D-L-STEP

; ---

d_l_hr_vt:
        LD      C,A                       ;
        PUSH    DE                        ;
        EXX                               ;
        POP     BC                        ;

d_l_step:
        LD      HL,(COORDS_X)             ; COORDS
        LD      A,B                       ;
        ADD     A,H                       ;
        LD      B,A                       ;
        LD      A,C                       ;
        INC     A                         ;
        ADD     A,L                       ;
        JR      C,d_l_range               ; to D-L-RANGE

        JR      Z,report_bc               ; to REPORT-Bc

d_l_plot:
        DEC     A                         ;
        LD      C,A                       ;
        CALL    plot_sub                  ; routine PLOT-SUB
        EXX                               ;
        LD      A,C                       ;
        DJNZ    d_l_loop                  ; to D-L-LOOP

        POP     DE                        ;
        RET                               ;

; ---

d_l_range:
        JR      Z,d_l_plot                ; to D-L-PLOT


report_bc:
        RST     08H                       ; ERROR-1
        DEFB    $0A                       ; Error Report: Integer out of range



;***********************************
;** Part 8. EXPRESSION EVALUATION **
;***********************************
;
; It is a this stage of the ROM that the Spectrum ceases altogether to be
; just a colourful novelty. One remarkable feature is that in all previous
; commands when the Spectrum is expecting a number or a string then an
; expression of the same type can be substituted ad infinitum.
; This is the routine that evaluates that expression.
; This is what causes 2 + 2 to give the answer 4.
; That is quite easy to understand. However you don't have to make it much
; more complex to start a remarkable juggling act.
; e.g. PRINT 2 * (VAL "2+2" + TAN 3)
; In fact, provided there is enough free RAM, the Spectrum can evaluate
; an expression of unlimited complexity.
; Apart from a couple of minor glitches, which you can now correct, the
; system is remarkably robust.


; ---------------------------------
; Scan expression or sub-expression
; ---------------------------------
;
;

scanning:
        RST     18H                       ; GET-CHAR
        LD      B,$00                     ; priority marker zero is pushed on stack
                                          ; to signify end of expression when it is
                                          ; popped off again.
        PUSH    BC                        ; put in on stack.
                                          ; and proceed to consider the first character
                                          ; of the expression.

s_loop_1:
        LD      C,A                       ; store the character while a look up is done.
        LD      HL,scan_func              ; Address: scan-func
        CALL    indexer                   ; routine INDEXER is called to see if it is
                                          ; part of a limited range '+', '(', 'ATTR' etc.

        LD      A,C                       ; fetch the character back
        JP      NC,s_alphnum              ; jump forward to S-ALPHNUM if not in primary
                                          ; operators and functions to consider in the
                                          ; first instance a digit or a variable and
                                          ; then anything else.                >>>

        LD      B,$00                     ; but here if it was found in table so
        LD      C,(HL)                    ; fetch offset from table and make B zero.
        ADD     HL,BC                     ; add the offset to position found
        JP      (HL)                      ; and jump to the routine e.g. S-BIN
                                          ; making an indirect exit from there.

; -------------------------------------------------------------------------
; The four service subroutines for routines in the scannings function table
; -------------------------------------------------------------------------

; PRINT """Hooray!"" he cried."

s_quote_s:
        CALL    ch_add_plus_1             ; routine CH-ADD+1 points to next character
                                          ; and fetches that character.
        INC     BC                        ; increase length counter.
        CP      $0D                       ; is it carriage return ?
                                          ; inside a quote.
        JP      Z,report_c                ; jump back to REPORT-C if so.
                                          ; 'Nonsense in BASIC'.

        CP      $22                       ; is it a quote '"' ?
        JR      NZ,s_quote_s              ; back to S-QUOTE-S if not for more.

        CALL    ch_add_plus_1             ; routine CH-ADD+1
        CP      $22                       ; compare with possible adjacent quote
        RET                               ; return. with zero set if two together.

; ---

; This subroutine is used to get two coordinate expressions for the three
; functions SCREEN$, ATTR and POINT that have two fixed parameters and
; therefore require surrounding braces.

s_2_coord:
        RST     20H                       ; NEXT-CHAR
        CP      $28                       ; is it the opening '(' ?
        JR      NZ,s_rport_c              ; forward to S-RPORT-C if not
                                          ; 'Nonsense in BASIC'.

        CALL    next_2num                 ; routine NEXT-2NUM gets two comma-separated
                                          ; numeric expressions. Note. this could cause
                                          ; many more recursive calls to SCANNING but
                                          ; the parent function will be evaluated fully
                                          ; before rejoining the main juggling act.

        RST     18H                       ; GET-CHAR
        CP      $29                       ; is it the closing ')' ?

s_rport_c:
        JP      NZ,report_c               ; jump back to REPORT-C if not.
                                          ; 'Nonsense in BASIC'.

; ------------
; Check syntax
; ------------
; This routine is called on a number of occasions to check if syntax is being
; checked or if the program is being run. To test the flag inline would use
; four bytes of code, but a call instruction only uses 3 bytes of code.

syntax_z:
        BIT     7,(IY+(FLAGS-C_IY))       ; test FLAGS  - checking syntax only ?
        RET                               ; return.

; ----------------
; Scanning SCREEN$
; ----------------
; This function returns the code of a bit-mapped character at screen
; position at line C, column B. It is unable to detect the mosaic characters
; which are not bit-mapped but detects the ASCII 32 - 127 range.
; The bit-mapped UDGs are ignored which is curious as it requires only a
; few extra bytes of code. As usual, anything to do with CHARS is weird.
; If no match is found a null string is returned.
; No actual check on ranges is performed - that's up to the BASIC programmer.
; No real harm can come from SCREEN$(255,255) although the BASIC manual
; says that invalid values will be trapped.
; Interestingly, in the Pitman pocket guide, 1984, Vickers says that the
; range checking will be performed.

s_scrnstring_s:
        CALL    stk_to_bc                 ; routine STK-TO-BC.
        LD      HL,(CHARS)                ; fetch address of CHARS.
        LD      DE,tkn_or                 ; fetch offset to chr$ 32
        ADD     HL,DE                     ; and find start of bitmaps.
                                          ; Note. not inc h. ??
        LD      A,C                       ; transfer line to A.
        RRCA                              ; multiply
        RRCA                              ; by
        RRCA                              ; thirty-two.
        AND     $E0                       ; and with 11100000
        XOR     B                         ; combine with column $00 - $1F
        LD      E,A                       ; to give the low byte of top line
        LD      A,C                       ; column to A range 00000000 to 00011111
        AND     $18                       ; and with 00011000
        XOR     $40                       ; xor with 01000000 (high byte screen start)
        LD      D,A                       ; register DE now holds start address of cell.
        LD      B,$60                     ; there are 96 characters in ASCII set.

s_scrn_lp:
        PUSH    BC                        ; save count
        PUSH    DE                        ; save screen start address
        PUSH    HL                        ; save bitmap start
        LD      A,(DE)                    ; first byte of screen to A
        XOR     (HL)                      ; xor with corresponding character byte
        JR      Z,s_sc_mtch               ; forward to S-SC-MTCH if they match
                                          ; if inverse result would be $FF
                                          ; if any other then mismatch

        INC     A                         ; set to $00 if inverse
        JR      NZ,s_scr_nxt              ; forward to S-SCR-NXT if a mismatch

        DEC     A                         ; restore $FF

; a match has been found so seven more to test.

s_sc_mtch:
        LD      C,A                       ; load C with inverse mask $00 or $FF
        LD      B,$07                     ; count seven more bytes

s_sc_rows:
        INC     D                         ; increment screen address.
        INC     HL                        ; increment bitmap address.
        LD      A,(DE)                    ; byte to A
        XOR     (HL)                      ; will give $00 or $FF (inverse)
        XOR     C                         ; xor with inverse mask
        JR      NZ,s_scr_nxt              ; forward to S-SCR-NXT if no match.

        DJNZ    s_sc_rows                 ; back to S-SC-ROWS until all eight matched.

; continue if a match of all eight bytes was found

        POP     BC                        ; discard the
        POP     BC                        ; saved
        POP     BC                        ; pointers
        LD      A,$80                     ; the endpoint of character set
        SUB     B                         ; subtract the counter
                                          ; to give the code 32-127
        LD      BC,$0001                  ; make one space in workspace.

        RST     30H                       ; BC-SPACES creates the space sliding
                                          ; the calculator stack upwards.
        LD      (DE),A                    ; start is addressed by DE, so insert code
        JR      s_scr_sto                 ; forward to S-SCR-STO

; ---

; the jump was here if no match and more bitmaps to test.

s_scr_nxt:
        POP     HL                        ; restore the last bitmap start
        LD      DE,error_1                ; and prepare to add 8.
        ADD     HL,DE                     ; now addresses next character bitmap.
        POP     DE                        ; restore screen address
        POP     BC                        ; and character counter in B
        DJNZ    s_scrn_lp                 ; back to S-SCRN-LP if more characters.

        LD      C,B                       ; B is now zero, so BC now zero.

s_scr_sto:
        JP      stk_sto_string            ; to STK-STO-$ to store the string in
                                          ; workspace or a string with zero length.
                                          ; (value of DE doesn't matter in last case)

; Note. this exit seems correct but the general-purpose routine S-STRING
; that calls this one will also stack any of its string results so this
; leads to a double storing of the result in this case.
; The instruction at s_scr_sto should just be a RET.
; credit Stephen Kelly and others, 1982.

; -------------
; Scanning ATTR
; -------------
; This function subroutine returns the attributes of a screen location -
; a numeric result.
; Again it's up to the BASIC programmer to supply valid values of line/column.

s_attr_s:
        CALL    stk_to_bc                 ; routine STK-TO-BC fetches line to C,
                                          ; and column to B.
        LD      A,C                       ; line to A $00 - $17   (max 00010111)
        RRCA                              ; rotate
        RRCA                              ; bits
        RRCA                              ; left.
        LD      C,A                       ; store in C as an intermediate value.

        AND     $E0                       ; pick up bits 11100000 ( was 00011100 )
        XOR     B                         ; combine with column $00 - $1F
        LD      L,A                       ; low byte now correct.

        LD      A,C                       ; bring back intermediate result from C
        AND     $03                       ; mask to give correct third of
                                          ; screen $00 - $02
        XOR     $58                       ; combine with base address.
        LD      H,A                       ; high byte correct.
        LD      A,(HL)                    ; pick up the colour attribute.
        JP      stack_a                   ; forward to STACK-A to store result
                                          ; and make an indirect exit.

; -----------------------
; Scanning function table
; -----------------------
; This table is used by INDEXER routine to find the offsets to
; four operators and eight functions. e.g. $A8 is the token 'FN'.
; This table is used in the first instance for the first character of an
; expression or by a recursive call to SCANNING for the first character of
; any sub-expression. It eliminates functions that have no argument or
; functions that can have more than one argument and therefore require
; braces. By eliminating and dealing with these now it can later take a
; simplistic approach to all other functions and assume that they have
; one argument.
; Similarly by eliminating BIN and '.' now it is later able to assume that
; all numbers begin with a digit and that the presence of a number or
; variable can be detected by a call to ALPHANUM.
; By default all expressions are positive and the spurious '+' is eliminated
; now as in print +2. This should not be confused with the operator '+'.
; Note. this does allow a degree of nonsense to be accepted as in
; PRINT +"3 is the greatest.".
; An acquired programming skill is the ability to include brackets where
; they are not necessary.
; A bracket at the start of a sub-expression may be spurious or necessary
; to denote that the contained expression is to be evaluated as an entity.
; In either case this is dealt with by recursive calls to SCANNING.
; An expression that begins with a quote requires special treatment.

scan_func:
        DEFB    $22
        DEFB    s_quote-$                 ; offset $1C to S-QUOTE
        DEFB    '('
        DEFB    s_bracket-$               ; offset $4F to S-BRACKET
        DEFB    '.'
        DEFB    s_decimal-$               ; offset $F2 to S-DECIMAL
        DEFB    '+'
        DEFB    s_u_plus-$                ; offset $12 to S-U-PLUS

        DEFB    $A8
        DEFB    s_fn-$                    ; offset $56 to S-FN
        DEFB    $A5
        DEFB    s_rnd-$                   ; offset $57 to S-RND
        DEFB    $A7
        DEFB    s_pi-$                    ; offset $84 to S-PI
        DEFB    $A6
        DEFB    s_inkeystring-$           ; offset $8F to S-INKEY$
        DEFB    $C4
        DEFB    s_bin-$                   ; offset $E6 to S-BIN
        DEFB    $AA
        DEFB    s_screenstring-$          ; offset $BF to S-SCREEN$
        DEFB    $AB
        DEFB    s_attr-$                  ; offset $C7 to S-ATTR
        DEFB    $A9
        DEFB    s_point-$                 ; offset $CE to S-POINT

        DEFB    $00                       ; zero end marker

; --------------------------
; Scanning function routines
; --------------------------
; These are the 11 subroutines accessed by the above table.
; S-BIN and S-DECIMAL are the same
; The 1-byte offset limits their location to within 255 bytes of their
; entry in the table.

; ->
s_u_plus:
        RST     20H                       ; NEXT-CHAR just ignore
        JP      s_loop_1                  ; to S-LOOP-1

; ---

; ->
s_quote:
        RST     18H                       ; GET-CHAR
        INC     HL                        ; address next character (first in quotes)
        PUSH    HL                        ; save start of quoted text.
        LD      BC,$0000                  ; initialize length of string to zero.
        CALL    s_quote_s                 ; routine S-QUOTE-S
        JR      NZ,s_q_prms               ; forward to S-Q-PRMS if

s_q_again:
        CALL    s_quote_s                 ; routine S-QUOTE-S copies string until a
                                          ; quote is encountered
        JR      Z,s_q_again               ; back to S-Q-AGAIN if two quotes WERE
                                          ; together.

; but if just an isolated quote then that terminates the string.

        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,s_q_prms                ; forward to S-Q-PRMS if checking syntax.


        RST     30H                       ; BC-SPACES creates the space for true
                                          ; copy of string in workspace.
        POP     HL                        ; re-fetch start of quoted text.
        PUSH    DE                        ; save start in workspace.

s_q_copy:
        LD      A,(HL)                    ; fetch a character from source.
        INC     HL                        ; advance source address.
        LD      (DE),A                    ; place in destination.
        INC     DE                        ; advance destination address.
        CP      $22                       ; was it a '"' just copied ?
        JR      NZ,s_q_copy               ; back to S-Q-COPY to copy more if not

        LD      A,(HL)                    ; fetch adjacent character from source.
        INC     HL                        ; advance source address.
        CP      $22                       ; is this '"' ? - i.e. two quotes together ?
        JR      Z,s_q_copy                ; to S-Q-COPY if so including just one of the
                                          ; pair of quotes.

; proceed when terminating quote encountered.

s_q_prms:
        DEC     BC                        ; decrease count by 1.
        POP     DE                        ; restore start of string in workspace.

s_string:
        LD      HL,FLAGS                  ; Address FLAGS system variable.
        RES     6,(HL)                    ; signal string result.
        BIT     7,(HL)                    ; is syntax being checked.
        CALL    NZ,stk_sto_string         ; routine STK-STO-$ is called in runtime.
        JP      s_cont_2                  ; jump forward to S-CONT-2          ===>

; ---

; ->
s_bracket:
        RST     20H                       ; NEXT-CHAR
        CALL    scanning                  ; routine SCANNING is called recursively.
        CP      $29                       ; is it the closing ')' ?
        JP      NZ,report_c               ; jump back to REPORT-C if not
                                          ; 'Nonsense in BASIC'

        RST     20H                       ; NEXT-CHAR
        JP      s_cont_2                  ; jump forward to S-CONT-2          ===>

; ---

; ->
s_fn:
        JP      s_fn_sbrn                 ; jump forward to S-FN-SBRN.

; ---

; ->
s_rnd:
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,s_rnd_end               ; forward to S-RND-END if checking syntax.

        LD      BC,(SEED)                 ; fetch system variable SEED
        CALL    stack_bc                  ; routine STACK-BC places on calculator stack

        RST     28H                       ;; FP-CALC           ;s.
        DEFB    $A1                       ;;stk-one            ;s,1.
        DEFB    $0F                       ;;addition           ;s+1.
        DEFB    $34                       ;;stk-data           ;
        DEFB    $37                       ;;Exponent: $87,
                                          ;;Bytes: 1
        DEFB    $16                       ;;(+00,+00,+00)      ;s+1,75.
        DEFB    $04                       ;;multiply           ;(s+1)*75 = v
        DEFB    $34                       ;;stk-data           ;v.
        DEFB    $80                       ;;Bytes: 3
        DEFB    $41                       ;;Exponent $91
        DEFB    $00,$00,$80               ;;(+00)              ;v,65537.
        DEFB    $32                       ;;n-mod-m            ;remainder, result.
        DEFB    $02                       ;;delete             ;remainder.
        DEFB    $A1                       ;;stk-one            ;remainder, 1.
        DEFB    $03                       ;;subtract           ;remainder - 1. = rnd
        DEFB    $31                       ;;duplicate          ;rnd,rnd.
        DEFB    $38                       ;;end-calc

        CALL    fp_to_bc                  ; routine FP-TO-BC
        LD      (SEED),BC                 ; store in SEED for next starting point.
        LD      A,(HL)                    ; fetch exponent
        AND     A                         ; is it zero ?
        JR      Z,s_rnd_end               ; forward if so to S-RND-END

        SUB     $10                       ; reduce exponent by 2^16
        LD      (HL),A                    ; place back

s_rnd_end:
        JR      s_pi_end                  ; forward to S-PI-END

; ---

; the number PI 3.14159...

; ->
s_pi:
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,s_pi_end                ; to S-PI-END if checking syntax.

        RST     28H                       ;; FP-CALC
        DEFB    $A3                       ;;stk-pi/2                          pi/2.
        DEFB    $38                       ;;end-calc

        INC     (HL)                      ; increment the exponent leaving pi
                                          ; on the calculator stack.

s_pi_end:
        RST     20H                       ; NEXT-CHAR
        JP      s_numeric                 ; jump forward to S-NUMERIC

; ---

; ->
s_inkeystring:
        LD      BC,$105A                  ; priority $10, operation code $1A ('read-in')
                                          ; +$40 for string result, numeric operand.
                                          ; set this up now in case we need to use the
                                          ; calculator.
        RST     20H                       ; NEXT-CHAR
        CP      $23                       ; '#' ?
        JP      Z,s_push_po               ; to S-PUSH-PO if so to use the calculator
                                          ; single operation
                                          ; to read from network/RS232 etc. .

; else read a key from the keyboard.

        LD      HL,FLAGS                  ; fetch FLAGS
        RES     6,(HL)                    ; signal string result.
        BIT     7,(HL)                    ; checking syntax ?
        JR      Z,s_inkstring_en          ; forward to S-INK$-EN if so

        JP      keyscan2                  ; Spectrum 128 patch

        LD      C,$00                     ; the length of an empty string
        JR      NZ,s_ikstring_stk         ; to S-IK$-STK to store empty string if
                                          ; no key returned.

        CALL    k_test                    ; routine K-TEST get main code in A
        JR      NC,s_ikstring_stk         ; to S-IK$-STK to stack null string if
                                          ; invalid

        DEC     D                         ; D is expected to be FLAGS so set bit 3 $FF
                                          ; 'L' Mode so no keywords.
        LD      E,A                       ; main key to A
                                          ; C is MODE 0 'KLC' from above still.
        CALL    k_decode                  ; routine K-DECODE
s_cont_get_str:
        PUSH    AF                        ; save the code
        LD      BC,$0001                  ; make room for one character

        RST     30H                       ; BC-SPACES
        POP     AF                        ; bring the code back
        LD      (DE),A                    ; put the key in workspace
        LD      C,$01                     ; set C length to one

s_ikstring_stk:
        LD      B,$00                     ; set high byte of length to zero
        CALL    stk_sto_string            ; routine STK-STO-$

s_inkstring_en:
        JP      s_cont_2                  ; to S-CONT-2            ===>

; ---

; ->
s_screenstring:
        CALL    s_2_coord                 ; routine S-2-COORD
        CALL    NZ,s_scrnstring_s         ; routine S-SCRN$-S

        RST     20H                       ; NEXT-CHAR
        JP      s_string                  ; forward to S-STRING to stack result

; ---

; ->
s_attr:
        CALL    s_2_coord                 ; routine S-2-COORD
        CALL    NZ,s_attr_s               ; routine S-ATTR-S

        RST     20H                       ; NEXT-CHAR
        JR      s_numeric                 ; forward to S-NUMERIC

; ---

; ->
s_point:
        CALL    s_2_coord                 ; routine S-2-COORD
        CALL    NZ,point_sub              ; routine POINT-SUB

        RST     20H                       ; NEXT-CHAR
        JR      s_numeric                 ; forward to S-NUMERIC

; -----------------------------

; ==> The branch was here if not in table.

s_alphnum:
        CALL    alphanum                  ; routine ALPHANUM checks if variable or
                                          ; a digit.
        JR      NC,s_negate               ; forward to S-NEGATE if not to consider
                                          ; a '-' character then functions.

        CP      $41                       ; compare 'A'
        JR      NC,s_letter               ; forward to S-LETTER if alpha       ->
                                          ; else must have been numeric so continue
                                          ; into that routine.

; This important routine is called during runtime and from LINE-SCAN
; when a BASIC line is checked for syntax. It is this routine that
; inserts, during syntax checking, the invisible floating point numbers
; after the numeric expression. During runtime it just picks these
; numbers up. It also handles BIN format numbers.

; ->
s_bin:
s_decimal:
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      NZ,s_stk_dec              ; to S-STK-DEC in runtime

; this route is taken when checking syntax.

        CALL    dec_to_fp                 ; routine DEC-TO-FP to evaluate number

        RST     18H                       ; GET-CHAR to fetch HL
        LD      BC,$0006                  ; six locations required
        CALL    make_room                 ; routine MAKE-ROOM
        INC     HL                        ; to first new location
        LD      (HL),$0E                  ; insert number marker
        INC     HL                        ; address next
        EX      DE,HL                     ; make DE destination.
        LD      HL,(STKEND)               ; STKEND points to end of stack.
        LD      C,$05                     ; result is five locations lower
        AND     A                         ; prepare for true subtraction
        SBC     HL,BC                     ; point to start of value.
        LD      (STKEND),HL               ; update STKEND as we are taking number.
        LDIR                              ; Copy five bytes to program location
        EX      DE,HL                     ; transfer pointer to HL
        DEC     HL                        ; adjust
        CALL    temp_ptr1                 ; routine TEMP-PTR1 sets CH-ADD
        JR      s_numeric                 ; to S-NUMERIC to record nature of result

; ---

; branch here in runtime.

s_stk_dec:
        RST     18H                       ; GET-CHAR positions HL at digit.

s_sd_skip:
        INC     HL                        ; advance pointer
        LD      A,(HL)                    ; until we find
        CP      $0E                       ; chr 14d - the number indicator
        JR      NZ,s_sd_skip              ; to S-SD-SKIP until a match
                                          ; it has to be here.

        INC     HL                        ; point to first byte of number
        CALL    stack_num                 ; routine STACK-NUM stacks it
        LD      (CH_ADD),HL               ; update system variable CH_ADD

s_numeric:
        SET     6,(IY+(FLAGS-C_IY))       ; update FLAGS  - Signal numeric result
        JR      s_cont_1                  ; forward to S-CONT-1               ===>
                                          ; actually S-CONT-2 is destination but why
                                          ; waste a byte on a jump when a JR will do.
                                          ; actually a JR s_cont_2 can be used. Rats.

; end of functions accessed from scanning functions table.

; --------------------------
; Scanning variable routines
; --------------------------
;
;

s_letter:
        CALL    look_vars                 ; routine LOOK-VARS
        JP      C,report_2                ; jump back to REPORT-2 if not found
                                          ; 'Variable not found'
                                          ; but a variable is always 'found' if syntax
                                          ; is being checked.

        CALL    Z,stk_var                 ; routine STK-VAR considers a subscript/slice
        LD      A,(FLAGS)                 ; fetch FLAGS value
        CP      $C0                       ; compare 11000000
        JR      C,s_cont_1                ; step forward to S-CONT-1 if string  ===>

        INC     HL                        ; advance pointer
        CALL    stack_num                 ; routine STACK-NUM

s_cont_1:
        JR      s_cont_2                  ; forward to S-CONT-2                 ===>

; ----------------------------------------
; -> the scanning branch was here if not alphanumeric.
; All the remaining functions will be evaluated by a single call to the
; calculator. The correct priority for the operation has to be placed in
; the B register and the operation code, calculator literal in the C register.
; the operation code has bit 7 set if result is numeric and bit 6 is
; set if operand is numeric. so
; $C0 = numeric result, numeric operand.            e.g. 'sin'
; $80 = numeric result, string operand.             e.g. 'code'
; $40 = string result, numeric operand.             e.g. 'str$'
; $00 = string result, string operand.              e.g. 'val$'

s_negate:
        LD      BC,$09DB                  ; prepare priority 09, operation code $C0 +
                                          ; 'negate' ($1B) - bits 6 and 7 set for numeric
                                          ; result and numeric operand.

        CP      $2D                       ; is it '-' ?
        JR      Z,s_push_po               ; forward if so to S-PUSH-PO

        LD      BC,$1018                  ; prepare priority $10, operation code 'val$' -
                                          ; bits 6 and 7 reset for string result and
                                          ; string operand.

        CP      $AE                       ; is it 'VAL$' ?
        JR      Z,s_push_po               ; forward if so to S-PUSH-PO

        SUB     $AF                       ; subtract token 'CODE' value to reduce
                                          ; functions 'CODE' to 'NOT' although the
                                          ; upper range is, as yet, unchecked.
                                          ; valid range would be $00 - $14.

        JP      C,report_c                ; jump back to REPORT-C with anything else
                                          ; 'Nonsense in BASIC'

        LD      BC,$04F0                  ; prepare priority $04, operation $C0 +
                                          ; 'not' ($30)

        CP      $14                       ; is it 'NOT'
        JR      Z,s_push_po               ; forward to S-PUSH-PO if so

        JP      NC,report_c               ; to REPORT-C if higher
                                          ; 'Nonsense in BASIC'

        LD      B,$10                     ; priority $10 for all the rest
        ADD     A,$DC                     ; make range $DC - $EF
                                          ; $C0 + 'code'($1C) thru 'chr$' ($2F)

        LD      C,A                       ; transfer 'function' to C
        CP      $DF                       ; is it 'sin' ?
        JR      NC,s_no_to_string         ; forward to S-NO-TO-$  with 'sin' through
                                          ; 'chr$' as operand is numeric.

; all the rest 'cos' through 'chr$' give a numeric result except 'str$'
; and 'chr$'.

        RES     6,C                       ; signal string operand for 'code', 'val' and
                                          ; 'len'.

s_no_to_string:
        CP      $EE                       ; compare 'str$'
        JR      C,s_push_po               ; forward to S-PUSH-PO if lower as result
                                          ; is numeric.

        RES     7,C                       ; reset bit 7 of op code for 'str$', 'chr$'
                                          ; as result is string.

; >> This is where they were all headed for.

s_push_po:
        PUSH    BC                        ; push the priority and calculator operation
                                          ; code.

        RST     20H                       ; NEXT-CHAR
        JP      s_loop_1                  ; jump back to S-LOOP-1 to go round the loop
                                          ; again with the next character.

; --------------------------------

; ===>  there were many branches forward to here

s_cont_2:
        RST     18H                       ; GET-CHAR

s_cont_3:
        CP      $28                       ; is it '(' ?
        JR      NZ,s_opertr               ; forward to S-OPERTR if not    >

        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS - numeric or string result ?
        JR      NZ,s_loop                 ; forward to S-LOOP if numeric to evaluate  >

; if a string preceded '(' then slice it.

        CALL    slicing                   ; routine SLICING

        RST     20H                       ; NEXT-CHAR
        JR      s_cont_3                  ; back to S-CONT-3

; ---------------------------

; the branch was here when possibility of an operator '(' has been excluded.

s_opertr:
        LD      B,$00                     ; prepare to add
        LD      C,A                       ; possible operator to C
        LD      HL,tbl_of_ops             ; Address: tbl_of_ops - tbl-of-ops
        CALL    indexer                   ; routine INDEXER
        JR      NC,s_loop                 ; forward to S-LOOP if not in table

; but if found in table the priority has to be looked up.

        LD      C,(HL)                    ; operation code to C ( B is still zero )
        LD      HL,tbl_priors - $C3       ; $26ED is base of table
        ADD     HL,BC                     ; index into table.
        LD      B,(HL)                    ; priority to B.

; ------------------
; Scanning main loop
; ------------------
; the juggling act

s_loop:
        POP     DE                        ; fetch last priority and operation
        LD      A,D                       ; priority to A
        CP      B                         ; compare with this one
        JR      C,s_tighter               ; forward to S-TIGHTER to execute the
                                          ; last operation before this one as it has
                                          ; higher priority.

; the last priority was greater or equal this one.

        AND     A                         ; if it is zero then so is this
        JP      Z,get_char                ; jump to exit via get-char pointing at
                                          ; next character.
                                          ; This may be the character after the
                                          ; expression or, if exiting a recursive call,
                                          ; the next part of the expression to be
                                          ; evaluated.

        PUSH    BC                        ; save current priority/operation
                                          ; as it has lower precedence than the one
                                          ; now in DE.

; the 'USR' function is special in that it is overloaded to give two types
; of result.

        LD      HL,FLAGS                  ; address FLAGS
        LD      A,E                       ; new operation to A register
        CP      $ED                       ; is it $C0 + 'usr-no' ($2D)  ?
        JR      NZ,s_stk_lst              ; forward to S-STK-LST if not

        BIT     6,(HL)                    ; string result expected ?
                                          ; (from the lower priority operand we've
                                          ; just pushed on stack )
        JR      NZ,s_stk_lst              ; forward to S-STK-LST if numeric
                                          ; as operand bits match.

        LD      E,$99                     ; reset bit 6 and substitute $19 'usr-$'
                                          ; for string operand.

s_stk_lst:
        PUSH    DE                        ; now stack this priority/operation
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,s_syntest               ; forward to S-SYNTEST if checking syntax.

        LD      A,E                       ; fetch the operation code
        AND     $3F                       ; mask off the result/operand bits to leave
                                          ; a calculator literal.
        LD      B,A                       ; transfer to B register

; now use the calculator to perform the single operation - operand is on
; the calculator stack.
; Note. although the calculator is performing a single operation most
; functions e.g. TAN are written using other functions and literals and
; these in turn are written using further strings of calculator literals so
; another level of magical recursion joins the juggling act for a while
; as the calculator too is calling itself.

        RST     28H                       ;; FP-CALC
        DEFB    $3B                       ;;fp-calc-2
        DEFB    $38                       ;;end-calc

        JR      s_runtest                 ; forward to S-RUNTEST

; ---

; the branch was here if checking syntax only.

s_syntest:
        LD      A,E                       ; fetch the operation code to accumulator
        XOR     (IY+(FLAGS-C_IY))         ; compare with bits of FLAGS
        AND     $40                       ; bit 6 will be zero now if operand
                                          ; matched expected result.

s_rport_c2:
        JP      NZ,report_c               ; to REPORT-C if mismatch
                                          ; 'Nonsense in BASIC'
                                          ; else continue to set flags for next

; the branch is to here in runtime after a successful operation.

s_runtest:
        POP     DE                        ; fetch the last operation from stack
        LD      HL,FLAGS                  ; address FLAGS
        SET     6,(HL)                    ; set default to numeric result in FLAGS
        BIT     7,E                       ; test the operational result
        JR      NZ,s_loopend              ; forward to S-LOOPEND if numeric

        RES     6,(HL)                    ; reset bit 6 of FLAGS to show string result.

s_loopend:
        POP     BC                        ; fetch the previous priority/operation
        JR      s_loop                    ; back to S-LOOP to perform these

; ---

; the branch was here when a stacked priority/operator had higher priority
; than the current one.

s_tighter:
        PUSH    DE                        ; save high priority op on stack again
        LD      A,C                       ; fetch lower priority operation code
        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS - Numeric or string result ?
        JR      NZ,s_next                 ; forward to S-NEXT if numeric result

; if this is lower priority yet has string then must be a comparison.
; Since these can only be evaluated in context and were defaulted to
; numeric in operator look up they must be changed to string equivalents.

        AND     $3F                       ; mask to give true calculator literal
        ADD     A,$08                     ; augment numeric literals to string
                                          ; equivalents.
                                          ; 'no-&-no'  => 'str-&-no'
                                          ; 'no-l-eql' => 'str-l-eql'
                                          ; 'no-gr-eq' => 'str-gr-eq'
                                          ; 'nos-neql' => 'strs-neql'
                                          ; 'no-grtr'  => 'str-grtr'
                                          ; 'no-less'  => 'str-less'
                                          ; 'nos-eql'  => 'strs-eql'
                                          ; 'addition' => 'strs-add'
        LD      C,A                       ; put modified comparison operator back
        CP      $10                       ; is it now 'str-&-no' ?
        JR      NZ,s_not_and              ; forward to S-NOT-AND  if not.

        SET     6,C                       ; set numeric operand bit
        JR      s_next                    ; forward to S-NEXT

; ---

s_not_and:
        JR      C,s_rport_c2              ; back to S-RPORT-C2 if less
                                          ; 'Nonsense in BASIC'.
                                          ; e.g. a$ * b$

        CP      $17                       ; is it 'strs-add' ?
        JR      Z,s_next                  ; forward to to S-NEXT if so
                                          ; (bit 6 and 7 are reset)

        SET     7,C                       ; set numeric (Boolean) result for all others

s_next:
        PUSH    BC                        ; now save this priority/operation on stack

        RST     20H                       ; NEXT-CHAR
        JP      s_loop_1                  ; jump back to S-LOOP-1

; ------------------
; Table of operators
; ------------------
; This table is used to look up the calculator literals associated with
; the operator character. The thirteen calculator operations $03 - $0F
; have bits 6 and 7 set to signify a numeric result.
; Some of these codes and bits may be altered later if the context suggests
; a string comparison or operation.
; that is '+', '=', '>', '<', '<=', '>=' or '<>'.

tbl_of_ops:
        DEFB    '+', $CF                  ;        $C0 + 'addition'
        DEFB    '-', $C3                  ;        $C0 + 'subtract'
        DEFB    '*', $C4                  ;        $C0 + 'multiply'
        DEFB    '/', $C5                  ;        $C0 + 'division'
        DEFB    '^', $C6                  ;        $C0 + 'to-power'
        DEFB    '=', $CE                  ;        $C0 + 'nos-eql'
        DEFB    '>', $CC                  ;        $C0 + 'no-grtr'
        DEFB    '<', $CD                  ;        $C0 + 'no-less'

        DEFB    $C7, $C9                  ; '<='   $C0 + 'no-l-eql'
        DEFB    $C8, $CA                  ; '>='   $C0 + 'no-gr-eql'
        DEFB    $C9, $CB                  ; '<>'   $C0 + 'nos-neql'
        DEFB    $C5, $C7                  ; 'OR'   $C0 + 'or'
        DEFB    $C6, $C8                  ; 'AND'  $C0 + 'no-&-no'

        DEFB    $00                       ; zero end-marker.


; -------------------
; Table of priorities
; -------------------
; This table is indexed with the operation code obtained from the above
; table $C3 - $CF to obtain the priority for the respective operation.

tbl_priors:
        DEFB    $06                       ; '-'   opcode $C3
        DEFB    $08                       ; '*'   opcode $C4
        DEFB    $08                       ; '/'   opcode $C5
        DEFB    $0A                       ; '^'   opcode $C6
        DEFB    $02                       ; 'OR'  opcode $C7
        DEFB    $03                       ; 'AND' opcode $C8
        DEFB    $05                       ; '<='  opcode $C9
        DEFB    $05                       ; '>='  opcode $CA
        DEFB    $05                       ; '<>'  opcode $CB
        DEFB    $05                       ; '>'   opcode $CC
        DEFB    $05                       ; '<'   opcode $CD
        DEFB    $05                       ; '='   opcode $CE
        DEFB    $06                       ; '+'   opcode $CF

; ----------------------
; Scanning function (FN)
; ----------------------
; This routine deals with user-defined functions.
; The definition can be anywhere in the program area but these are best
; placed near the start of the program as we shall see.
; The evaluation process is quite complex as the Spectrum has to parse two
; statements at the same time. Syntax of both has been checked previously
; and hidden locations have been created immediately after each argument
; of the DEF FN statement. Each of the arguments of the FN function is
; evaluated by SCANNING and placed in the hidden locations. Then the
; expression to the right of the DEF FN '=' is evaluated by SCANNING and for
; any variables encountered, a search is made in the DEF FN variable list
; in the program area before searching in the normal variables area.
;
; Recursion is not allowed: i.e. the definition of a function should not use
; the same function, either directly or indirectly ( through another function).
; You'll normally get error 4, ('Out of memory'), although sometimes the sytem
; will crash. - Vickers, Pitman 1984.
;
; As the definition is just an expression, there would seem to be no means
; of breaking out of such recursion.
; However, by the clever use of string expressions and VAL, such recursion is
; possible.
; e.g. DEF FN a(n) = VAL "n+FN a(n-1)+0" ((n<1) * 10 + 1 TO )
; will evaluate the full 11-character expression for all values where n is
; greater than zero but just the 11th character, "0", when n drops to zero
; thereby ending the recursion producing the correct result.
; Recursive string functions are possible using VAL$ instead of VAL and the
; null string as the final addend.
; - from a turn of the century newsgroup discussion initiated by Mike Wynne.

s_fn_sbrn:
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      NZ,sf_run                 ; forward to SF-RUN in runtime


        RST     20H                       ; NEXT-CHAR
        CALL    alpha                     ; routine ALPHA check for letters A-Z a-z
        JP      NC,report_c               ; jump back to REPORT-C if not
                                          ; 'Nonsense in BASIC'


        RST     20H                       ; NEXT-CHAR
        CP      $24                       ; is it '$' ?
        PUSH    AF                        ; save character and flags
        JR      NZ,sf_brkt_1              ; forward to SF-BRKT-1 with numeric function


        RST     20H                       ; NEXT-CHAR

sf_brkt_1:
        CP      $28                       ; is '(' ?
        JR      NZ,sf_rprt_c              ; forward to SF-RPRT-C if not
                                          ; 'Nonsense in BASIC'


        RST     20H                       ; NEXT-CHAR
        CP      $29                       ; is it ')' ?
        JR      Z,sf_flag_6               ; forward to SF-FLAG-6 if no arguments.

sf_argmts:
        CALL    scanning                  ; routine SCANNING checks each argument
                                          ; which may be an expression.

        RST     18H                       ; GET-CHAR
        CP      $2C                       ; is it a ',' ?
        JR      NZ,sf_brkt_2              ; forward if not to SF-BRKT-2 to test bracket


        RST     20H                       ; NEXT-CHAR if a comma was found
        JR      sf_argmts                 ; back to SF-ARGMTS to parse all arguments.

; ---

sf_brkt_2:
        CP      $29                       ; is character the closing ')' ?

sf_rprt_c:
        JP      NZ,report_c               ; jump to REPORT-C
                                          ; 'Nonsense in BASIC'

; at this point any optional arguments have had their syntax checked.

sf_flag_6:
        RST     20H                       ; NEXT-CHAR
        LD      HL,FLAGS                  ; address system variable FLAGS
        RES     6,(HL)                    ; signal string result
        POP     AF                        ; restore test against '$'.
        JR      Z,sf_syn_en               ; forward to SF-SYN-EN if string function.

        SET     6,(HL)                    ; signal numeric result

sf_syn_en:
        JP      s_cont_2                  ; jump back to S-CONT-2 to continue scanning.

; ---

; the branch was here in runtime.

sf_run:
        RST     20H                       ; NEXT-CHAR fetches name
        AND     $DF                       ; AND 11101111 - reset bit 5 - upper-case.
        LD      B,A                       ; save in B

        RST     20H                       ; NEXT-CHAR
        SUB     $24                       ; subtract '$'
        LD      C,A                       ; save result in C
        JR      NZ,sf_argmt1              ; forward if not '$' to SF-ARGMT1

        RST     20H                       ; NEXT-CHAR advances to bracket

sf_argmt1:
        RST     20H                       ; NEXT-CHAR advances to start of argument
        PUSH    HL                        ; save address
        LD      HL,(PROG)                 ; fetch start of program area from PROG
        DEC     HL                        ; the search starting point is the previous
                                          ; location.

sf_fnd_df:
        LD      DE,$00CE                  ; search is for token 'DEF FN' in E,
                                          ; statement count in D.
        PUSH    BC                        ; save C the string test, and B the letter.
        CALL    look_prog                 ; routine LOOK-PROG will search for token.
        POP     BC                        ; restore BC.
        JR      NC,sf_cp_def              ; forward to SF-CP-DEF if a match was found.


report_p:
        RST     08H                       ; ERROR-1
        DEFB    $18                       ; Error Report: FN without DEF

sf_cp_def:
        PUSH    HL                        ; save address of DEF FN
        CALL    fn_skpovr                 ; routine FN-SKPOVR skips over white-space etc.
                                          ; without disturbing CH-ADD.
        AND     $DF                       ; make fetched character upper-case.
        CP      B                         ; compare with FN name
        JR      NZ,sf_not_fd              ; forward to SF-NOT-FD if no match.

; the letters match so test the type.

        CALL    fn_skpovr                 ; routine FN-SKPOVR skips white-space
        SUB     $24                       ; subtract '$' from fetched character
        CP      C                         ; compare with saved result of same operation
                                          ; on FN name.
        JR      Z,sf_values               ; forward to SF-VALUES with a match.

; the letters matched but one was string and the other numeric.

sf_not_fd:
        POP     HL                        ; restore search point.
        DEC     HL                        ; make location before
        LD      DE,$0200                  ; the search is to be for the end of the
                                          ; current definition - 2 statements forward.
        PUSH    BC                        ; save the letter/type
        CALL    each_stmt                 ; routine EACH-STMT steps past rejected
                                          ; definition.
        POP     BC                        ; restore letter/type
        JR      sf_fnd_df                 ; back to SF-FND-DF to continue search

; ---

; Success!
; the branch was here with matching letter and numeric/string type.

sf_values:
        AND     A                         ; test A ( will be zero if string '$' - '$' )

        CALL    Z,fn_skpovr               ; routine FN-SKPOVR advances HL past '$'.

        POP     DE                        ; discard pointer to 'DEF FN'.
        POP     DE                        ; restore pointer to first FN argument.
        LD      (CH_ADD),DE               ; save in CH_ADD

        CALL    fn_skpovr                 ; routine FN-SKPOVR advances HL past '('
        PUSH    HL                        ; save start address in DEF FN  ***
        CP      $29                       ; is character a ')' ?
        JR      Z,sf_r_br_2               ; forward to SF-R-BR-2 if no arguments.

sf_arg_lp:
        INC     HL                        ; point to next character.
        LD      A,(HL)                    ; fetch it.
        CP      $0E                       ; is it the number marker
        LD      D,$40                     ; signal numeric in D.
        JR      Z,sf_arg_vl               ; forward to SF-ARG-VL if numeric.

        DEC     HL                        ; back to letter
        CALL    fn_skpovr                 ; routine FN-SKPOVR skips any white-space
        INC     HL                        ; advance past the expected '$' to
                                          ; the 'hidden' marker.
        LD      D,$00                     ; signal string.

sf_arg_vl:
        INC     HL                        ; now address first of 5-byte location.
        PUSH    HL                        ; save address in DEF FN statement
        PUSH    DE                        ; save D - result type

        CALL    scanning                  ; routine SCANNING evaluates expression in
                                          ; the FN statement setting FLAGS and leaving
                                          ; result as last value on calculator stack.

        POP     AF                        ; restore saved result type to A

        XOR     (IY+(FLAGS-C_IY))         ; xor with FLAGS
        AND     $40                       ; and with 01000000 to test bit 6
        JR      NZ,report_q               ; forward to REPORT-Q if type mismatch.
                                          ; 'Parameter error'

        POP     HL                        ; pop the start address in DEF FN statement
        EX      DE,HL                     ; transfer to DE ?? pop straight into de ?

        LD      HL,(STKEND)               ; set HL to STKEND location after value
        LD      BC,$0005                  ; five bytes to move
        SBC     HL,BC                     ; decrease HL by 5 to point to start.
        LD      (STKEND),HL               ; set STKEND 'removing' value from stack.

        LDIR                              ; copy value into DEF FN statement
        EX      DE,HL                     ; set HL to location after value in DEF FN
        DEC     HL                        ; step back one
        CALL    fn_skpovr                 ; routine FN-SKPOVR gets next valid character
        CP      $29                       ; is it ')' end of arguments ?
        JR      Z,sf_r_br_2               ; forward to SF-R-BR-2 if so.

; a comma separator has been encountered in the DEF FN argument list.

        PUSH    HL                        ; save position in DEF FN statement

        RST     18H                       ; GET-CHAR from FN statement
        CP      $2C                       ; is it ',' ?
        JR      NZ,report_q               ; forward to REPORT-Q if not
                                          ; 'Parameter error'

        RST     20H                       ; NEXT-CHAR in FN statement advances to next
                                          ; argument.

        POP     HL                        ; restore DEF FN pointer
        CALL    fn_skpovr                 ; routine FN-SKPOVR advances to corresponding
                                          ; argument.

        JR      sf_arg_lp                 ; back to SF-ARG-LP looping until all
                                          ; arguments are passed into the DEF FN
                                          ; hidden locations.

; ---

; the branch was here when all arguments passed.

sf_r_br_2:
        PUSH    HL                        ; save location of ')' in DEF FN

        RST     18H                       ; GET-CHAR gets next character in FN
        CP      $29                       ; is it a ')' also ?
        JR      Z,sf_value                ; forward to SF-VALUE if so.


report_q:
        RST     08H                       ; ERROR-1
        DEFB    $19                       ; Error Report: Parameter error

sf_value:
        POP     DE                        ; location of ')' in DEF FN to DE.
        EX      DE,HL                     ; now to HL, FN ')' pointer to DE.
        LD      (CH_ADD),HL               ; initialize CH_ADD to this value.

; At this point the start of the DEF FN argument list is on the machine stack.
; We also have to consider that this defined function may form part of the
; definition of another defined function (though not itself).
; As this defined function may be part of a hierarchy of defined functions
; currently being evaluated by recursive calls to SCANNING, then we have to
; preserve the original value of DEFADD and not assume that it is zero.

        LD      HL,(DEFADD)               ; get original DEFADD address
        EX      (SP),HL                   ; swap with DEF FN address on stack ***
        LD      (DEFADD),HL               ; set DEFADD to point to this argument list
                                          ; during scanning.

        PUSH    DE                        ; save FN ')' pointer.

        RST     20H                       ; NEXT-CHAR advances past ')' in define

        RST     20H                       ; NEXT-CHAR advances past '=' to expression

        CALL    scanning                  ; routine SCANNING evaluates but searches
                                          ; initially for variables at DEFADD

        POP     HL                        ; pop the FN ')' pointer
        LD      (CH_ADD),HL               ; set CH_ADD to this
        POP     HL                        ; pop the original DEFADD value
        LD      (DEFADD),HL               ; and re-insert into DEFADD system variable.

        RST     20H                       ; NEXT-CHAR advances to character after ')'
        JP      s_cont_2                  ; to S-CONT-2 - to continue current
                                          ; invocation of scanning

; --------------------
; Used to parse DEF FN
; --------------------
; e.g. DEF FN     s $ ( x )     =  b     $ (  TO  x  ) : REM exaggerated
;
; This routine is used 10 times to advance along a DEF FN statement
; skipping spaces and colour control codes. It is similar to NEXT-CHAR
; which is, at the same time, used to skip along the corresponding FN function
; except the latter has to deal with AT and TAB characters in string
; expressions. These cannot occur in a program area so this routine is
; simpler as both colour controls and their parameters are less than space.

fn_skpovr:
        INC     HL                        ; increase pointer
        LD      A,(HL)                    ; fetch addressed character
        CP      $21                       ; compare with space + 1
        JR      C,fn_skpovr               ; back to FN-SKPOVR if less

        RET                               ; return pointing to a valid character.

; ---------
; LOOK-VARS
; ---------
;
;

look_vars:
        SET     6,(IY+(FLAGS-C_IY))       ; update FLAGS - presume numeric result

        RST     18H                       ; GET-CHAR
        CALL    alpha                     ; routine ALPHA tests for A-Za-z
        JP      NC,report_c               ; jump to REPORT-C if not.
                                          ; 'Nonsense in BASIC'

        PUSH    HL                        ; save pointer to first letter       ^1
        AND     $1F                       ; mask lower bits, 1 - 26 decimal     000xxxxx
        LD      C,A                       ; store in C.

        RST     20H                       ; NEXT-CHAR
        PUSH    HL                        ; save pointer to second character   ^2
        CP      $28                       ; is it '(' - an array ?
        JR      Z,v_runslashsyn           ; forward to V-RUN/SYN if so.

        SET     6,C                       ; set 6 signaling string if solitary  010
        CP      $24                       ; is character a '$' ?
        JR      Z,v_str_var               ; forward to V-STR-VAR

        SET     5,C                       ; signal numeric                       011
        CALL    alphanum                  ; routine ALPHANUM sets carry if second
                                          ; character is alphanumeric.
        JR      NC,v_test_fn              ; forward to V-TEST-FN if just one character

; it is more than one character but re-test current character so that 6 reset
; Note. this is a rare lack of elegance. Bit 6 could be reset once before
; entering the loop. Another puzzle is that this loop renders the similar
; loop at V-PASS redundant.

v_char:
        CALL    alphanum                  ; routine ALPHANUM
        JR      NC,v_runslashsyn          ; to V-RUN/SYN when no more

        RES     6,C                       ; make long named type                 001

        RST     20H                       ; NEXT-CHAR
        JR      v_char                    ; loop back to V-CHAR

; ---


v_str_var:
        RST     20H                       ; NEXT-CHAR advances past '$'
        RES     6,(IY+(FLAGS-C_IY))       ; update FLAGS - signal string result.

v_test_fn:
        LD      A,(DEFADD_hi)             ; load A with DEFADD_hi
        AND     A                         ; and test for zero.
        JR      Z,v_runslashsyn           ; forward to V-RUN/SYN if a defined function
                                          ; is not being evaluated.

; Note.

        CALL    syntax_z                  ; routine SYNTAX-Z
        JP      NZ,stk_f_arg              ; JUMP to STK-F-ARG in runtime and then
                                          ; back to this point if no variable found.

v_runslashsyn:
        LD      B,C                       ; save flags in B
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      NZ,v_run                  ; to V-RUN to look for the variable in runtime

; if checking syntax the letter is not returned

        LD      A,C                       ; copy letter/flags to A
        AND     $E0                       ; and with 11100000 to get rid of the letter
        SET     7,A                       ; use spare bit to signal checking syntax.
        LD      C,A                       ; and transfer to C.
        JR      v_syntax                  ; forward to V-SYNTAX

; ---

; but in runtime search for the variable.

v_run:
        LD      HL,(VARS)                 ; set HL to start of variables from VARS

v_each:
        LD      A,(HL)                    ; get first character
        AND     $7F                       ; and with 01111111
                                          ; ignoring bit 7 which distinguishes
                                          ; arrays or for/next variables.

        JR      Z,v_80_byte               ; to V-80-BYTE if zero as must be 10000000
                                          ; the variables end-marker.

        CP      C                         ; compare with supplied value.
        JR      NZ,v_next                 ; forward to V-NEXT if no match.

        RLA                               ; destructively test
        ADD     A,A                       ; bits 5 and 6 of A
                                          ; jumping if bit 5 reset or 6 set

        JP      P,v_found_2               ; to V-FOUND-2  strings and arrays

        JR      C,v_found_2               ; to V-FOUND-2  simple and for next

; leaving long name variables.

        POP     DE                        ; pop pointer to 2nd. char
        PUSH    DE                        ; save it again
        PUSH    HL                        ; save variable first character pointer

v_matches:
        INC     HL                        ; address next character in vars area

v_spaces:
        LD      A,(DE)                    ; pick up letter from prog area
        INC     DE                        ; and advance address
        CP      $20                       ; is it a space
        JR      Z,v_spaces                ; back to V-SPACES until non-space

        OR      $20                       ; convert to range 1 - 26.
        CP      (HL)                      ; compare with addressed variables character
        JR      Z,v_matches               ; loop back to V-MATCHES if a match on an
                                          ; intermediate letter.

        OR      $80                       ; now set bit 7 as last character of long
                                          ; names are inverted.
        CP      (HL)                      ; compare again
        JR      NZ,v_get_ptr              ; forward to V-GET-PTR if no match

; but if they match check that this is also last letter in prog area

        LD      A,(DE)                    ; fetch next character
        CALL    alphanum                  ; routine ALPHANUM sets carry if not alphanum
        JR      NC,v_found_1              ; forward to V-FOUND-1 with a full match.

v_get_ptr:
        POP     HL                        ; pop saved pointer to char 1

v_next:
        PUSH    BC                        ; save flags
        CALL    next_one                  ; routine NEXT-ONE gets next variable in DE
        EX      DE,HL                     ; transfer to HL.
        POP     BC                        ; restore the flags
        JR      v_each                    ; loop back to V-EACH
                                          ; to compare each variable

; ---

v_80_byte:
        SET     7,B                       ; will signal not found

; the branch was here when checking syntax

v_syntax:
        POP     DE                        ; discard the pointer to 2nd. character  v2
                                          ; in BASIC line/workspace.

        RST     18H                       ; GET-CHAR gets character after variable name.
        CP      $28                       ; is it '(' ?
        JR      Z,v_pass                  ; forward to V-PASS
                                          ; Note. could go straight to V-END ?

        SET     5,B                       ; signal not an array
        JR      v_end                     ; forward to V-END

; ---------------------------

; the jump was here when a long name matched and HL pointing to last character
; in variables area.

v_found_1:
        POP     DE                        ; discard pointer to first var letter

; the jump was here with all other matches HL points to first var char.

v_found_2:
        POP     DE                        ; discard pointer to 2nd prog char       v2
        POP     DE                        ; drop pointer to 1st prog char          v1
        PUSH    HL                        ; save pointer to last char in vars

        RST     18H                       ; GET-CHAR

v_pass:
        CALL    alphanum                  ; routine ALPHANUM
        JR      NC,v_end                  ; forward to V-END if not

; but it never will be as we advanced past long-named variables earlier.

        RST     20H                       ; NEXT-CHAR
        JR      v_pass                    ; back to V-PASS

; ---

v_end:
        POP     HL                        ; pop the pointer to first character in
                                          ; BASIC line/workspace.
        RL      B                         ; rotate the B register left
                                          ; bit 7 to carry
        BIT     6,B                       ; test the array indicator bit.
        RET                               ; return

; -----------------------
; Stack function argument
; -----------------------
; This branch is taken from LOOK-VARS when a defined function is currently
; being evaluated.
; Scanning is evaluating the expression after the '=' and the variable
; found could be in the argument list to the left of the '=' or in the
; normal place after the program. Preference will be given to the former.
; The variable name to be matched is in C.

stk_f_arg:
        LD      HL,(DEFADD)               ; set HL to DEFADD
        LD      A,(HL)                    ; load the first character
        CP      $29                       ; is it ')' ?
        JP      Z,v_runslashsyn           ; JUMP back to V-RUN/SYN, if so, as there are
                                          ; no arguments.

; but proceed to search argument list of defined function first if not empty.

sfa_loop:
        LD      A,(HL)                    ; fetch character again.
        OR      $60                       ; or with 01100000 presume a simple variable.
        LD      B,A                       ; save result in B.
        INC     HL                        ; address next location.
        LD      A,(HL)                    ; pick up byte.
        CP      $0E                       ; is it the number marker ?
        JR      Z,sfa_cp_vr               ; forward to SFA-CP-VR if so.

; it was a string. White-space may be present but syntax has been checked.

        DEC     HL                        ; point back to letter.
        CALL    fn_skpovr                 ; routine FN-SKPOVR skips to the '$'
        INC     HL                        ; now address the hidden marker.
        RES     5,B                       ; signal a string variable.

sfa_cp_vr:
        LD      A,B                       ; transfer found variable letter to A.
        CP      C                         ; compare with expected.
        JR      Z,sfa_match               ; forward to SFA-MATCH with a match.

        INC     HL                        ; step
        INC     HL                        ; past
        INC     HL                        ; the
        INC     HL                        ; five
        INC     HL                        ; bytes.

        CALL    fn_skpovr                 ; routine FN-SKPOVR skips to next character
        CP      $29                       ; is it ')' ?
        JP      Z,v_runslashsyn           ; jump back if so to V-RUN/SYN to look in
                                          ; normal variables area.

        CALL    fn_skpovr                 ; routine FN-SKPOVR skips past the ','
                                          ; all syntax has been checked and these
                                          ; things can be taken as read.
        JR      sfa_loop                  ; back to SFA-LOOP while there are more
                                          ; arguments.

; ---

sfa_match:
        BIT     5,C                       ; test if numeric
        JR      NZ,sfa_end                ; to SFA-END if so as will be stacked
                                          ; by scanning

        INC     HL                        ; point to start of string descriptor
        LD      DE,(STKEND)               ; set DE to STKEND
        CALL    move_fp                   ; routine MOVE-FP puts parameters on stack.
        EX      DE,HL                     ; new free location to HL.
        LD      (STKEND),HL               ; use it to set STKEND system variable.

sfa_end:
        POP     DE                        ; discard
        POP     DE                        ; pointers.
        XOR     A                         ; clear carry flag.
        INC     A                         ; and zero flag.
        RET                               ; return.

; ------------------------
; Stack variable component
; ------------------------
; This is called to evaluate a complex structure that has been found, in
; runtime, by LOOK-VARS in the variables area.
; In this case HL points to the initial letter, bits 7-5
; of which indicate the type of variable.
; 010 - simple string, 110 - string array, 100 - array of numbers.
;
; It is called from CLASS-01 when assigning to a string or array including
; a slice.
; It is called from SCANNING to isolate the required part of the structure.
;
; An important part of the runtime process is to check that the number of
; dimensions of the variable match the number of subscripts supplied in the
; BASIC line.
;
; If checking syntax,
; the B register, which counts dimensions is set to zero (256) to allow
; the loop to continue till all subscripts are checked. While doing this it
; is reading dimension sizes from some arbitrary area of memory. Although
; these are meaningless it is of no concern as the limit is never checked by
; int-exp during syntax checking.
;
; The routine is also called from the syntax path of DIM command to check the
; syntax of both string and numeric arrays definitions except that bit 6 of C
; is reset so both are checked as numeric arrays. This ruse avoids a terminal
; slice being accepted as part of the DIM command.
; All that is being checked is that there are a valid set of comma-separated
; expressions before a terminal ')', although, as above, it will still go
; through the motions of checking dummy dimension sizes.

stk_var:
        XOR     A                         ; clear A
        LD      B,A                       ; and B, the syntax dimension counter (256)
        BIT     7,C                       ; checking syntax ?
        JR      NZ,sv_count               ; forward to SV-COUNT if so.

; runtime evaluation.

        BIT     7,(HL)                    ; will be reset if a simple string.
        JR      NZ,sv_arrays              ; forward to SV-ARRAYS otherwise

        INC     A                         ; set A to 1, simple string.

sv_simplestring:
        INC     HL                        ; address length low
        LD      C,(HL)                    ; place in C
        INC     HL                        ; address length high
        LD      B,(HL)                    ; place in B
        INC     HL                        ; address start of string
        EX      DE,HL                     ; DE = start now.
        CALL    stk_sto_string            ; routine STK-STO-$ stacks string parameters
                                          ; DE start in variables area,
                                          ; BC length, A=1 simple string

; the only thing now is to consider if a slice is required.

        RST     18H                       ; GET-CHAR puts character at CH_ADD in A
        JP      sv_slicequestion          ; jump forward to SV-SLICE? to test for '('

; --------------------------------------------------------

; the branch was here with string and numeric arrays in runtime.

sv_arrays:
        INC     HL                        ; step past
        INC     HL                        ; the total length
        INC     HL                        ; to address Number of dimensions.
        LD      B,(HL)                    ; transfer to B overwriting zero.
        BIT     6,C                       ; a numeric array ?
        JR      Z,sv_ptr                  ; forward to SV-PTR with numeric arrays

        DEC     B                         ; ignore the final element of a string array
                                          ; the fixed string size.

        JR      Z,sv_simplestring         ; back to SV-SIMPLE$ if result is zero as has
                                          ; been created with DIM a$(10) for instance
                                          ; and can be treated as a simple string.

; proceed with multi-dimensioned string arrays in runtime.

        EX      DE,HL                     ; save pointer to dimensions in DE

        RST     18H                       ; GET-CHAR looks at the BASIC line
        CP      $28                       ; is character '(' ?
        JR      NZ,report_3               ; to REPORT-3 if not
                                          ; 'Subscript wrong'

        EX      DE,HL                     ; dimensions pointer to HL to synchronize
                                          ; with next instruction.

; runtime numeric arrays path rejoins here.

sv_ptr:
        EX      DE,HL                     ; save dimension pointer in DE
        JR      sv_count                  ; forward to SV-COUNT with true no of dims
                                          ; in B. As there is no initial comma the
                                          ; loop is entered at the midpoint.

; ----------------------------------------------------------
; the dimension counting loop which is entered at mid-point.

sv_comma:
        PUSH    HL                        ; save counter

        RST     18H                       ; GET-CHAR

        POP     HL                        ; pop counter
        CP      $2C                       ; is character ',' ?
        JR      Z,sv_loop                 ; forward to SV-LOOP if so

; in runtime the variable definition indicates a comma should appear here

        BIT     7,C                       ; checking syntax ?
        JR      Z,report_3                ; forward to REPORT-3 if not
                                          ; 'Subscript error'

; proceed if checking syntax of an array?

        BIT     6,C                       ; array of strings
        JR      NZ,sv_close               ; forward to SV-CLOSE if so

; an array of numbers.

        CP      $29                       ; is character ')' ?
        JR      NZ,sv_rpt_c               ; forward to SV-RPT-C if not
                                          ; 'Nonsense in BASIC'

        RST     20H                       ; NEXT-CHAR moves CH-ADD past the statement
        RET                               ; return ->

; ---

; the branch was here with an array of strings.

sv_close:
        CP      $29                       ; as above ')' could follow the expression
        JR      Z,sv_dim                  ; forward to SV-DIM if so

        CP      $CC                       ; is it 'TO' ?
        JR      NZ,sv_rpt_c               ; to SV-RPT-C with anything else
                                          ; 'Nonsense in BASIC'

; now backtrack CH_ADD to set up for slicing routine.
; Note. in a BASIC line we can safely backtrack to a colour parameter.

sv_ch_add:
        RST     18H                       ; GET-CHAR
        DEC     HL                        ; backtrack HL
        LD      (CH_ADD),HL               ; to set CH_ADD up for slicing routine
        JR      sv_slice                  ; forward to SV-SLICE and make a return
                                          ; when all slicing complete.

; ----------------------------------------
; -> the mid-point entry point of the loop

sv_count:
        LD      HL,$0000                  ; initialize data pointer to zero.

sv_loop:
        PUSH    HL                        ; save the data pointer.

        RST     20H                       ; NEXT-CHAR in BASIC area points to an
                                          ; expression.

        POP     HL                        ; restore the data pointer.
        LD      A,C                       ; transfer name/type to A.
        CP      $C0                       ; is it 11000000 ?
                                          ; Note. the letter component is absent if
                                          ; syntax checking.
        JR      NZ,sv_mult                ; forward to SV-MULT if not an array of
                                          ; strings.

; proceed to check string arrays during syntax.

        RST     18H                       ; GET-CHAR
        CP      $29                       ; ')'  end of subscripts ?
        JR      Z,sv_dim                  ; forward to SV-DIM to consider further slice

        CP      $CC                       ; is it 'TO' ?
        JR      Z,sv_ch_add               ; back to SV-CH-ADD to consider a slice.
                                          ; (no need to repeat get-char at sv_ch_add)

; if neither, then an expression is required so rejoin runtime loop ??
; registers HL and DE only point to somewhere meaningful in runtime so
; comments apply to that situation.

sv_mult:
        PUSH    BC                        ; save dimension number.
        PUSH    HL                        ; push data pointer/rubbish.
                                          ; DE points to current dimension.
        CALL    decommade_plus_1          ; routine DE,(DE+1) gets next dimension in DE
                                          ; and HL points to it.
        EX      (SP),HL                   ; dim pointer to stack, data pointer to HL (*)
        EX      DE,HL                     ; data pointer to DE, dim size to HL.

        CALL    int_exp1                  ; routine INT-EXP1 checks integer expression
                                          ; and gets result in BC in runtime.
        JR      C,report_3                ; to REPORT-3 if > HL
                                          ; 'Subscript out of range'

        DEC     BC                        ; adjust returned result from 1-x to 0-x
        CALL    get_hltimesde             ; routine GET-HL*DE multiplies data pointer by
                                          ; dimension size.
        ADD     HL,BC                     ; add the integer returned by expression.
        POP     DE                        ; pop the dimension pointer.                              ***
        POP     BC                        ; pop dimension counter.
        DJNZ    sv_comma                  ; back to SV-COMMA if more dimensions
                                          ; Note. during syntax checking, unless there
                                          ; are more than 256 subscripts, the branch
                                          ; back to SV-COMMA is always taken.

        BIT     7,C                       ; are we checking syntax ?
                                          ; then we've got a joker here.

sv_rpt_c:
        JR      NZ,sl_rpt_c               ; forward to SL-RPT-C if so
                                          ; 'Nonsense in BASIC'
                                          ; more than 256 subscripts in BASIC line.

; but in runtime the number of subscripts are at least the same as dims

        PUSH    HL                        ; save data pointer.
        BIT     6,C                       ; is it a string array ?
        JR      NZ,sv_elemstring          ; forward to SV-ELEM$ if so.

; a runtime numeric array subscript.

        LD      B,D                       ; register DE has advanced past all dimensions
        LD      C,E                       ; and points to start of data in variable.
                                          ; transfer it to BC.

        RST     18H                       ; GET-CHAR checks BASIC line
        CP      $29                       ; must be a ')' ?
        JR      Z,sv_number               ; skip to SV-NUMBER if so

; else more subscripts in BASIC line than the variable definition.

report_3:
        RST     08H                       ; ERROR-1
        DEFB    $02                       ; Error Report: Subscript wrong

; continue if subscripts matched the numeric array.

sv_number:
        RST     20H                       ; NEXT-CHAR moves CH_ADD to next statement
                                          ; - finished parsing.

        POP     HL                        ; pop the data pointer.
        LD      DE,$0005                  ; each numeric element is 5 bytes.
        CALL    get_hltimesde             ; routine GET-HL*DE multiplies.
        ADD     HL,BC                     ; now add to start of data in the variable.

        RET                               ; return with HL pointing at the numeric
                                          ; array subscript.                       ->

; ---------------------------------------------------------------

; the branch was here for string subscripts when the number of subscripts
; in the BASIC line was one less than in variable definition.

sv_elemstring:
        CALL    decommade_plus_1          ; routine DE,(DE+1) gets final dimension
                                          ; the length of strings in this array.
        EX      (SP),HL                   ; start pointer to stack, data pointer to HL.
        CALL    get_hltimesde             ; routine GET-HL*DE multiplies by element
                                          ; size.
        POP     BC                        ; the start of data pointer is added
        ADD     HL,BC                     ; in - now points to location before.
        INC     HL                        ; point to start of required string.
        LD      B,D                       ; transfer the length (final dimension size)
        LD      C,E                       ; from DE to BC.
        EX      DE,HL                     ; put start in DE.
        CALL    stk_st_0                  ; routine STK-ST-0 stores the string parameters
                                          ; with A=0 - a slice or subscript.

; now check that there were no more subscripts in the BASIC line.

        RST     18H                       ; GET-CHAR
        CP      $29                       ; is it ')' ?
        JR      Z,sv_dim                  ; forward to SV-DIM to consider a separate
                                          ; subscript or/and a slice.

        CP      $2C                       ; a comma is allowed if the final subscript
                                          ; is to be sliced e.g a$(2,3,4 TO 6).
        JR      NZ,report_3               ; to REPORT-3 with anything else
                                          ; 'Subscript error'

sv_slice:
        CALL    slicing                   ; routine SLICING slices the string.

; but a slice of a simple string can itself be sliced.

sv_dim:
        RST     20H                       ; NEXT-CHAR

sv_slicequestion:
        CP      $28                       ; is character '(' ?
        JR      Z,sv_slice                ; loop back if so to SV-SLICE

        RES     6,(IY+(FLAGS-C_IY))       ; update FLAGS  - Signal string result
        RET                               ; and return.

; ---

; The above section deals with the flexible syntax allowed.
; DIM a$(3,3,10) can be considered as two dimensional array of ten-character
; strings or a 3-dimensional array of characters.
; a$(1,1) will return a 10-character string as will a$(1,1,1 TO 10)
; a$(1,1,1) will return a single character.
; a$(1,1) (1 TO 6) is the same as a$(1,1,1 TO 6)
; A slice can itself be sliced ad infinitum
; b$ () () () () () () (2 TO 10) (2 TO 9) (3) is the same as b$(5)



; -------------------------
; Handle slicing of strings
; -------------------------
; The syntax of string slicing is very natural and it is as well to reflect
; on the permutations possible.
; a$() and a$( TO ) indicate the entire string although just a$ would do
; and would avoid coming here.
; h$(16) indicates the single character at position 16.
; a$( TO 32) indicates the first 32 characters.
; a$(257 TO) indicates all except the first 256 characters.
; a$(19000 TO 19999) indicates the thousand characters at position 19000.
; Also a$(9 TO 5) returns a null string not an error.
; This enables a$(2 TO) to return a null string if the passed string is
; of length zero or 1.
; A string expression in brackets can be sliced. e.g. (STR$ PI) (3 TO )
; We arrived here from SCANNING with CH-ADD pointing to the initial '('
; or from above.

slicing:
        CALL    syntax_z                  ; routine SYNTAX-Z
        CALL    NZ,stk_fetch              ; routine STK-FETCH fetches parameters of
                                          ; string at runtime, start in DE, length
                                          ; in BC. This could be an array subscript.

        RST     20H                       ; NEXT-CHAR
        CP      $29                       ; is it ')' ?     e.g. a$()
        JR      Z,sl_store                ; forward to SL-STORE to store entire string.

        PUSH    DE                        ; else save start address of string

        XOR     A                         ; clear accumulator to use as a running flag.
        PUSH    AF                        ; and save on stack before any branching.

        PUSH    BC                        ; save length of string to be sliced.
        LD      DE,$0001                  ; default the start point to position 1.

        RST     18H                       ; GET-CHAR

        POP     HL                        ; pop length to HL as default end point
                                          ; and limit.

        CP      $CC                       ; is it 'TO' ?    e.g. a$( TO 10000)
        JR      Z,sl_second               ; to SL-SECOND to evaluate second parameter.

        POP     AF                        ; pop the running flag.

        CALL    int_exp2                  ; routine INT-EXP2 fetches first parameter.

        PUSH    AF                        ; save flag (will be $FF if parameter>limit)

        LD      D,B                       ; transfer the start
        LD      E,C                       ; to DE overwriting 0001.
        PUSH    HL                        ; save original length.

        RST     18H                       ; GET-CHAR
        POP     HL                        ; pop the limit length.
        CP      $CC                       ; is it 'TO' after a start ?
        JR      Z,sl_second               ; to SL-SECOND to evaluate second parameter

        CP      $29                       ; is it ')' ?       e.g. a$(365)

sl_rpt_c:
        JP      NZ,report_c               ; jump to REPORT-C with anything else
                                          ; 'Nonsense in BASIC'

        LD      H,D                       ; copy start
        LD      L,E                       ; to end - just a one character slice.
        JR      sl_define                 ; forward to SL-DEFINE.

; ---------------------

sl_second:
        PUSH    HL                        ; save limit length.

        RST     20H                       ; NEXT-CHAR

        POP     HL                        ; pop the length.

        CP      $29                       ; is character ')' ?        e.g a$(7 TO )
        JR      Z,sl_define               ; to SL-DEFINE using length as end point.

        POP     AF                        ; else restore flag.
        CALL    int_exp2                  ; routine INT-EXP2 gets second expression.

        PUSH    AF                        ; save the running flag.

        RST     18H                       ; GET-CHAR

        LD      H,B                       ; transfer second parameter
        LD      L,C                       ; to HL.              e.g. a$(42 to 99)
        CP      $29                       ; is character a ')' ?
        JR      NZ,sl_rpt_c               ; to SL-RPT-C if not
                                          ; 'Nonsense in BASIC'

; we now have start in DE and an end in HL.

sl_define:
        POP     AF                        ; pop the running flag.
        EX      (SP),HL                   ; put end point on stack, start address to HL
        ADD     HL,DE                     ; add address of string to the start point.
        DEC     HL                        ; point to first character of slice.
        EX      (SP),HL                   ; start address to stack, end point to HL (*)
        AND     A                         ; prepare to subtract.
        SBC     HL,DE                     ; subtract start point from end point.
        LD      BC,$0000                  ; default the length result to zero.
        JR      C,sl_over                 ; forward to SL-OVER if start > end.

        INC     HL                        ; increment the length for inclusive byte.

        AND     A                         ; now test the running flag.
        JP      M,report_3                ; jump back to REPORT-3 if $FF.
                                          ; 'Subscript out of range'

        LD      B,H                       ; transfer the length
        LD      C,L                       ; to BC.

sl_over:
        POP     DE                        ; restore start address from machine stack ***
        RES     6,(IY+(FLAGS-C_IY))       ; update FLAGS - signal string result for
                                          ; syntax.

sl_store:
        CALL    syntax_z                  ; routine SYNTAX-Z  (UNSTACK-Z?)
        RET     Z                         ; return if checking syntax.
                                          ; but continue to store the string in runtime.

; ------------------------------------
; other than from above, this routine is called from STK-VAR to stack
; a known string array element.
; ------------------------------------

stk_st_0:
        XOR     A                         ; clear to signal a sliced string or element.

; -------------------------
; this routine is called from chr$, scrn$ etc. to store a simple string result.
; --------------------------

stk_sto_string:
        RES     6,(IY+(FLAGS-C_IY))       ; update FLAGS - signal string result.
                                          ; and continue to store parameters of string.

; ---------------------------------------
; Pass five registers to calculator stack
; ---------------------------------------
; This subroutine puts five registers on the calculator stack.

stk_store:
        PUSH    BC                        ; save two registers
        CALL    test_5_sp                 ; routine TEST-5-SP checks room and puts 5
                                          ; in BC.
        POP     BC                        ; fetch the saved registers.
        LD      HL,(STKEND)               ; make HL point to first empty location STKEND
        LD      (HL),A                    ; place the 5 registers.
        INC     HL                        ;
        LD      (HL),E                    ;
        INC     HL                        ;
        LD      (HL),D                    ;
        INC     HL                        ;
        LD      (HL),C                    ;
        INC     HL                        ;
        LD      (HL),B                    ;
        INC     HL                        ;
        LD      (STKEND),HL               ; update system variable STKEND.
        RET                               ; and return.

; -------------------------------------------
; Return result of evaluating next expression
; -------------------------------------------
; This clever routine is used to check and evaluate an integer expression
; which is returned in BC, setting A to $FF, if greater than a limit supplied
; in HL. It is used to check array subscripts, parameters of a string slice
; and the arguments of the DIM command. In the latter case, the limit check
; is not required and H is set to $FF. When checking optional string slice
; parameters, it is entered at the second entry point so as not to disturb
; the running flag A, which may be $00 or $FF from a previous invocation.

int_exp1:
        XOR     A                         ; set result flag to zero.

; -> The entry point is here if A is used as a running flag.

int_exp2:
        PUSH    DE                        ; preserve DE register throughout.
        PUSH    HL                        ; save the supplied limit.
        PUSH    AF                        ; save the flag.

        CALL    expt_1num                 ; routine EXPT-1NUM evaluates expression
                                          ; at CH_ADD returning if numeric result,
                                          ; with value on calculator stack.

        POP     AF                        ; pop the flag.
        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      Z,i_restore               ; forward to I-RESTORE if checking syntax so
                                          ; avoiding a comparison with supplied limit.

        PUSH    AF                        ; save the flag.

        CALL    find_int2                 ; routine FIND-INT2 fetches value from
                                          ; calculator stack to BC producing an error
                                          ; if too high.

        POP     DE                        ; pop the flag to D.
        LD      A,B                       ; test value for zero and reject
        OR      C                         ; as arrays and strings begin at 1.
        SCF                               ; set carry flag.
        JR      Z,i_carry                 ; forward to I-CARRY if zero.

        POP     HL                        ; restore the limit.
        PUSH    HL                        ; and save.
        AND     A                         ; prepare to subtract.
        SBC     HL,BC                     ; subtract value from limit.

i_carry:
        LD      A,D                       ; move flag to accumulator $00 or $FF.
        SBC     A,$00                     ; will set to $FF if carry set.

i_restore:
        POP     HL                        ; restore the limit.
        POP     DE                        ; and DE register.
        RET                               ; return.


; -----------------------
; LD DE,(DE+1) Subroutine
; -----------------------
; This routine just loads the DE register with the contents of the two
; locations following the location addressed by DE.
; It is used to step along the 16-bit dimension sizes in array definitions.
; Note. Such code is made into subroutines to make programs easier to
; write and it would use less space to include the five instructions in-line.
; However, there are so many exchanges going on at the places this is invoked
; that to implement it in-line would make the code hard to follow.
; It probably had a zippier label though as the intention is to simplify the
; program.

decommade_plus_1:
        EX      DE,HL                     ;
        INC     HL                        ;
        LD      E,(HL)                    ;
        INC     HL                        ;
        LD      D,(HL)                    ;
        RET                               ;

; -------------------
; HL=HL*DE Subroutine
; -------------------
; This routine calls the mathematical routine to multiply HL by DE in runtime.
; It is called from STK-VAR and from DIM. In the latter case syntax is not
; being checked so the entry point could have been at the second CALL
; instruction to save a few clock-cycles.

get_hltimesde:
        CALL    syntax_z                  ; routine SYNTAX-Z.
        RET     Z                         ; return if checking syntax.

        CALL    hl_mult_de                ; routine HL-HL*DE.
        JP      C,report_4                ; jump back to REPORT-4 if over 65535.

        RET                               ; else return with 16-bit result in HL.

; -----------------
; THE 'LET' COMMAND
; -----------------
; Sinclair BASIC adheres to the ANSI-78 standard and a LET is required in
; assignments e.g. LET a = 1  :   LET h$ = "hat".
;
; Long names may contain spaces but not colour controls (when assigned).
; a substring can appear to the left of the equals sign.

; An earlier mathematician Lewis Carroll may have been pleased that
; 10 LET Babies cannot manage crocodiles = Babies are illogical AND
;    Nobody is despised who can manage a crocodile AND Illogical persons
;    are despised
; does not give the 'Nonsense..' error if the three variables exist.
; I digress.

let:
        LD      HL,(DEST)                 ; fetch system variable DEST to HL.
        BIT     1,(IY+(FLAGX-C_IY))       ; test FLAGX - handling a new variable ?
        JR      Z,l_exists                ; forward to L-EXISTS if not.

; continue for a new variable. DEST points to start in BASIC line.
; from the CLASS routines.

        LD      BC,$0005                  ; assume numeric and assign an initial 5 bytes

l_each_ch:
        INC     BC                        ; increase byte count for each relevant
                                          ; character

l_no_sp:
        INC     HL                        ; increase pointer.
        LD      A,(HL)                    ; fetch character.
        CP      $20                       ; is it a space ?
        JR      Z,l_no_sp                 ; back to L-NO-SP is so.

        JR      NC,l_test_ch              ; forward to L-TEST-CH if higher.

        CP      $10                       ; is it $00 - $0F ?
        JR      C,l_spaces                ; forward to L-SPACES if so.

        CP      $16                       ; is it $16 - $1F ?
        JR      NC,l_spaces               ; forward to L-SPACES if so.

; it was $10 - $15  so step over a colour code.

        INC     HL                        ; increase pointer.
        JR      l_no_sp                   ; loop back to L-NO-SP.

; ---

; the branch was to here if higher than space.

l_test_ch:
        CALL    alphanum                  ; routine ALPHANUM sets carry if alphanumeric
        JR      C,l_each_ch               ; loop back to L-EACH-CH for more if so.

        CP      $24                       ; is it '$' ?
        JP      Z,l_newstring             ; jump forward if so, to L-NEW$
                                          ; with a new string.

l_spaces:
        LD      A,C                       ; save length lo in A.
        LD      HL,(E_LINE)               ; fetch E_LINE to HL.
        DEC     HL                        ; point to location before, the variables
                                          ; end-marker.
        CALL    make_room                 ; routine MAKE-ROOM creates BC spaces
                                          ; for name and numeric value.
        INC     HL                        ; advance to first new location.
        INC     HL                        ; then to second.
        EX      DE,HL                     ; set DE to second location.
        PUSH    DE                        ; save this pointer.
        LD      HL,(DEST)                 ; reload HL with DEST.
        DEC     DE                        ; point to first.
        SUB     $06                       ; subtract six from length_lo.
        LD      B,A                       ; save count in B.
        JR      Z,l_single                ; forward to L-SINGLE if it was just
                                          ; one character.

; HL points to start of variable name after 'LET' in BASIC line.

l_char:
        INC     HL                        ; increase pointer.
        LD      A,(HL)                    ; pick up character.
        CP      $21                       ; is it space or higher ?
        JR      C,l_char                  ; back to L-CHAR with space and less.

        OR      $20                       ; make variable lower-case.
        INC     DE                        ; increase destination pointer.
        LD      (DE),A                    ; and load to edit line.
        DJNZ    l_char                    ; loop back to L-CHAR until B is zero.

        OR      $80                       ; invert the last character.
        LD      (DE),A                    ; and overwrite that in edit line.

; now consider first character which has bit 6 set

        LD      A,$C0                     ; set A 11000000 is xor mask for a long name.
                                          ; %101      is xor/or  result

; single character numerics rejoin here with %00000000 in mask.
;                                            %011      will be xor/or result

l_single:
        LD      HL,(DEST)                 ; fetch DEST - HL addresses first character.
        XOR     (HL)                      ; apply variable type indicator mask (above).
        OR      $20                       ; make lowercase - set bit 5.
        POP     HL                        ; restore pointer to 2nd character.
        CALL    l_first                   ; routine L-FIRST puts A in first character.
                                          ; and returns with HL holding
                                          ; new E_LINE-1  the $80 vars end-marker.

l_numeric:
        PUSH    HL                        ; save the pointer.

; the value of variable is deleted but remains after calculator stack.

        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete      ; delete variable value
        DEFB    $38                       ;;end-calc

; DE (STKEND) points to start of value.

        POP     HL                        ; restore the pointer.
        LD      BC,$0005                  ; start of number is five bytes before.
        AND     A                         ; prepare for true subtraction.
        SBC     HL,BC                     ; HL points to start of value.
        JR      l_enter                   ; forward to L-ENTER  ==>

; ---


; the jump was to here if the variable already existed.

l_exists:
        BIT     6,(IY+(FLAGS-C_IY))       ; test FLAGS - numeric or string result ?
        JR      Z,l_deletestring          ; skip forward to L-DELETE$   -*->
                                          ; if string result.

; A numeric variable could be simple or an array element.
; They are treated the same and the old value is overwritten.

        LD      DE,$0006                  ; six bytes forward points to loc past value.
        ADD     HL,DE                     ; add to start of number.
        JR      l_numeric                 ; back to L-NUMERIC to overwrite value.

; ---

; -*-> the branch was here if a string existed.

l_deletestring:
        LD      HL,(DEST)                 ; fetch DEST to HL.
                                          ; (still set from first instruction)
        LD      BC,(STRLEN)               ; fetch STRLEN to BC.
        BIT     0,(IY+(FLAGX-C_IY))       ; test FLAGX - handling a complete simple
                                          ; string ?
        JR      NZ,l_addstring            ; forward to L-ADD$ if so.

; must be a string array or a slice in workspace.
; Note. LET a$(3 TO 6) = h$   will assign "hat " if h$ = "hat"
;                                  and    "hats" if h$ = "hatstand".
;
; This is known as Procrustian lengthening and shortening after a
; character Procrustes in Greek legend who made travellers sleep in his bed,
; cutting off their feet or stretching them so they fitted the bed perfectly.
; The bloke was hatstand and slain by Theseus.

        LD      A,B                       ; test if length
        OR      C                         ; is zero and
        RET     Z                         ; return if so.

        PUSH    HL                        ; save pointer to start.

        RST     30H                       ; BC-SPACES creates room.
        PUSH    DE                        ; save pointer to first new location.
        PUSH    BC                        ; and length            (*)
        LD      D,H                       ; set DE to point to last location.
        LD      E,L                       ;
        INC     HL                        ; set HL to next location.
        LD      (HL),$20                  ; place a space there.
        LDDR                              ; copy bytes filling with spaces.

        PUSH    HL                        ; save pointer to start.
        CALL    stk_fetch                 ; routine STK-FETCH start to DE,
                                          ; length to BC.
        POP     HL                        ; restore the pointer.
        EX      (SP),HL                   ; (*) length to HL, pointer to stack.
        AND     A                         ; prepare for true subtraction.
        SBC     HL,BC                     ; subtract old length from new.
        ADD     HL,BC                     ; and add back.
        JR      NC,l_length               ; forward if it fits to L-LENGTH.

        LD      B,H                       ; otherwise set
        LD      C,L                       ; length to old length.
                                          ; "hatstand" becomes "hats"

l_length:
        EX      (SP),HL                   ; (*) length to stack, pointer to HL.
        EX      DE,HL                     ; pointer to DE, start of string to HL.
        LD      A,B                       ; is the length zero ?
        OR      C                         ;
        JR      Z,l_in_wslashs            ; forward to L-IN-W/S if so
                                          ; leaving prepared spaces.

        LDIR                              ; else copy bytes overwriting some spaces.

l_in_wslashs:
        POP     BC                        ; pop the new length.  (*)
        POP     DE                        ; pop pointer to new area.
        POP     HL                        ; pop pointer to variable in assignment.
                                          ; and continue copying from workspace
                                          ; to variables area.

; ==> branch here from  L-NUMERIC

l_enter:
        EX      DE,HL                     ; exchange pointers HL=STKEND DE=end of vars.
        LD      A,B                       ; test the length
        OR      C                         ; and make a
        RET     Z                         ; return if zero (strings only).

        PUSH    DE                        ; save start of destination.
        LDIR                              ; copy bytes.
        POP     HL                        ; address the start.
        RET                               ; and return.

; ---

; the branch was here from L-DELETE$ if an existing simple string.
; register HL addresses start of string in variables area.

l_addstring:
        DEC     HL                        ; point to high byte of length.
        DEC     HL                        ; to low byte.
        DEC     HL                        ; to letter.
        LD      A,(HL)                    ; fetch masked letter to A.
        PUSH    HL                        ; save the pointer on stack.
        PUSH    BC                        ; save new length.
        CALL    l_string                  ; routine L-STRING adds new string at end
                                          ; of variables area.
                                          ; if no room we still have old one.
        POP     BC                        ; restore length.
        POP     HL                        ; restore start.
        INC     BC                        ; increase
        INC     BC                        ; length by three
        INC     BC                        ; to include character and length bytes.
        JP      reclaim_2                 ; jump to indirect exit via RECLAIM-2
                                          ; deleting old version and adjusting pointers.

; ---

; the jump was here with a new string variable.

l_newstring:
        LD      A,$DF                     ; indicator mask %11011111 for
                                          ;                %010xxxxx will be result
        LD      HL,(DEST)                 ; address DEST first character.
        AND     (HL)                      ; combine mask with character.

l_string:
        PUSH    AF                        ; save first character and mask.
        CALL    stk_fetch                 ; routine STK-FETCH fetches parameters of
                                          ; the string.
        EX      DE,HL                     ; transfer start to HL.
        ADD     HL,BC                     ; add to length.
        PUSH    BC                        ; save the length.
        DEC     HL                        ; point to end of string.
        LD      (DEST),HL                 ; save pointer in DEST.
                                          ; (updated by POINTERS if in workspace)
        INC     BC                        ; extra byte for letter.
        INC     BC                        ; two bytes
        INC     BC                        ; for the length of string.
        LD      HL,(E_LINE)               ; address E_LINE.
        DEC     HL                        ; now end of VARS area.
        CALL    make_room                 ; routine MAKE-ROOM makes room for string.
                                          ; updating pointers including DEST.
        LD      HL,(DEST)                 ; pick up pointer to end of string from DEST.
        POP     BC                        ; restore length from stack.
        PUSH    BC                        ; and save again on stack.
        INC     BC                        ; add a byte.
        LDDR                              ; copy bytes from end to start.
        EX      DE,HL                     ; HL addresses length low
        INC     HL                        ; increase to address high byte
        POP     BC                        ; restore length to BC
        LD      (HL),B                    ; insert high byte
        DEC     HL                        ; address low byte location
        LD      (HL),C                    ; insert that byte
        POP     AF                        ; restore character and mask

l_first:
        DEC     HL                        ; address variable name
        LD      (HL),A                    ; and insert character.
        LD      HL,(E_LINE)               ; load HL with E_LINE.
        DEC     HL                        ; now end of VARS area.
        RET                               ; return

; ------------------------------------
; Get last value from calculator stack
; ------------------------------------
;
;

stk_fetch:
        LD      HL,(STKEND)               ; STKEND
        DEC     HL                        ;
        LD      B,(HL)                    ;
        DEC     HL                        ;
        LD      C,(HL)                    ;
        DEC     HL                        ;
        LD      D,(HL)                    ;
        DEC     HL                        ;
        LD      E,(HL)                    ;
        DEC     HL                        ;
        LD      A,(HL)                    ;
        LD      (STKEND),HL               ; STKEND
        RET                               ;

; ------------------
; Handle DIM command
; ------------------
; e.g. DIM a(2,3,4,7): DIM a$(32) : DIM b$(300,2,768) : DIM c$(20000)
; the only limit to dimensions is memory so, for example,
; DIM a(2,2,2,2,2,2,2,2,2,2,2,2,2) is possible and creates a multi-
; dimensional array of zeros. String arrays are initialized to spaces.
; It is not possible to erase an array, but it can be re-dimensioned to
; a minimal size of 1, after use, to free up memory.

dim:
        CALL    look_vars                 ; routine LOOK-VARS

d_rport_c:
        JP      NZ,report_c               ; jump to REPORT-C if a long-name variable.
                                          ; DIM lottery numbers(49) doesn't work.

        CALL    syntax_z                  ; routine SYNTAX-Z
        JR      NZ,d_run                  ; forward to D-RUN in runtime.

        RES     6,C                       ; signal 'numeric' array even if string as
                                          ; this simplifies the syntax checking.

        CALL    stk_var                   ; routine STK-VAR checks syntax.
        CALL    check_end                 ; routine CHECK-END performs early exit ->

; the branch was here in runtime.

d_run:
        JR      C,d_letter                ; skip to D-LETTER if variable did not exist.
                                          ; else reclaim the old one.

        PUSH    BC                        ; save type in C.
        CALL    next_one                  ; routine NEXT-ONE find following variable
                                          ; or position of $80 end-marker.
        CALL    reclaim_2                 ; routine RECLAIM-2 reclaims the
                                          ; space between.
        POP     BC                        ; pop the type.

d_letter:
        SET     7,C                       ; signal array.
        LD      B,$00                     ; initialize dimensions to zero and
        PUSH    BC                        ; save with the type.
        LD      HL,$0001                  ; make elements one character presuming string
        BIT     6,C                       ; is it a string ?
        JR      NZ,d_size                 ; forward to D-SIZE if so.

        LD      L,$05                     ; make elements 5 bytes as is numeric.

d_size:
        EX      DE,HL                     ; save the element size in DE.

; now enter a loop to parse each of the integers in the list.

d_no_loop:
        RST     20H                       ; NEXT-CHAR
        LD      H,$FF                     ; disable limit check by setting HL high
        CALL    int_exp1                  ; routine INT-EXP1
        JP      C,report_3                ; to REPORT-3 if > 65280 and then some
                                          ; 'Subscript out of range'

        POP     HL                        ; pop dimension counter, array type
        PUSH    BC                        ; save dimension size                     ***
        INC     H                         ; increment the dimension counter
        PUSH    HL                        ; save the dimension counter
        LD      H,B                       ; transfer size
        LD      L,C                       ; to HL
        CALL    get_hltimesde             ; routine GET-HL*DE multiplies dimension by
                                          ; running total of size required initially
                                          ; 1 or 5.
        EX      DE,HL                     ; save running total in DE

        RST     18H                       ; GET-CHAR
        CP      $2C                       ; is it ',' ?
        JR      Z,d_no_loop               ; loop back to D-NO-LOOP until all dimensions
                                          ; have been considered

; when loop complete continue.

        CP      $29                       ; is it ')' ?
        JR      NZ,d_rport_c              ; to D-RPORT-C with anything else
                                          ; 'Nonsense in BASIC'


        RST     20H                       ; NEXT-CHAR advances to next statement/CR

        POP     BC                        ; pop dimension counter/type
        LD      A,C                       ; type to A

; now calculate space required for array variable

        LD      L,B                       ; dimensions to L since these require 16 bits
                                          ; then this value will be doubled
        LD      H,$00                     ; set high byte to zero

; another four bytes are required for letter(1), total length(2), number of
; dimensions(1) but since we have yet to double allow for two

        INC     HL                        ; increment
        INC     HL                        ; increment

        ADD     HL,HL                     ; now double giving 4 + dimensions * 2

        ADD     HL,DE                     ; add to space required for array contents

        JP      C,report_4                ; to REPORT-4 if > 65535
                                          ; 'Out of memory'

        PUSH    DE                        ; save data space
        PUSH    BC                        ; save dimensions/type
        PUSH    HL                        ; save total space
        LD      B,H                       ; total space
        LD      C,L                       ; to BC
        LD      HL,(E_LINE)               ; address E_LINE - first location after
                                          ; variables area
        DEC     HL                        ; point to location before - the $80 end-marker
        CALL    make_room                 ; routine MAKE-ROOM creates the space if
                                          ; memory is available.

        INC     HL                        ; point to first new location and
        LD      (HL),A                    ; store letter/type

        POP     BC                        ; pop total space
        DEC     BC                        ; exclude name
        DEC     BC                        ; exclude the 16-bit
        DEC     BC                        ; counter itself
        INC     HL                        ; point to next location the 16-bit counter
        LD      (HL),C                    ; insert low byte
        INC     HL                        ; address next
        LD      (HL),B                    ; insert high byte

        POP     BC                        ; pop the number of dimensions.
        LD      A,B                       ; dimensions to A
        INC     HL                        ; address next
        LD      (HL),A                    ; and insert "No. of dims"

        LD      H,D                       ; transfer DE space + 1 from make-room
        LD      L,E                       ; to HL
        DEC     DE                        ; set DE to next location down.
        LD      (HL),$00                  ; presume numeric and insert a zero
        BIT     6,C                       ; test bit 6 of C. numeric or string ?
        JR      Z,dim_clear               ; skip to DIM-CLEAR if numeric

        LD      (HL),$20                  ; place a space character in HL

dim_clear:
        POP     BC                        ; pop the data length

        LDDR                              ; LDDR sets to zeros or spaces

; The number of dimensions is still in A.
; A loop is now entered to insert the size of each dimension that was pushed
; during the D-NO-LOOP working downwards from position before start of data.

dim_sizes:
        POP     BC                        ; pop a dimension size                    ***
        LD      (HL),B                    ; insert high byte at position
        DEC     HL                        ; next location down
        LD      (HL),C                    ; insert low byte
        DEC     HL                        ; next location down
        DEC     A                         ; decrement dimension counter
        JR      NZ,dim_sizes              ; back to DIM-SIZES until all done.

        RET                               ; return.

; -----------------------------
; Check whether digit or letter
; -----------------------------
; This routine checks that the character in A is alphanumeric
; returning with carry set if so.

alphanum:
        CALL    numeric                   ; routine NUMERIC will reset carry if so.
        CCF                               ; Complement Carry Flag
        RET     C                         ; Return if numeric else continue into
                                          ; next routine.

; This routine checks that the character in A is alphabetic

alpha:
        CP      $41                       ; less than 'A' ?
        CCF                               ; Complement Carry Flag
        RET     NC                        ; return if so

        CP      $5B                       ; less than 'Z'+1 ?
        RET     C                         ; is within first range

        CP      $61                       ; less than 'a' ?
        CCF                               ; Complement Carry Flag
        RET     NC                        ; return if so.

        CP      $7B                       ; less than 'z'+1 ?
        RET                               ; carry set if within a-z.

; -------------------------
; Decimal to floating point
; -------------------------
; This routine finds the floating point number represented by an expression
; beginning with BIN, '.' or a digit.
; Note that BIN need not have any '0's or '1's after it.
; BIN is really just a notational symbol and not a function.

dec_to_fp:
        CP      $C4                       ; 'BIN' token ?
        JR      NZ,not_bin                ; to NOT-BIN if not

        LD      DE,$0000                  ; initialize 16 bit buffer register.

bin_digit:
        RST     20H                       ; NEXT-CHAR
        SUB     $31                       ; '1'
        ADC     A,$00                     ; will be zero if '1' or '0'
                                          ; carry will be set if was '0'
        JR      NZ,bin_end                ; forward to BIN-END if result not zero

        EX      DE,HL                     ; buffer to HL
        CCF                               ; Carry now set if originally '1'
        ADC     HL,HL                     ; shift the carry into HL
        JP      C,report_6                ; to REPORT-6 if overflow - too many digits
                                          ; after first '1'. There can be an unlimited
                                          ; number of leading zeros.
                                          ; 'Number too big' - raise an error

        EX      DE,HL                     ; save the buffer
        JR      bin_digit                 ; back to BIN-DIGIT for more digits

; ---

bin_end:
        LD      B,D                       ; transfer 16 bit buffer
        LD      C,E                       ; to BC register pair.
        JP      stack_bc                  ; JUMP to STACK-BC to put on calculator stack

; ---

; continue here with .1,  42, 3.14, 5., 2.3 E -4

not_bin:
        CP      $2E                       ; '.' - leading decimal point ?
        JR      Z,decimal                 ; skip to DECIMAL if so.

        CALL    int_to_fp                 ; routine INT-TO-FP to evaluate all digits
                                          ; This number 'x' is placed on stack.
        CP      $2E                       ; '.' - mid decimal point ?

        JR      NZ,e_format               ; to E-FORMAT if not to consider that format

        RST     20H                       ; NEXT-CHAR
        CALL    numeric                   ; routine NUMERIC returns carry reset if 0-9

        JR      C,e_format                ; to E-FORMAT if not a digit e.g. '1.'

        JR      dec_sto_1                 ; to DEC-STO-1 to add the decimal part to 'x'

; ---

; a leading decimal point has been found in a number.

decimal:
        RST     20H                       ; NEXT-CHAR
        CALL    numeric                   ; routine NUMERIC will reset carry if digit

dec_rpt_c:
        JP      C,report_c                ; to REPORT-C if just a '.'
                                          ; raise 'Nonsense in BASIC'

; since there is no leading zero put one on the calculator stack.

        RST     28H                       ;; FP-CALC
        DEFB    $A0                       ;;stk-zero  ; 0.
        DEFB    $38                       ;;end-calc

; If rejoining from earlier there will be a value 'x' on stack.
; If continuing from above the value zero.
; Now store 1 in mem-0.
; Note. At each pass of the digit loop this will be divided by ten.

dec_sto_1:
        RST     28H                       ;; FP-CALC
        DEFB    $A1                       ;;stk-one   ;x or 0,1.
        DEFB    $C0                       ;;st-mem-0  ;x or 0,1.
        DEFB    $02                       ;;delete    ;x or 0.
        DEFB    $38                       ;;end-calc


nxt_dgt_1:
        RST     18H                       ; GET-CHAR
        CALL    stk_digit                 ; routine STK-DIGIT stacks single digit 'd'
        JR      C,e_format                ; exit to E-FORMAT when digits exhausted  >


        RST     28H                       ;; FP-CALC   ;x or 0,d.           first pass.
        DEFB    $E0                       ;;get-mem-0  ;x or 0,d,1.
        DEFB    $A4                       ;;stk-ten    ;x or 0,d,1,10.
        DEFB    $05                       ;;division   ;x or 0,d,1/10.
        DEFB    $C0                       ;;st-mem-0   ;x or 0,d,1/10.
        DEFB    $04                       ;;multiply   ;x or 0,d/10.
        DEFB    $0F                       ;;addition   ;x or 0 + d/10.
        DEFB    $38                       ;;end-calc   last value.

        RST     20H                       ; NEXT-CHAR  moves to next character
        JR      nxt_dgt_1                 ; back to NXT-DGT-1

; ---

; although only the first pass is shown it can be seen that at each pass
; the new less significant digit is multiplied by an increasingly smaller
; factor (1/100, 1/1000, 1/10000 ... ) before being added to the previous
; last value to form a new last value.

; Finally see if an exponent has been input.

e_format:
        CP      $45                       ; is character 'E' ?
        JR      Z,sign_flag               ; to SIGN-FLAG if so

        CP      $65                       ; 'e' is acceptable as well.
        RET     NZ                        ; return as no exponent.

sign_flag:
        LD      B,$FF                     ; initialize temporary sign byte to $FF

        RST     20H                       ; NEXT-CHAR
        CP      $2B                       ; is character '+' ?
        JR      Z,sign_done               ; to SIGN-DONE

        CP      $2D                       ; is character '-' ?
        JR      NZ,st_e_part              ; to ST-E-PART as no sign

        INC     B                         ; set sign to zero

; now consider digits of exponent.
; Note. incidentally this is the only occasion in Spectrum BASIC when an
; expression may not be used when a number is expected.

sign_done:
        RST     20H                       ; NEXT-CHAR

st_e_part:
        CALL    numeric                   ; routine NUMERIC
        JR      C,dec_rpt_c               ; to DEC-RPT-C if not
                                          ; raise 'Nonsense in BASIC'.

        PUSH    BC                        ; save sign (in B)
        CALL    int_to_fp                 ; routine INT-TO-FP places exponent on stack
        CALL    fp_to_a                   ; routine FP-TO-A  transfers it to A
        POP     BC                        ; restore sign
        JP      C,report_6                ; to REPORT-6 if overflow (over 255)
                                          ; raise 'Number too big'.

        AND     A                         ; set flags
        JP      M,report_6                ; to REPORT-6 if over '127'.
                                          ; raise 'Number too big'.
                                          ; 127 is still way too high and it is
                                          ; impossible to enter an exponent greater
                                          ; than 39 from the keyboard. The error gets
                                          ; raised later in E-TO-FP so two different
                                          ; error messages depending how high A is.

        INC     B                         ; $FF to $00 or $00 to $01 - expendable now.
        JR      Z,e_fp_jump               ; forward to E-FP-JUMP if exponent positive

        NEG                               ; Negate the exponent.

e_fp_jump:
        JP      e_to_fp                   ; JUMP forward to E-TO-FP to assign to
                                          ; last value x on stack x * 10 to power A
                                          ; a relative jump would have done.

; ---------------------
; Check for valid digit
; ---------------------
; This routine checks that the ASCII character in A is numeric
; returning with carry reset if so.

numeric:
        CP      $30                       ; '0'
        RET     C                         ; return if less than zero character.

        CP      $3A                       ; The upper test is '9'
        CCF                               ; Complement Carry Flag
        RET                               ; Return - carry clear if character '0' - '9'

; -----------
; Stack Digit
; -----------
; This subroutine is called from INT-TO-FP and DEC-TO-FP to stack a digit
; on the calculator stack.

stk_digit:
        CALL    numeric                   ; routine NUMERIC
        RET     C                         ; return if not numeric character

        SUB     $30                       ; convert from ASCII to digit

; -----------------
; Stack accumulator
; -----------------
;
;

stack_a:
        LD      C,A                       ; transfer to C
        LD      B,$00                     ; and make B zero

; ----------------------
; Stack BC register pair
; ----------------------
;

stack_bc:
        LD      IY,ERR_NR                 ; re-initialize ERR_NR

        XOR     A                         ; clear to signal small integer
        LD      E,A                       ; place in E for sign
        LD      D,C                       ; LSB to D
        LD      C,B                       ; MSB to C
        LD      B,A                       ; last byte not used
        CALL    stk_store                 ; routine STK-STORE

        RST     28H                       ;; FP-CALC
        DEFB    $38                       ;;end-calc  make HL = STKEND-5

        AND     A                         ; clear carry
        RET                               ; before returning

; -------------------------
; Integer to floating point
; -------------------------
; This routine places one or more digits found in a BASIC line
; on the calculator stack multiplying the previous value by ten each time
; before adding in the new digit to form a last value on calculator stack.

int_to_fp:
        PUSH    AF                        ; save first character

        RST     28H                       ;; FP-CALC
        DEFB    $A0                       ;;stk-zero    ; v=0. initial value
        DEFB    $38                       ;;end-calc

        POP     AF                        ; fetch first character back.

nxt_dgt_2:
        CALL    stk_digit                 ; routine STK-DIGIT puts 0-9 on stack
        RET     C                         ; will return when character is not numeric >

        RST     28H                       ;; FP-CALC    ; v, d.
        DEFB    $01                       ;;exchange    ; d, v.
        DEFB    $A4                       ;;stk-ten     ; d, v, 10.
        DEFB    $04                       ;;multiply    ; d, v*10.
        DEFB    $0F                       ;;addition    ; d + v*10 = newvalue
        DEFB    $38                       ;;end-calc    ; v.

        CALL    ch_add_plus_1             ; routine CH-ADD+1 get next character
        JR      nxt_dgt_2                 ; back to NXT-DGT-2 to process as a digit


;*********************************
;** Part 9. ARITHMETIC ROUTINES **
;*********************************

; --------------------------
; E-format to floating point
; --------------------------
; This subroutine is used by the PRINT-FP routine and the decimal to FP
; routines to stack a number expressed in exponent format.
; Note. Though not used by the ROM as such, it has also been set up as
; a unary calculator literal but this will not work as the accumulator
; is not available from within the calculator.

; on entry there is a value x on the calculator stack and an exponent of ten
; in A.    The required value is x + 10 ^ A

e_to_fp:
e_to_fp:
        RLCA                              ; this will set the          x.
        RRCA                              ; carry if bit 7 is set

        JR      NC,e_save                 ; to E-SAVE  if positive.

        CPL                               ; make negative positive
        INC     A                         ; without altering carry.

e_save:
        PUSH    AF                        ; save positive exp and sign in carry

        LD      HL,MEMBOT                 ; address MEM-0

        CALL    fp_0slash1                ; routine FP-0/1
                                          ; places an integer zero, if no carry,
                                          ; else a one in mem-0 as a sign flag

        RST     28H                       ;; FP-CALC
        DEFB    $A4                       ;;stk-ten                    x, 10.
        DEFB    $38                       ;;end-calc

        POP     AF                        ; pop the exponent.

; now enter a loop

e_loop:
        SRL     A                         ; 0>76543210>C

        JR      NC,e_tst_end              ; forward to E-TST-END if no bit

        PUSH    AF                        ; save shifted exponent.

        RST     28H                       ;; FP-CALC
        DEFB    $C1                       ;;st-mem-1                   x, 10.
        DEFB    $E0                       ;;get-mem-0                  x, 10, (0/1).
        DEFB    $00                       ;;jump-true

        DEFB    $04                       ;;to e_divsn, E-DIVSN

        DEFB    $04                       ;;multiply                   x*10.
        DEFB    $33                       ;;jump

        DEFB    $02                       ;;to e_fetch, E-FETCH

e_divsn:
        DEFB    $05                       ;;division                   x/10.

e_fetch:
        DEFB    $E1                       ;;get-mem-1                  x/10 or x*10, 10.
        DEFB    $38                       ;;end-calc                   new x, 10.

        POP     AF                        ; restore shifted exponent

; the loop branched to here with no carry

e_tst_end:
        JR      Z,e_end                   ; forward to E-END  if A emptied of bits

        PUSH    AF                        ; re-save shifted exponent

        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate                  new x, 10, 10.
        DEFB    $04                       ;;multiply                   new x, 100.
        DEFB    $38                       ;;end-calc

        POP     AF                        ; restore shifted exponent
        JR      e_loop                    ; back to E-LOOP  until all bits done.

; ---

; although only the first pass is shown it can be seen that for each set bit
; representing a power of two, x is multiplied or divided by the
; corresponding power of ten.

e_end:
        RST     28H                       ;; FP-CALC                   final x, factor.
        DEFB    $02                       ;;delete                     final x.
        DEFB    $38                       ;;end-calc                   x.

        RET                               ; return




; -------------
; Fetch integer
; -------------
; This routine is called by the mathematical routines - FP-TO-BC, PRINT-FP,
; mult, re-stack and negate to fetch an integer from address HL.
; HL points to the stack or a location in MEM and no deletion occurs.
; If the number is negative then a similar process to that used in INT-STORE
; is used to restore the twos complement number to normal in DE and a sign
; in C.

int_fetch:
        INC     HL                        ; skip zero indicator.
        LD      C,(HL)                    ; fetch sign to C
        INC     HL                        ; address low byte
        LD      A,(HL)                    ; fetch to A
        XOR     C                         ; two's complement
        SUB     C                         ;
        LD      E,A                       ; place in E
        INC     HL                        ; address high byte
        LD      A,(HL)                    ; fetch to A
        ADC     A,C                       ; two's complement
        XOR     C                         ;
        LD      D,A                       ; place in D
        RET                               ; return

; ------------------------
; Store a positive integer
; ------------------------
; This entry point is not used in this ROM but would
; store any integer as positive.

p_int_sto:
        LD      C,$00                     ; make sign byte positive and continue

; -------------
; Store integer
; -------------
; this routine stores an integer in DE at address HL.
; It is called from mult, truncate, negate and sgn.
; The sign byte $00 +ve or $FF -ve is in C.
; If negative, the number is stored in 2's complement form so that it is
; ready to be added.

int_store:
        PUSH    HL                        ; preserve HL

        LD      (HL),$00                  ; first byte zero shows integer not exponent
        INC     HL                        ;
        LD      (HL),C                    ; then store the sign byte
        INC     HL                        ;
                                          ; e.g.             +1             -1
        LD      A,E                       ; fetch low byte   00000001       00000001
        XOR     C                         ; xor sign         00000000   or  11111111
                                          ; gives            00000001   or  11111110
        SUB     C                         ; sub sign         00000000   or  11111111
                                          ; gives            00000001>0 or  11111111>C
        LD      (HL),A                    ; store 2's complement.
        INC     HL                        ;
        LD      A,D                       ; high byte        00000000       00000000
        ADC     A,C                       ; sign             00000000<0     11111111<C
                                          ; gives            00000000   or  00000000
        XOR     C                         ; xor sign         00000000       11111111
        LD      (HL),A                    ; store 2's complement.
        INC     HL                        ;
        LD      (HL),$00                  ; last byte always zero for integers.
                                          ; is not used and need not be looked at when
                                          ; testing for zero but comes into play should
                                          ; an integer be converted to fp.
        POP     HL                        ; restore HL
        RET                               ; return.


; -----------------------------
; Floating point to BC register
; -----------------------------
; This routine gets a floating point number e.g. 127.4 from the calculator
; stack to the BC register.

fp_to_bc:
        RST     28H                       ;; FP-CALC            set HL to
        DEFB    $38                       ;;end-calc            point to last value.

        LD      A,(HL)                    ; get first of 5 bytes
        AND     A                         ; and test
        JR      Z,fp_delete               ; forward to FP-DELETE if an integer

; The value is first rounded up and then converted to integer.

        RST     28H                       ;; FP-CALC           x.
        DEFB    $A2                       ;;stk-half           x. 1/2.
        DEFB    $0F                       ;;addition           x + 1/2.
        DEFB    $27                       ;;int                int(x + .5)
        DEFB    $38                       ;;end-calc

; now delete but leave HL pointing at integer

fp_delete:
        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        PUSH    HL                        ; save pointer.
        PUSH    DE                        ; and STKEND.
        EX      DE,HL                     ; make HL point to exponent/zero indicator
        LD      B,(HL)                    ; indicator to B
        CALL    int_fetch                 ; routine INT-FETCH
                                          ; gets int in DE sign byte to C
                                          ; but meaningless values if a large integer

        XOR     A                         ; clear A
        SUB     B                         ; subtract indicator byte setting carry
                                          ; if not a small integer.

        BIT     7,C                       ; test a bit of the sign byte setting zero
                                          ; if positive.

        LD      B,D                       ; transfer int
        LD      C,E                       ; to BC
        LD      A,E                       ; low byte to A as a useful return value.

        POP     DE                        ; pop STKEND
        POP     HL                        ; and pointer to last value
        RET                               ; return
                                          ; if carry is set then the number was too big.

; ------------
; LOG(2^A)
; ------------
; This routine is used when printing floating point numbers to calculate
; the number of digits before the decimal point.

; first convert a one-byte signed integer to its five byte form.

log2to_thea:
        LD      D,A                       ; store a copy of A in D.
        RLA                               ; test sign bit of A.
        SBC     A,A                       ; now $FF if negative or $00
        LD      E,A                       ; sign byte to E.
        LD      C,A                       ; and to C
        XOR     A                         ; clear A
        LD      B,A                       ; and B.
        CALL    stk_store                 ; routine STK-STORE stacks number AEDCB

;  so 00 00 XX 00 00 (positive) or 00 FF XX FF 00 (negative).
;  i.e. integer indicator, sign byte, low, high, unused.

; now multiply exponent by log to the base 10 of two.

        RST      28H                      ;; FP-CALC

        DEFB    $34                       ;;stk-data                      .30103 (log 2)
        DEFB    $EF                       ;;Exponent: $7F, Bytes: 4
        DEFB    $1A,$20,$9A,$85           ;;
        DEFB    $04                       ;;multiply

        DEFB    $27                       ;;int

        DEFB    $38                       ;;end-calc

; -------------------
; Floating point to A
; -------------------
; this routine collects a floating point number from the stack into the
; accumulator returning carry set if not in range 0 - 255.
; Not all the calling routines raise an error with overflow so no attempt
; is made to produce an error report here.

fp_to_a:
        CALL    fp_to_bc                  ; routine FP-TO-BC returns with C in A also.
        RET     C                         ; return with carry set if > 65535, overflow

        PUSH    AF                        ; save the value and flags
        DEC     B                         ; and test that
        INC     B                         ; the high byte is zero.
        JR      Z,fp_a_end                ; forward  FP-A-END if zero

; else there has been 8-bit overflow

        POP     AF                        ; retrieve the value
        SCF                               ; set carry flag to show overflow
        RET                               ; and return.

; ---

fp_a_end:
        POP     AF                        ; restore value and success flag and
        RET                               ; return.


; -----------------------------
; Print a floating point number
; -----------------------------
; Not a trivial task.
; Begin by considering whether to print a leading sign for negative numbers.

print_fp:
        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate
        DEFB    $36                       ;;less-0
        DEFB    $00                       ;;jump-true

        DEFB    $0B                       ;;to pf_negtve, PF-NEGTVE

        DEFB    $31                       ;;duplicate
        DEFB    $37                       ;;greater-0
        DEFB    $00                       ;;jump-true

        DEFB    $0D                       ;;to pf_postve, PF-POSTVE

; must be zero itself

        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

        LD      A,$30                     ; prepare the character '0'

        RST     10H                       ; PRINT-A
        RET                               ; return.                 ->
; ---

pf_negtve:
        DEFB    $2A                       ;;abs
        DEFB    $38                       ;;end-calc

        LD      A,$2D                     ; the character '-'

        RST     10H                       ; PRINT-A

; and continue to print the now positive number.

        RST     28H                       ;; FP-CALC

pf_postve:
        DEFB    $A0                       ;;stk-zero     x,0.     begin by
        DEFB    $C3                       ;;st-mem-3     x,0.     clearing a temporary
        DEFB    $C4                       ;;st-mem-4     x,0.     output buffer to
        DEFB    $C5                       ;;st-mem-5     x,0.     fifteen zeros.
        DEFB    $02                       ;;delete       x.
        DEFB    $38                       ;;end-calc     x.

        EXX                               ; in case called from 'str$' then save the
        PUSH    HL                        ; pointer to whatever comes after
        EXX                               ; str$ as H'L' will be used.

; now enter a loop?

pf_loop:
        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate    x,x.
        DEFB    $27                       ;;int          x,int x.
        DEFB    $C2                       ;;st-mem-2     x,int x.
        DEFB    $03                       ;;subtract     x-int x.     fractional part.
        DEFB    $E2                       ;;get-mem-2    x-int x, int x.
        DEFB    $01                       ;;exchange     int x, x-int x.
        DEFB    $C2                       ;;st-mem-2     int x, x-int x.
        DEFB    $02                       ;;delete       int x.
        DEFB    $38                       ;;end-calc     int x.
                                          ;
                                          ; mem-2 holds the fractional part.

; HL points to last value int x

        LD      A,(HL)                    ; fetch exponent of int x.
        AND     A                         ; test
        JR      NZ,pf_large               ; forward to PF-LARGE if a large integer
                                          ; > 65535

; continue with small positive integer components in range 0 - 65535
; if original number was say .999 then this integer component is zero.

        CALL    int_fetch                 ; routine INT-FETCH gets x in DE
                                          ; (but x is not deleted)

        LD      B,$10                     ; set B, bit counter, to 16d

        LD      A,D                       ; test if
        AND     A                         ; high byte is zero
        JR      NZ,pf_save                ; forward to PF-SAVE if 16-bit integer.

; and continue with integer in range 0 - 255.

        OR      E                         ; test the low byte for zero
                                          ; i.e. originally just point something or other.
        JR      Z,pf_small                ; forward if so to PF-SMALL

;

        LD      D,E                       ; transfer E to D
        LD      B,$08                     ; and reduce the bit counter to 8.

pf_save:
        PUSH    DE                        ; save the part before decimal point.
        EXX                               ;
        POP     DE                        ; and pop in into D'E'
        EXX                               ;
        JR      pf_bits                   ; forward to PF-BITS

; ---------------------

; the branch was here when 'int x' was found to be zero as in say 0.5.
; The zero has been fetched from the calculator stack but not deleted and
; this should occur now. This omission leaves the stack unbalanced and while
; that causes no problems with a simple PRINT statement, it will if str$ is
; being used in an expression e.g. "2" + STR$ 0.5 gives the result "0.5"
; instead of the expected result "20.5".
; credit Tony Stratton, 1982.
; A DEFB 02 delete is required immediately on using the calculator.

pf_small:
        RST     28H                       ;; FP-CALC       int x = 0.
        DEFB    $E2                       ;;get-mem-2      int x = 0, x-int x.
        DEFB    $38                       ;;end-calc

        LD      A,(HL)                    ; fetch exponent of positive fractional number
        SUB     $7E                       ; subtract

        CALL    log2to_thea               ; routine LOG(2^A) calculates leading digits.

        LD      D,A                       ; transfer count to D
        LD      A,(MEMBOT_1a)             ; fetch total MEM-5-1
        SUB     D                         ;
        LD      (MEMBOT_1a),A             ; MEM-5-1
        LD      A,D                       ;
        CALL    e_to_fp                   ; routine E-TO-FP

        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate
        DEFB    $27                       ;;int
        DEFB    $C1                       ;;st-mem-1
        DEFB    $03                       ;;subtract
        DEFB    $E1                       ;;get-mem-1
        DEFB    $38                       ;;end-calc

        CALL    fp_to_a                   ; routine FP-TO-A

        PUSH    HL                        ; save HL
        LD      (MEMBOT_0f),A             ; MEM-3-1
        DEC     A                         ;
        RLA                               ;
        SBC     A,A                       ;
        INC     A                         ;

        LD      HL,MEMBOT_19              ; address MEM-5-1 leading digit counter
        LD      (HL),A                    ; store counter
        INC     HL                        ; address MEM-5-2 total digits
        ADD     A,(HL)                    ; add counter to contents
        LD      (HL),A                    ; and store updated value
        POP     HL                        ; restore HL

        JP      pf_fractn                 ; JUMP forward to PF-FRACTN

; ---

; Note. while it would be pedantic to comment on every occasion a JP
; instruction could be replaced with a JR instruction, this applies to the
; above, which is useful if you wish to correct the unbalanced stack error
; by inserting a 'DEFB 02 delete' at DEFB $E2 above, and maintain main addresses.

; the branch was here with a large positive integer > 65535 e.g. 123456789
; the accumulator holds the exponent.

pf_large:
        SUB     $80                       ; make exponent positive
        CP      $1C                       ; compare to 28
        JR      C,pf_medium               ; to PF-MEDIUM if integer <= 2^27

        CALL    log2to_thea               ; routine LOG(2^A)
        SUB     $07                       ;
        LD      B,A                       ;
        LD      HL,MEMBOT_1a              ; address MEM-5-1 the leading digits counter.
        ADD     A,(HL)                    ; add A to contents
        LD      (HL),A                    ; store updated value.
        LD      A,B                       ;
        NEG                               ; negate
        CALL    e_to_fp                   ; routine E-TO-FP
        JR      pf_loop                   ; back to PF-LOOP

; ----------------------------

pf_medium:
        EX      DE,HL                     ;
        CALL    fetch_two                 ; routine FETCH-TWO
        EXX                               ;
        SET     7,D                       ;
        LD      A,L                       ;
        EXX                               ;
        SUB     $80                       ;
        LD      B,A                       ;

; the branch was here to handle bits in DE with 8 or 16 in B  if small int
; and integer in D'E', 6 nibbles will accommodate 065535 but routine does
; 32-bit numbers as well from above

pf_bits:
        SLA     E                         ;  C<xxxxxxxx<0
        RL      D                         ;  C<xxxxxxxx<C
        EXX                               ;
        RL      E                         ;  C<xxxxxxxx<C
        RL      D                         ;  C<xxxxxxxx<C
        EXX                               ;

        LD      HL,MEMBOT_18              ; set HL to mem-4-5th last byte of buffer
        LD      C,$05                     ; set byte count to 5 -  10 nibbles

pf_bytes:
        LD      A,(HL)                    ; fetch 0 or prev value
        ADC     A,A                       ; shift left add in carry    C<xxxxxxxx<C

        DAA                               ; Decimal Adjust Accumulator.
                                          ; if greater than 9 then the left hand
                                          ; nibble is incremented. If greater than
                                          ; 99 then adjusted and carry set.
                                          ; so if we'd built up 7 and a carry came in
                                          ;      0000 0111 < C
                                          ;      0000 1111
                                          ; daa     1 0101  which is 15 in BCD

        LD      (HL),A                    ; put back
        DEC     HL                        ; work down thru mem 4
        DEC     C                         ; decrease the 5 counter.
        JR      NZ,pf_bytes               ; back to PF-BYTES until the ten nibbles rolled

        DJNZ    pf_bits                   ; back to PF-BITS until 8 or 16 (or 32) done

; at most 9 digits for 32-bit number will have been loaded with digits
; each of the 9 nibbles in mem 4 is placed into ten bytes in mem-3 and mem 4
; unless the nibble is zero as the buffer is already zero.
; ( or in the case of mem-5 will become zero as a result of RLD instruction )

        XOR     A                         ; clear to accept
        LD      HL,MEMBOT_14              ; address MEM-4-0 byte destination.
        LD      DE,MEMBOT_0f              ; address MEM-3-0 nibble source.
        LD      B,$09                     ; the count is 9 (not ten) as the first
                                          ; nibble is known to be blank.

        RLD                               ; shift RH nibble to left in (HL)
                                          ;    A           (HL)
                                          ; 0000 0000 < 0000 3210
                                          ; 0000 0000   3210 0000
                                          ; A picks up the blank nibble


        LD      C,$FF                     ; set a flag to indicate when a significant
                                          ; digit has been encountered.

pf_digits:
        RLD                               ; pick up leftmost nibble from (HL)
                                          ;    A           (HL)
                                          ; 0000 0000 < 7654 3210
                                          ; 0000 7654   3210 0000


        JR      NZ,pf_insert              ; to PF-INSERT if non-zero value picked up.

        DEC     C                         ; test
        INC     C                         ; flag
        JR      NZ,pf_test_2              ; skip forward to PF-TEST-2 if flag still $FF
                                          ; indicating this is a leading zero.

; but if the zero is a significant digit e.g. 10 then include in digit totals.
; the path for non-zero digits rejoins here.

pf_insert:
        LD      (DE),A                    ; insert digit at destination
        INC     DE                        ; increase the destination pointer
        INC     (IY+(MEMBOT_19-C_IY))     ; increment MEM-5-1st  digit counter
        INC     (IY+(MEMBOT_1a-C_IY))     ; increment MEM-5-2nd  leading digit counter
        LD      C,$00                     ; set flag to zero indicating that any
                                          ; subsequent zeros are significant and not
                                          ; leading.

pf_test_2:
        BIT     0,B                       ; test if the nibble count is even
        JR      Z,pf_all_9                ; skip to PF-ALL-9 if so to deal with the
                                          ; other nibble in the same byte

        INC     HL                        ; point to next source byte if not

pf_all_9:
        DJNZ    pf_digits                 ; decrement the nibble count, back to PF-DIGITS
                                          ; if all nine not done.

; For 8-bit integers there will be at most 3 digits.
; For 16-bit integers there will be at most 5 digits.
; but for larger integers there could be nine leading digits.
; if nine digits complete then the last one is rounded up as the number will
; be printed using E-format notation

        LD      A,(MEMBOT_19)             ; fetch digit count from MEM-5-1st
        SUB     $09                       ; subtract 9 - max possible
        JR      C,pf_more                 ; forward if less to PF-MORE

        DEC     (IY+(MEMBOT_19-C_IY))     ; decrement digit counter MEM-5-1st to 8
        LD      A,$04                     ; load A with the value 4.
        CP      (IY+(MEMBOT_17-C_IY))     ; compare with MEM-4-4th - the ninth digit
        JR      pf_round                  ; forward to PF-ROUND
                                          ; to consider rounding.

; ---------------------------------------

; now delete int x from calculator stack and fetch fractional part.

pf_more:
        RST     28H                       ;; FP-CALC        int x.
        DEFB    $02                       ;;delete          .
        DEFB    $E2                       ;;get-mem-2       x - int x = f.
        DEFB    $38                       ;;end-calca       f.

pf_fractn:
        EX      DE,HL                     ;
        CALL    fetch_two                 ; routine FETCH-TWO
        EXX                               ;
        LD      A,$80                     ;
        SUB     L                         ;
        LD      L,$00                     ;
        SET     7,D                       ;
        EXX                               ;
        CALL    shift_fp                  ; routine SHIFT-FP

pf_frn_lp:
        LD      A,(IY+(MEMBOT_19-C_IY))   ; MEM-5-1st
        CP      $08                       ;
        JR      C,pf_fr_dgt               ; to PF-FR-DGT

        EXX                               ;
        RL      D                         ;
        EXX                               ;
        JR      pf_round                  ; to PF-ROUND

; ---

pf_fr_dgt:
        LD      BC,$0200                  ;

pf_fr_exx:
        LD      A,E                       ;
        CALL    ca_10timesa_plus_c        ; routine CA-10*A+C
        LD      E,A                       ;
        LD      A,D                       ;
        CALL    ca_10timesa_plus_c        ; routine CA-10*A+C
        LD      D,A                       ;
        PUSH    BC                        ;
        EXX                               ;
        POP     BC                        ;
        DJNZ    pf_fr_exx                 ; to PF-FR-EXX

        LD      HL,MEMBOT_0f              ; MEM-3
        LD      A,C                       ;
        LD      C,(IY+(MEMBOT_19-C_IY))   ; MEM-5-1st
        ADD     HL,BC                     ;
        LD      (HL),A                    ;
        INC     (IY+(MEMBOT_19-C_IY))     ; MEM-5-1st
        JR      pf_frn_lp                 ; to PF-FRN-LP

; ----------------

; 1) with 9 digits but 8 in mem-5-1 and A holding 4, carry set if rounding up.
; e.g.
;      999999999 is printed as 1E+9
;      100000001 is printed as 1E+8
;      100000009 is printed as 1.0000001E+8

pf_round:
        PUSH    AF                        ; save A and flags
        LD      HL,MEMBOT_0f              ; address MEM-3 start of digits
        LD      C,(IY+(MEMBOT_19-C_IY))   ; MEM-5-1st No. of digits to C
        LD      B,$00                     ; prepare to add
        ADD     HL,BC                     ; address last digit + 1
        LD      B,C                       ; No. of digits to B counter
        POP     AF                        ; restore A and carry flag from comparison.

pf_rnd_lp:
        DEC     HL                        ; address digit at rounding position.
        LD      A,(HL)                    ; fetch it
        ADC     A,$00                     ; add carry from the comparison
        LD      (HL),A                    ; put back result even if $0A.
        AND     A                         ; test A
        JR      Z,pf_r_back               ; skip to PF-R-BACK if ZERO?

        CP      $0A                       ; compare to 'ten' - overflow
        CCF                               ; complement carry flag so that set if ten.
        JR      NC,pf_count               ; forward to PF-COUNT with 1 - 9.

pf_r_back:
        DJNZ    pf_rnd_lp                 ; loop back to PF-RND-LP

; if B counts down to zero then we've rounded right back as in 999999995.
; and the first 8 locations all hold $0A.


        LD      (HL),$01                  ; load first location with digit 1.
        INC     B                         ; make B hold 1 also.
                                          ; could save an instruction byte here.
        INC     (IY+(MEMBOT_1a-C_IY))     ; make MEM-5-2nd hold 1.
                                          ; and proceed to initialize total digits to 1.

pf_count:
        LD      (IY+(MEMBOT_19-C_IY)),B   ; MEM-5-1st

; now balance the calculator stack by deleting  it

        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc

; note if used from str$ then other values may be on the calculator stack.
; we can also restore the next literal pointer from its position on the
; machine stack.

        EXX                               ;
        POP     HL                        ; restore next literal pointer.
        EXX                               ;

        LD      BC,(MEMBOT_19)            ; set C to MEM-5-1st digit counter.
                                          ; set B to MEM-5-2nd leading digit counter.
        LD      HL,MEMBOT_0f              ; set HL to start of digits at MEM-3-1
        LD      A,B                       ;
        CP      $09                       ;
        JR      C,pf_not_e                ; to PF-NOT-E

        CP      $FC                       ;
        JR      C,pf_e_frmt               ; to PF-E-FRMT

pf_not_e:
        AND     A                         ; test for zero leading digits as in .123

        CALL    Z,out_code                ; routine OUT-CODE prints a zero e.g. 0.123

pf_e_sbrn:
        XOR     A                         ;
        SUB     B                         ;
        JP      M,pf_out_lp               ; skip forward to PF-OUT-LP if originally +ve

        LD      B,A                       ; else negative count now +ve
        JR      pf_dc_out                 ; forward to PF-DC-OUT       ->

; ---

pf_out_lp:
        LD      A,C                       ; fetch total digit count
        AND     A                         ; test for zero
        JR      Z,pf_out_dt               ; forward to PF-OUT-DT if so

        LD      A,(HL)                    ; fetch digit
        INC     HL                        ; address next digit
        DEC     C                         ; decrease total digit counter

pf_out_dt:
        CALL    out_code                  ; routine OUT-CODE outputs it.
        DJNZ    pf_out_lp                 ; loop back to PF-OUT-LP until B leading
                                          ; digits output.

pf_dc_out:
        LD      A,C                       ; fetch total digits and
        AND     A                         ; test if also zero
        RET     Z                         ; return if so              -->

;

        INC     B                         ; increment B
        LD      A,$2E                     ; prepare the character '.'

pf_dec_0string:
        RST     10H                       ; PRINT-A outputs the character '.' or '0'

        LD      A,$30                     ; prepare the character '0'
                                          ; (for cases like .000012345678)
        DJNZ    pf_dec_0string            ; loop back to PF-DEC-0$ for B times.

        LD      B,C                       ; load B with now trailing digit counter.
        JR      pf_out_lp                 ; back to PF-OUT-LP

; ---------------------------------

; the branch was here for E-format printing e.g 123456789 => 1.2345679e+8

pf_e_frmt:
        LD      D,B                       ; counter to D
        DEC     D                         ; decrement
        LD      B,$01                     ; load B with 1.

        CALL    pf_e_sbrn                 ; routine PF-E-SBRN above

        LD      A,$45                     ; prepare character 'e'
        RST     10H                       ; PRINT-A

        LD      C,D                       ; exponent to C
        LD      A,C                       ; and to A
        AND     A                         ; test exponent
        JP      P,pf_e_pos                ; to PF-E-POS if positive

        NEG                               ; negate
        LD      C,A                       ; positive exponent to C
        LD      A,$2D                     ; prepare character '-'
        JR      pf_e_sign                 ; skip to PF-E-SIGN

; ---

pf_e_pos:
        LD      A,$2B                     ; prepare character '+'

pf_e_sign:
        RST     10H                       ; PRINT-A outputs the sign

        LD      B,$00                     ; make the high byte zero.
        JP      out_num_1                 ; exit via OUT-NUM-1 to print exponent in BC

; ------------------------------
; Handle printing floating point
; ------------------------------
; This subroutine is called twice from above when printing floating-point
; numbers. It returns 10*A +C in registers C and A

ca_10timesa_plus_c:
        PUSH    DE                        ; preserve DE.
        LD      L,A                       ; transfer A to L
        LD      H,$00                     ; zero high byte.
        LD      E,L                       ; copy HL
        LD      D,H                       ; to DE.
        ADD     HL,HL                     ; double (*2)
        ADD     HL,HL                     ; double (*4)
        ADD     HL,DE                     ; add DE (*5)
        ADD     HL,HL                     ; double (*10)
        LD      E,C                       ; copy C to E    (D is 0)
        ADD     HL,DE                     ; and add to give required result.
        LD      C,H                       ; transfer to
        LD      A,L                       ; destination registers.
        POP     DE                        ; restore DE
        RET                               ; return with result.

; --------------
; Prepare to add
; --------------
; This routine is called twice by addition to prepare the two numbers. The
; exponent is picked up in A and the location made zero. Then the sign bit
; is tested before being set to the implied state. Negative numbers are twos
; complemented.

prep_add:
        LD      A,(HL)                    ; pick up exponent
        LD      (HL),$00                  ; make location zero
        AND     A                         ; test if number is zero
        RET     Z                         ; return if so

        INC     HL                        ; address mantissa
        BIT     7,(HL)                    ; test the sign bit
        SET     7,(HL)                    ; set it to implied state
        DEC     HL                        ; point to exponent
        RET     Z                         ; return if positive number.

        PUSH    BC                        ; preserve BC
        LD      BC,$0005                  ; length of number
        ADD     HL,BC                     ; point HL past end
        LD      B,C                       ; set B to 5 counter
        LD      C,A                       ; store exponent in C
        SCF                               ; set carry flag

neg_byte:
        DEC     HL                        ; work from LSB to MSB
        LD      A,(HL)                    ; fetch byte
        CPL                               ; complement
        ADC     A,$00                     ; add in initial carry or from prev operation
        LD      (HL),A                    ; put back
        DJNZ    neg_byte                  ; loop to NEG-BYTE till all 5 done

        LD      A,C                       ; stored exponent to A
        POP     BC                        ; restore original BC
        RET                               ; return

; -----------------
; Fetch two numbers
; -----------------
; This routine is called twice when printing floating point numbers and also
; to fetch two numbers by the addition, multiply and division routines.
; HL addresses the first number, DE addresses the second number.
; For arithmetic only, A holds the sign of the result which is stored in
; the second location.

fetch_two:
        PUSH    HL                        ; save pointer to first number, result if math.
        PUSH    AF                        ; save result sign.

        LD      C,(HL)                    ;
        INC     HL                        ;

        LD      B,(HL)                    ;
        LD      (HL),A                    ; store the sign at correct location in
                                          ; destination 5 bytes for arithmetic only.
        INC     HL                        ;

        LD      A,C                       ;
        LD      C,(HL)                    ;
        PUSH    BC                        ;
        INC     HL                        ;
        LD      C,(HL)                    ;
        INC     HL                        ;
        LD      B,(HL)                    ;
        EX      DE,HL                     ;
        LD      D,A                       ;
        LD      E,(HL)                    ;
        PUSH    DE                        ;
        INC     HL                        ;
        LD      D,(HL)                    ;
        INC     HL                        ;
        LD      E,(HL)                    ;
        PUSH    DE                        ;
        EXX                               ;
        POP     DE                        ;
        POP     HL                        ;
        POP     BC                        ;
        EXX                               ;
        INC     HL                        ;
        LD      D,(HL)                    ;
        INC     HL                        ;
        LD      E,(HL)                    ;

        POP     AF                        ; restore possible result sign.
        POP     HL                        ; and pointer to possible result.
        RET                               ; return.

; ---------------------------------
; Shift floating point number right
; ---------------------------------
;
;

shift_fp:
        AND     A                         ;
        RET     Z                         ;

        CP      $21                       ;
        JR      NC,addend_0               ; to ADDEND-0

        PUSH    BC                        ;
        LD      B,A                       ;

one_shift:
        EXX                               ;
        SRA     L                         ;
        RR      D                         ;
        RR      E                         ;
        EXX                               ;
        RR      D                         ;
        RR      E                         ;
        DJNZ    one_shift                 ; to ONE-SHIFT

        POP     BC                        ;
        RET     NC                        ;

        CALL    add_back                  ; routine ADD-BACK
        RET     NZ                        ;

addend_0:
        EXX                               ;
        XOR     A                         ;

zeros_4slash5:
        LD      L,$00                     ;
        LD      D,A                       ;
        LD      E,L                       ;
        EXX                               ;
        LD      DE,$0000                  ;
        RET                               ;

; ------------------
; Add back any carry
; ------------------
;
;

add_back:
        INC     E                         ;
        RET     NZ                        ;

        INC      D                        ;
        RET     NZ                        ;

        EXX                               ;
        INC     E                         ;
        JR      NZ,all_added              ; to ALL-ADDED

        INC     D                         ;

all_added:
        EXX                               ;
        RET                               ;

; -----------------------
; Handle subtraction (03)
; -----------------------
; Subtraction is done by switching the sign byte/bit of the second number
; which may be integer of floating point and continuing into addition.

subtract:
        EX      DE,HL                     ; address second number with HL

        CALL    negate                    ; routine NEGATE switches sign

        EX      DE,HL                     ; address first number again
                                          ; and continue.

; --------------------
; Handle addition (0F)
; --------------------
; HL points to first number, DE to second.
; If they are both integers, then go for the easy route.

addition:
        LD      A,(DE)                    ; fetch first byte of second
        OR      (HL)                      ; combine with first byte of first
        JR      NZ,full_addn              ; forward to FULL-ADDN if at least one was
                                          ; in floating point form.

; continue if both were small integers.

        PUSH    DE                        ; save pointer to lowest number for result.

        INC     HL                        ; address sign byte and
        PUSH    HL                        ; push the pointer.

        INC     HL                        ; address low byte
        LD      E,(HL)                    ; to E
        INC     HL                        ; address high byte
        LD      D,(HL)                    ; to D
        INC     HL                        ; address unused byte

        INC     HL                        ; address known zero indicator of 1st number
        INC     HL                        ; address sign byte

        LD      A,(HL)                    ; sign to A, $00 or $FF

        INC     HL                        ; address low byte
        LD      C,(HL)                    ; to C
        INC     HL                        ; address high byte
        LD      B,(HL)                    ; to B

        POP     HL                        ; pop result sign pointer
        EX      DE,HL                     ; integer to HL

        ADD     HL,BC                     ; add to the other one in BC
                                          ; setting carry if overflow.

        EX      DE,HL                     ; save result in DE bringing back sign pointer

        ADC     A,(HL)                    ; if pos/pos A=01 with overflow else 00
                                          ; if neg/neg A=FF with overflow else FE
                                          ; if mixture A=00 with overflow else FF

        RRCA                              ; bit 0 to (C)

        ADC     A,$00                     ; both acceptable signs now zero

        JR      NZ,addn_oflw              ; forward to ADDN-OFLW if not

        SBC     A,A                       ; restore a negative result sign

        LD      (HL),A                    ;
        INC     HL                        ;
        LD      (HL),E                    ;
        INC     HL                        ;
        LD      (HL),D                    ;
        DEC     HL                        ;
        DEC     HL                        ;
        DEC     HL                        ;

        POP     DE                        ; STKEND
        RET                               ;

; ---

addn_oflw:
        DEC     HL                        ;
        POP     DE                        ;

full_addn:
        CALL    re_st_two                 ; routine RE-ST-TWO
        EXX                               ;
        PUSH    HL                        ;
        EXX                               ;
        PUSH    DE                        ;
        PUSH    HL                        ;
        CALL    prep_add                  ; routine PREP-ADD
        LD      B,A                       ;
        EX      DE,HL                     ;
        CALL    prep_add                  ; routine PREP-ADD
        LD       C,A                      ;
        CP      B                         ;
        JR      NC,shift_len              ; to SHIFT-LEN

        LD      A,B                       ;
        LD      B,C                       ;
        EX      DE,HL                     ;

shift_len:
        PUSH    AF                        ;
        SUB     B                         ;
        CALL    fetch_two                 ; routine FETCH-TWO
        CALL    shift_fp                  ; routine SHIFT-FP
        POP     AF                        ;
        POP     HL                        ;
        LD      (HL),A                    ;
        PUSH    HL                        ;
        LD      L,B                       ;
        LD      H,C                       ;
        ADD     HL,DE                     ;
        EXX                               ;
        EX      DE,HL                     ;
        ADC     HL,BC                     ;
        EX      DE,HL                     ;
        LD      A,H                       ;
        ADC     A,L                       ;
        LD      L,A                       ;
        RRA                               ;
        XOR     L                         ;
        EXX                               ;
        EX      DE,HL                     ;
        POP     HL                        ;
        RRA                               ;
        JR      NC,test_neg               ; to TEST-NEG

        LD      A,$01                     ;
        CALL    shift_fp                  ; routine SHIFT-FP
        INC     (HL)                      ;
        JR      Z,add_rep_6               ; to ADD-REP-6

test_neg:
        EXX                               ;
        LD      A,L                       ;
        AND     $80                       ;
        EXX                               ;
        INC     HL                        ;
        LD      (HL),A                    ;
        DEC     HL                        ;
        JR      Z,go_nc_mlt               ; to GO-NC-MLT

        LD      A,E                       ;
        NEG                               ; Negate
        CCF                               ; Complement Carry Flag
        LD      E,A                       ;
        LD      A,D                       ;
        CPL                               ;
        ADC     A,$00                     ;
        LD      D,A                       ;
        EXX                               ;
        LD      A,E                       ;
        CPL                               ;
        ADC     A,$00                     ;
        LD      E,A                       ;
        LD      A,D                       ;
        CPL                               ;
        ADC     A,$00                     ;
        JR      NC,end_compl              ; to END-COMPL

        RRA                               ;
        EXX                               ;
        INC     (HL)                      ;

add_rep_6:
        JP      Z,report_6                ; to REPORT-6

        EXX                               ;

end_compl:
        LD      D,A                       ;
        EXX                               ;

go_nc_mlt:
        XOR     A                         ;
        JP      test_norm                 ; to TEST-NORM

; -----------------------------
; Used in 16 bit multiplication
; -----------------------------
; This routine is used, in the first instance, by the multiply calculator
; literal to perform an integer multiplication in preference to
; 32-bit multiplication to which it will resort if this overflows.
;
; It is also used by STK-VAR to calculate array subscripts and by DIM to
; calculate the space required for multi-dimensional arrays.

hl_mult_de:
        PUSH    BC                        ; preserve BC throughout
        LD      B,$10                     ; set B to 16
        LD      A,H                       ; save H in A high byte
        LD      C,L                       ; save L in C low byte
        LD      HL,$0000                  ; initialize result to zero

; now enter a loop.

hl_loop:
        ADD     HL,HL                     ; double result
        JR      C,hl_end                  ; to HL-END if overflow

        RL      C                         ; shift AC left into carry
        RLA                               ;
        JR      NC,hl_again               ; to HL-AGAIN to skip addition if no carry

        ADD     HL,DE                     ; add in DE
        JR      C,hl_end                  ; to HL-END if overflow

hl_again:
        DJNZ    hl_loop                   ; back to HL-LOOP for all 16 bits

hl_end:
        POP     BC                        ; restore preserved BC
        RET                               ; return with carry reset if successful
                                          ; and result in HL.

; -----------------------------
; Prepare to multiply or divide
; -----------------------------
; This routine is called in succession from multiply and divide to prepare
; two mantissas by setting the leftmost bit that is used for the sign.
; On the first call A holds zero and picks up the sign bit. On the second
; call the two bits are XORed to form the result sign - minus * minus giving
; plus etc. If either number is zero then this is flagged.
; HL addresses the exponent.

prep_mslashd:
        CALL    test_zero                 ; routine TEST-ZERO  preserves accumulator.
        RET     C                         ; return carry set if zero

        INC     HL                        ; address first byte of mantissa
        XOR     (HL)                      ; pick up the first or xor with first.
        SET     7,(HL)                    ; now set to give true 32-bit mantissa
        DEC     HL                        ; point to exponent
        RET                               ; return with carry reset

; --------------------------
; Handle multiplication (04)
; --------------------------
;
;

multiply:
        LD      A,(DE)                    ;
        OR      (HL)                      ;
        JR      NZ,mult_long              ; to MULT-LONG

        PUSH    DE                        ;
        PUSH    HL                        ;
        PUSH    DE                        ;
        CALL    int_fetch                 ; routine INT-FETCH
        EX      DE,HL                     ;
        EX      (SP),HL                   ;
        LD      B,C                       ;
        CALL    int_fetch                 ; routine INT-FETCH
        LD      A,B                       ;
        XOR     C                         ;
        LD      C,A                       ;
        POP     HL                        ;
        CALL    hl_mult_de                ; routine HL-HL*DE
        EX      DE,HL                     ;
        POP     HL                        ;
        JR      C,mult_oflw               ; to MULT-OFLW

        LD      A,D                       ;
        OR      E                         ;
        JR      NZ,mult_rslt              ; to MULT-RSLT

        LD      C,A                       ;

mult_rslt:
        CALL    int_store                 ; routine INT-STORE
        POP      DE                       ;
        RET                               ;

; ---

mult_oflw:
        POP     DE                        ;

mult_long:
        CALL    re_st_two                 ; routine RE-ST-TWO
        XOR     A                         ;
        CALL    prep_mslashd              ; routine PREP-M/D
        RET     C                         ;

        EXX                               ;
        PUSH    HL                        ;
        EXX                               ;
        PUSH    DE                        ;
        EX      DE,HL                     ;
        CALL    prep_mslashd              ; routine PREP-M/D
        EX      DE,HL                     ;
        JR      C,zero_rslt               ; to ZERO-RSLT

        PUSH    HL                        ;
        CALL    fetch_two                 ; routine FETCH-TWO
        LD      A,B                       ;
        AND     A                         ;
        SBC     HL,HL                     ;
        EXX                               ;
        PUSH    HL                        ;
        SBC     HL,HL                     ;
        EXX                               ;
        LD      B,$21                     ;
        JR      strt_mlt                  ; to STRT-MLT

; ---

mlt_loop:
        JR      NC,no_add                 ; to NO-ADD

        ADD     HL,DE                     ;
        EXX                               ;
        ADC     HL,DE                     ;
        EXX                               ;

no_add:
        EXX                               ;
        RR      H                         ;
        RR      L                         ;
        EXX                               ;
        RR      H                         ;
        RR      L                         ;

strt_mlt:
        EXX                               ;
        RR      B                         ;
        RR      C                         ;
        EXX                               ;
        RR      C                         ;
        RRA                               ;
        DJNZ    mlt_loop                  ; to MLT-LOOP

        EX      DE,HL                     ;
        EXX                               ;
        EX      DE,HL                     ;
        EXX                               ;
        POP     BC                        ;
        POP     HL                        ;
        LD      A,B                       ;
        ADD     A,C                       ;
        JR      NZ,make_expt              ; to MAKE-EXPT

        AND     A                         ;

make_expt:
        DEC     A                         ;
        CCF                               ; Complement Carry Flag

divn_expt:
        RLA                               ;
        CCF                               ; Complement Carry Flag
        RRA                               ;
        JP      P,oflw1_clr               ; to OFLW1-CLR

        JR      NC,report_6               ; to REPORT-6

        AND     A                         ;

oflw1_clr:
        INC     A                         ;
        JR      NZ,oflw2_clr              ; to OFLW2-CLR

        JR      C,oflw2_clr               ; to OFLW2-CLR

        EXX                               ;
        BIT     7,D                       ;
        EXX                               ;
        JR      NZ,report_6               ; to REPORT-6

oflw2_clr:
        LD      (HL),A                    ;
        EXX                               ;
        LD      A,B                       ;
        EXX                               ;

test_norm:
        JR      NC,normalise              ; to NORMALISE

        LD      A,(HL)                    ;
        AND     A                         ;

near_zero:
        LD      A,$80                     ;
        JR      Z,skip_zero               ; to SKIP-ZERO

zero_rslt:
        XOR     A                         ;

skip_zero:
        EXX                               ;
        AND     D                         ;
        CALL    zeros_4slash5             ; routine ZEROS-4/5
        RLCA                              ;
        LD      (HL),A                    ;
        JR      C,oflow_clr               ; to OFLOW-CLR

        INC     HL                        ;
        LD      (HL),A                    ;
        DEC     HL                        ;
        JR      oflow_clr                 ; to OFLOW-CLR

; ---

normalise:
        LD      B,$20                     ;

shift_one:
        EXX                               ;
        BIT     7,D                       ;
        EXX                               ;
        JR      NZ,norml_now              ; to NORML-NOW

        RLCA                              ;
        RL      E                         ;
        RL      D                         ;
        EXX                               ;
        RL      E                         ;
        RL      D                         ;
        EXX                               ;
        DEC     (HL)                      ;
        JR      Z,near_zero               ; to NEAR-ZERO

        DJNZ    shift_one                 ; to SHIFT-ONE

        JR      zero_rslt                 ; to ZERO-RSLT

; ---

norml_now:
        RLA                               ;
        JR      NC,oflow_clr              ; to OFLOW-CLR

        CALL    add_back                  ; routine ADD-BACK
        JR      NZ,oflow_clr              ; to OFLOW-CLR

        EXX                               ;
        LD       D,$80                    ;
        EXX                               ;
        INC     (HL)                      ;
        JR      Z,report_6                ; to REPORT-6

oflow_clr:
        PUSH    HL                        ;
        INC     HL                        ;
        EXX                               ;
        PUSH    DE                        ;
        EXX                               ;
        POP     BC                        ;
        LD      A,B                       ;
        RLA                               ;
        RL      (HL)                      ;
        RRA                               ;
        LD      (HL),A                    ;
        INC     HL                        ;
        LD      (HL),C                    ;
        INC     HL                        ;
        LD      (HL),D                    ;
        INC     HL                        ;
        LD      (HL),E                    ;
        POP     HL                        ;
        POP     DE                        ;
        EXX                               ;
        POP     HL                        ;
        EXX                               ;
        RET                               ;

; ---

report_6:
        RST     08H                       ; ERROR-1
        DEFB    $05                       ; Error Report: Number too big

; --------------------
; Handle division (05)
; --------------------
;
;

division:
        CALL    re_st_two                 ; routine RE-ST-TWO
        EX      DE,HL                     ;
        XOR     A                         ;
        CALL    prep_mslashd              ; routine PREP-M/D
        JR      C,report_6                ; to REPORT-6

        EX      DE,HL                     ;
        CALL    prep_mslashd              ; routine PREP-M/D
        RET     C                         ;

        EXX                               ;
        PUSH    HL                        ;
        EXX                               ;
        PUSH    DE                        ;
        PUSH    HL                        ;
        CALL    fetch_two                 ; routine FETCH-TWO
        EXX                               ;
        PUSH    HL                        ;
        LD      H,B                       ;
        LD      L,C                       ;
        EXX                               ;
        LD      H,C                       ;
        LD      L,B                       ;
        XOR     A                         ;
        LD      B,$DF                     ;
        JR      div_start                 ; to DIV-START

; ---

div_loop:
        RLA                               ;
        RL      C                         ;
        EXX                               ;
        RL      C                         ;
        RL      B                         ;
        EXX                               ;

div_34th:
        ADD     HL,HL                     ;
        EXX                               ;
        ADC     HL,HL                     ;
        EXX                               ;
        JR      C,subn_only               ; to SUBN-ONLY

div_start:
        SBC     HL,DE                     ;
        EXX                               ;
        SBC     HL,DE                     ;
        EXX                               ;
        JR      NC,no_rstore              ; to NO-RSTORE

        ADD     HL,DE                     ;
        EXX                               ;
        ADC     HL,DE                     ;
        EXX                               ;
        AND     A                         ;
        JR      count_one                 ; to COUNT-ONE

; ---

subn_only:
        AND     A                         ;
        SBC     HL,DE                     ;
        EXX                               ;
        SBC     HL,DE                     ;
        EXX                               ;

no_rstore:
        SCF                               ; Set Carry Flag

count_one:
        INC     B                         ;
        JP      M,div_loop                ; to DIV-LOOP

        PUSH    AF                        ;
        JR      Z,div_start               ; to DIV-START

;
;
;
;

        LD      E,A                       ;
        LD      D,C                       ;
        EXX                               ;
        LD      E,C                       ;
        LD      D,B                       ;
        POP     AF                        ;
        RR      B                         ;
        POP     AF                        ;
        RR      B                         ;
        EXX                               ;
        POP     BC                        ;
        POP     HL                        ;
        LD      A,B                       ;
        SUB     C                         ;
        JP      divn_expt                 ; jump back to DIVN-EXPT

; ------------------------------------
; Integer truncation towards zero ($3A)
; ------------------------------------
;
;

truncate:
        LD      A,(HL)                    ;
        AND     A                         ;
        RET     Z                         ;

        CP      $81                       ;
        JR      NC,t_gr_zero              ; to T-GR-ZERO

        LD      (HL),$00                  ;
        LD      A,$20                     ;
        JR      nil_bytes                 ; to NIL-BYTES

; ---

t_gr_zero:
        CP      $91                       ;
        JR      NZ,t_small                ; to T-SMALL

        INC     HL                        ;
        INC     HL                        ;
        INC     HL                        ;
        LD      A,$80                     ;
        AND     (HL)                      ;
        DEC      HL                       ;
        OR      (HL)                      ;
        DEC     HL                        ;
        JR      NZ,t_first                ; to T-FIRST

        LD      A,$80                     ;
        XOR     (HL)                      ;

t_first:
        DEC     HL                        ;
        JR      NZ,t_expnent              ; to T-EXPNENT

        LD      (HL),A                    ;
        INC     HL                        ;
        LD      (HL),$FF                  ;
        DEC     HL                        ;
        LD      A,$18                     ;
        JR      nil_bytes                 ; to NIL-BYTES

; ---

t_small:
        JR      NC,x_large                ; to X-LARGE

        PUSH    DE                        ;
        CPL                               ;
        ADD     A,$91                     ;
        INC     HL                        ;
        LD      D,(HL)                    ;
        INC     HL                        ;
        LD      E,(HL)                    ;
        DEC     HL                        ;
        DEC     HL                        ;
        LD      C,$00                     ;
        BIT     7,D                       ;
        JR      Z,t_numeric               ; to T-NUMERIC

        DEC     C                         ;

t_numeric:
        SET     7,D                       ;
        LD      B,$08                     ;
        SUB     B                         ;
        ADD     A,B                       ;
        JR      C,t_test                  ; to T-TEST

        LD      E,D                       ;
        LD      D,$00                     ;
        SUB     B                         ;

t_test:
        JR      Z,t_store                 ; to T-STORE

        LD      B,A                       ;

t_shift:
        SRL     D                         ;
        RR      E                         ;
        DJNZ    t_shift                   ; to T-SHIFT

t_store:
        CALL    int_store                 ; routine INT-STORE
        POP     DE                        ;
        RET                               ;

; ---

t_expnent:
        LD      A,(HL)                    ;

x_large:
        SUB     $A0                       ;
        RET     P                         ;

        NEG                               ; Negate

nil_bytes:
        PUSH    DE                        ;
        EX      DE,HL                     ;
        DEC     HL                        ;
        LD      B,A                       ;
        SRL     B                         ;
        SRL     B                         ;
        SRL     B                         ;
        JR      Z,bits_zero               ; to BITS-ZERO

byte_zero:
        LD      (HL),$00                  ;
        DEC     HL                        ;
        DJNZ    byte_zero                 ; to BYTE-ZERO

bits_zero:
        AND     $07                       ;
        JR      Z,ix_end                  ; to IX-END

        LD      B,A                       ;
        LD      A,$FF                     ;

less_mask:
        SLA     A                         ;
        DJNZ    less_mask                 ; to LESS-MASK

        AND     (HL)                      ;
        LD      (HL),A                    ;

ix_end:
        EX      DE,HL                     ;
        POP     DE                        ;
        RET                               ;

; ----------------------------------
; Storage of numbers in 5 byte form.
; ==================================
; Both integers and floating-point numbers can be stored in five bytes.
; Zero is a special case stored as 5 zeros.
; For integers the form is
; Byte 1 - zero,
; Byte 2 - sign byte, $00 +ve, $FF -ve.
; Byte 3 - Low byte of integer.
; Byte 4 - High byte
; Byte 5 - unused but always zero.
;
; it seems unusual to store the low byte first but it is just as easy either
; way. Statistically it just increases the chances of trailing zeros which
; is an advantage elsewhere in saving ROM code.
;
;             zero     sign     low      high    unused
; So +1 is  00000000 00000000 00000001 00000000 00000000
;
; and -1 is 00000000 11111111 11111111 11111111 00000000
;
; much of the arithmetic found in BASIC lines can be done using numbers
; in this form using the Z80's 16 bit register operation ADD.
; (multiplication is done by a sequence of additions).
;
; Storing -ve integers in two's complement form, means that they are ready for
; addition and you might like to add the numbers above to prove that the
; answer is zero. If, as in this case, the carry is set then that denotes that
; the result is positive. This only applies when the signs don't match.
; With positive numbers a carry denotes the result is out of integer range.
; With negative numbers a carry denotes the result is within range.
; The exception to the last rule is when the result is -65536
;
; Floating point form is an alternative method of storing numbers which can
; be used for integers and larger (or fractional) numbers.
;
; In this form 1 is stored as
;           10000001 00000000 00000000 00000000 00000000
;
; When a small integer is converted to a floating point number the last two
; bytes are always blank so they are omitted in the following steps
;
; first make exponent +1 +16d  (bit 7 of the exponent is set if positive)

; 10010001 00000000 00000001
; 10010000 00000000 00000010 <-  now shift left and decrement exponent
; ...
; 10000010 01000000 00000000 <-  until a 1 abuts the imaginary point
; 10000001 10000000 00000000     to the left of the mantissa.
;
; however since the leftmost bit of the mantissa is always set then it can
; be used to denote the sign of the mantissa and put back when needed by the
; PREP routines which gives
;
; 10000001 00000000 00000000

; -----------------------------
; Re-stack two `small' integers
; -----------------------------
; This routine is called to re-stack two numbers in full floating point form
; e.g. from mult when integer multiplication has overflowed.

re_st_two:
        CALL    restk_sub                 ; routine RESTK-SUB  below and continue
                                          ; into the routine to do the other one.

restk_sub:
        EX      DE,HL                     ; swap pointers

; --------------------------------
; Re-stack one number in full form
; --------------------------------
; This routine re-stacks an integer usually on the calculator stack
; in full floating point form.
; HL points to first byte.

re_stack:
        LD      A,(HL)                    ; Fetch Exponent byte to A
        AND     A                         ; test it
        RET     NZ                        ; return if not zero as already in full
                                          ; floating-point form.

        PUSH    DE                        ; preserve DE.
        CALL    int_fetch                 ; routine INT-FETCH
                                          ; integer to DE, sign to C.

; HL points to 4th byte.

        XOR     A                         ; clear accumulator.
        INC     HL                        ; point to 5th.
        LD      (HL),A                    ; and blank.
        DEC     HL                        ; point to 4th.
        LD      (HL),A                    ; and blank.

        LD      B,$91                     ; set exponent byte +ve $81
                                          ; and imaginary dec point 16 bits to right
                                          ; of first bit.

; we could skip to normalize now but it's quicker to avoid
; normalizing through an empty D.

        LD      A,D                       ; fetch the high byte D
        AND     A                         ; is it zero ?
        JR      NZ,rs_nrmlse              ; skip to RS-NRMLSE if not.

        OR      E                         ; low byte E to A and test for zero
        LD      B,D                       ; set B exponent to 0
        JR      Z,rs_store                ; forward to RS-STORE if value is zero.

        LD      D,E                       ; transfer E to D
        LD      E,B                       ; set E to 0
        LD      B,$89                     ; reduce the initial exponent by eight.


rs_nrmlse:
        EX      DE,HL                     ; integer to HL, addr of 4th byte to DE.

rstk_loop:
        DEC     B                         ; decrease exponent
        ADD     HL,HL                     ; shift DE left
        JR      NC,rstk_loop              ; loop back to RSTK-LOOP
                                          ; until a set bit pops into carry

        RRC     C                         ; now rotate the sign byte $00 or $FF
                                          ; into carry to give a sign bit

        RR      H                         ; rotate the sign bit to left of H
        RR      L                         ; rotate any carry into L

        EX      DE,HL                     ; address 4th byte, normalized int to DE

rs_store:
        DEC     HL                        ; address 3rd byte
        LD      (HL),E                    ; place E
        DEC     HL                        ; address 2nd byte
        LD      (HL),D                    ; place D
        DEC     HL                        ; address 1st byte
        LD      (HL),B                    ; store the exponent

        POP     DE                        ; restore initial DE.
        RET                               ; return.

;****************************************
;** Part 10. FLOATING-POINT CALCULATOR **
;****************************************

; As a general rule the calculator avoids using the IY register.
; exceptions are val, val$ and str$.
; So an assembly language programmer who has disabled interrupts to use
; IY for other purposes can still use the calculator for mathematical
; purposes.


; ------------------
; Table of constants
; ------------------
;
;

; used 11 times
;                                                           00 00 00 00 00
stk_zero:
        DEFB    $00                       ;;Bytes: 1
        DEFB    $B0                       ;;Exponent $00
        DEFB    $00                       ;;(+00,+00,+00)

; used 19 times
;                                                           00 00 01 00 00
stk_one:
        DEFB    $40                       ;;Bytes: 2
        DEFB    $B0                       ;;Exponent $00
        DEFB    $00,$01                   ;;(+00,+00)

; used 9 times
;                                                           80 00 00 00 00
stk_half:
        DEFB    $30                       ;;Exponent: $80, Bytes: 1
        DEFB    $00                       ;;(+00,+00,+00)

; used 4 times.
;                                                           81 49 0F DA A2
stk_pislash2:
        DEFB    $F1                       ;;Exponent: $81, Bytes: 4
        DEFB    $49,$0F,$DA,$A2           ;;

; used 3 times.
;                                                           00 00 0A 00 00
stk_ten:
        DEFB    $40                       ;;Bytes: 2
        DEFB    $B0                       ;;Exponent $00
        DEFB    $00,$0A                   ;;(+00,+00)


; ------------------
; Table of addresses
; ------------------
;
; starts with binary operations which have two operands and one result.
; three pseudo binary operations first.

tbl_addrs:
        DEFW    jump_true                 ; $00 Address: jump_true - jump-true
        DEFW    exchange                  ; $01 Address: exchange - exchange
        DEFW    delete                    ; $02 Address: delete - delete

; true binary operations.

        DEFW    subtract                  ; $03 Address: subtract - subtract
        DEFW    multiply                  ; $04 Address: multiply - multiply
        DEFW    division                  ; $05 Address: division - division
        DEFW    to_power                  ; $06 Address: to_power - to-power
        DEFW    or                        ; $07 Address: or - or

        DEFW    no_and_no                 ; $08 Address: no_and_no - no-&-no
        DEFW    no_l_eqlcomma             ; $09 Address: no_l_eqlcomma - no-l-eql
        DEFW    no_l_eqlcomma             ; $0A Address: no_l_eqlcomma - no-gr-eql
        DEFW    no_l_eqlcomma             ; $0B Address: no_l_eqlcomma - nos-neql
        DEFW    no_l_eqlcomma             ; $0C Address: no_l_eqlcomma - no-grtr
        DEFW    no_l_eqlcomma             ; $0D Address: no_l_eqlcomma - no-less
        DEFW    no_l_eqlcomma             ; $0E Address: no_l_eqlcomma - nos-eql
        DEFW    addition                  ; $0F Address: addition - addition

        DEFW    str_and_no                ; $10 Address: str_and_no - str-&-no
        DEFW    no_l_eqlcomma             ; $11 Address: no_l_eqlcomma - str-l-eql
        DEFW    no_l_eqlcomma             ; $12 Address: no_l_eqlcomma - str-gr-eql
        DEFW    no_l_eqlcomma             ; $13 Address: no_l_eqlcomma - strs-neql
        DEFW    no_l_eqlcomma             ; $14 Address: no_l_eqlcomma - str-grtr
        DEFW    no_l_eqlcomma             ; $15 Address: no_l_eqlcomma - str-less
        DEFW    no_l_eqlcomma             ; $16 Address: no_l_eqlcomma - strs-eql
        DEFW    strs_add                  ; $17 Address: strs_add - strs-add

; unary follow

        DEFW    valstring                 ; $18 Address: val - val$
        DEFW    usr_string                ; $19 Address: usr_string - usr-$
        DEFW    read_in                   ; $1A Address: read_in - read-in
        DEFW    negate                    ; $1B Address: negate - negate

        DEFW    code                      ; $1C Address: code - code
        DEFW    val                       ; $1D Address: val - val
        DEFW    len                       ; $1E Address: len - len
        DEFW    sin                       ; $1F Address: sin - sin
        DEFW    cos                       ; $20 Address: cos - cos
        DEFW    tan                       ; $21 Address: tan - tan
        DEFW    asn                       ; $22 Address: asn - asn
        DEFW    acs                       ; $23 Address: acs - acs
        DEFW    atn                       ; $24 Address: atn - atn
        DEFW    ln                        ; $25 Address: ln - ln
        DEFW    exp                       ; $26 Address: exp - exp
        DEFW    int                       ; $27 Address: int - int
        DEFW    sqr                       ; $28 Address: sqr - sqr
        DEFW    sgn                       ; $29 Address: sgn - sgn
        DEFW    abs                       ; $2A Address: abs - abs
        DEFW    peek                      ; $2B Address: peek - peek
        DEFW    in                        ; $2C Address: in - in
        DEFW    usr_no                    ; $2D Address: usr_no - usr-no
        DEFW    strstring                 ; $2E Address: strstring - str$
        DEFW    chrs                      ; $2F Address: chrs - chrs
        DEFW    not                       ; $30 Address: not - not

; end of true unary

        DEFW    duplicate                 ; $31 Address: duplicate - duplicate
        DEFW    n_mod_m                   ; $32 Address: n_mod_m - n-mod-m
        DEFW    jump                      ; $33 Address: jump - jump
        DEFW    stk_data                  ; $34 Address: stk_data - stk-data
        DEFW    dec_jr_nz                 ; $35 Address: dec_jr_nz - dec-jr-nz
        DEFW    less_0                    ; $36 Address: less_0 - less-0
        DEFW    greater_0                 ; $37 Address: greater_0 - greater-0
        DEFW    end_calc                  ; $38 Address: end_calc - end-calc
        DEFW    get_argt                  ; $39 Address: get_argt - get-argt
        DEFW    truncate                  ; $3A Address: truncate - truncate
        DEFW    fp_calc_2                 ; $3B Address: fp_calc_2 - fp-calc-2
        DEFW    e_to_fp                   ; $3C Address: e_to_fp - e-to-fp
        DEFW    re_stack                  ; $3D Address: re_stack - re-stack

; the following are just the next available slots for the 128 compound literals
; which are in range $80 - $FF.

        DEFW    series_xx                 ; $3E Address: series_xx - series-xx    $80 - $9F.
        DEFW    stk_const_xx              ; $3F Address: stk_const_xx - stk-const-xx $A0 - $BF.
        DEFW    st_mem_xx                 ; $40 Address: st_mem_xx - st-mem-xx    $C0 - $DF.
        DEFW    get_mem_xx                ; $41 Address: get_mem_xx - get-mem-xx   $E0 - $FF.

; Aside: 3E - 7F are therefore unused calculator literals.
;        3E - 7B would be available for expansion.

; --------------
; The Calculator
; --------------
;
;

calculate:
        CALL    stk_pntrs                 ; routine STK-PNTRS is called to set up the
                                          ; calculator stack pointers for a default
                                          ; unary operation. HL = last value on stack.
                                          ; DE = STKEND first location after stack.

; the calculate routine is called at this point by the series generator...

gen_ent_1:
        LD      A,B                       ; fetch the Z80 B register to A
        LD      (BREG),A                  ; and store value in system variable BREG.
                                          ; this will be the counter for dec-jr-nz
                                          ; or if used from fp-calc2 the calculator
                                          ; instruction.

; ... and again later at this point

gen_ent_2:
        EXX                               ; switch sets
        EX      (SP),HL                   ; and store the address of next instruction,
                                          ; the return address, in H'L'.
                                          ; If this is a recursive call the the H'L'
                                          ; of the previous invocation goes on stack.
                                          ; c.f. end-calc.
        EXX                               ; switch back to main set

; this is the re-entry looping point when handling a string of literals.

re_entry:
        LD      (STKEND),DE               ; save end of stack in system variable STKEND
        EXX                               ; switch to alt
        LD      A,(HL)                    ; get next literal
        INC     HL                        ; increase pointer'

; single operation jumps back to here

scan_ent:
        PUSH    HL                        ; save pointer on stack
        AND     A                         ; now test the literal
        JP      P,first_3d                ; forward to FIRST-3D if in range $00 - $3D
                                          ; anything with bit 7 set will be one of
                                          ; 128 compound literals.

; compound literals have the following format.
; bit 7 set indicates compound.
; bits 6-5 the subgroup 0-3.
; bits 4-0 the embedded parameter $00 - $1F.
; The subgroup 0-3 needs to be manipulated to form the next available four
; address places after the simple literals in the address table.

        LD      D,A                       ; save literal in D
        AND     $60                       ; and with 01100000 to isolate subgroup
        RRCA                              ; rotate bits
        RRCA                              ; 4 places to right
        RRCA                              ; not five as we need offset * 2
        RRCA                              ; 00000xx0
        ADD     A,$7C                     ; add ($3E * 2) to give correct offset.
                                          ; alter above if you add more literals.
        LD      L,A                       ; store in L for later indexing.
        LD      A,D                       ; bring back compound literal
        AND     $1F                       ; use mask to isolate parameter bits
        JR      ent_table                 ; forward to ENT-TABLE

; ---

; the branch was here with simple literals.

first_3d:
        CP      $18                       ; compare with first unary operations.
        JR      NC,double_a               ; to DOUBLE-A with unary operations

; it is binary so adjust pointers.

        EXX                               ;
        LD      BC,-5                     ; the value -5
        LD      D,H                       ; transfer HL, the last value, to DE.
        LD      E,L                       ;
        ADD     HL,BC                     ; subtract 5 making HL point to second
                                          ; value.
        EXX                               ;

double_a:
        RLCA                              ; double the literal
        LD      L,A                       ; and store in L for indexing

ent_table:
        LD      DE,tbl_addrs              ; Address: tbl-addrs
        LD      H,$00                     ; prepare to index
        ADD     HL,DE                     ; add to get address of routine
        LD      E,(HL)                    ; low byte to E
        INC     HL                        ;
        LD      D,(HL)                    ; high byte to D
        LD      HL,re_entry               ; Address: RE-ENTRY
        EX      (SP),HL                   ; goes to stack
        PUSH    DE                        ; now address of routine
        EXX                               ; main set
                                          ; avoid using IY register.
        LD      BC,(STKEND_hi)            ; STKEND_hi
                                          ; nothing much goes to C but BREG to B
                                          ; and continue into next ret instruction
                                          ; which has a dual identity


; ------------------
; Handle delete (02)
; ------------------
; A simple return but when used as a calculator literal this
; deletes the last value from the calculator stack.
; On entry, as always with binary operations,
; HL=first number, DE=second number
; On exit, HL=result, DE=stkend.
; So nothing to do

delete:
        RET                               ; return - indirect jump if from above.

; ---------------------
; Single operation (3B)
; ---------------------
; this single operation is used, in the first instance, to evaluate most
; of the mathematical and string functions found in BASIC expressions.

fp_calc_2:
        POP     AF                        ; drop return address.
        LD      A,(BREG)                  ; load accumulator from system variable BREG
                                          ; value will be literal eg. 'tan'
        EXX                               ; switch to alt
        JR      scan_ent                  ; back to SCAN-ENT
                                          ; next literal will be end-calc at 0x2758

; ----------------
; Test five-spaces
; ----------------
; This routine is called from MOVE-FP, STK-CONST and STK-STORE to
; test that there is enough space between the calculator stack and the
; machine stack for another five-byte value. It returns with BC holding
; the value 5 ready for any subsequent LDIR.

test_5_sp:
        PUSH    DE                        ; save
        PUSH    HL                        ; registers
        LD      BC,$0005                  ; an overhead of five bytes
        CALL    test_room                 ; routine TEST-ROOM tests free RAM raising
                                          ; an error if not.
        POP     HL                        ; else restore
        POP     DE                        ; registers.
        RET                               ; return with BC set at 5.

; ------------
; Stack number
; ------------
; This routine is called to stack a hidden floating point number found in
; a BASIC line. It is also called to stack a numeric variable value, and
; from BEEP, to stack an entry in the semi-tone table. It is not part of the
; calculator suite of routines.
; On entry HL points to the number to be stacked.

stack_num:
        LD      DE,(STKEND)               ; load destination from STKEND system variable.
        CALL    move_fp                   ; routine MOVE-FP puts on calculator stack
                                          ; with a memory check.
        LD      (STKEND),DE               ; set STKEND to next free location.
        RET                               ; return.

; ---------------------------------
; Move a floating point number (31)
; ---------------------------------
; This simple routine is a 5-byte LDIR instruction
; that incorporates a memory check.
; When used as a calculator literal it duplicates the last value on the
; calculator stack.
; Unary so on entry HL points to last value, DE to stkend

duplicate:
move_fp:
        CALL    test_5_sp                 ; routine TEST-5-SP test free memory
                                          ; and sets BC to 5.
        LDIR                              ; copy the five bytes.
        RET                               ; return with DE addressing new STKEND
                                          ; and HL addressing new last value.

; -------------------
; Stack literals ($34)
; -------------------
; When a calculator subroutine needs to put a value on the calculator
; stack that is not a regular constant this routine is called with a
; variable number of following data bytes that convey to the routine
; the integer or floating point form as succinctly as is possible.

stk_data:
        LD      H,D                       ; transfer STKEND
        LD      L,E                       ; to HL for result.

stk_const:
        CALL    test_5_sp                 ; routine TEST-5-SP tests that room exists
                                          ; and sets BC to $05.

        EXX                               ; switch to alternate set
        PUSH    HL                        ; save the pointer to next literal on stack
        EXX                               ; switch back to main set

        EX      (SP),HL                   ; pointer to HL, destination to stack.

        PUSH    BC                        ; save BC - value 5 from test room ??.

        LD      A,(HL)                    ; fetch the byte following 'stk-data'
        AND     $C0                       ; isolate bits 7 and 6
        RLCA                              ; rotate
        RLCA                              ; to bits 1 and 0  range $00 - $03.
        LD      C,A                       ; transfer to C
        INC     C                         ; and increment to give number of bytes
                                          ; to read. $01 - $04
        LD      A,(HL)                    ; reload the first byte
        AND     $3F                       ; mask off to give possible exponent.
        JR      NZ,form_exp               ; forward to FORM-EXP if it was possible to
                                          ; include the exponent.

; else byte is just a byte count and exponent comes next.

        INC     HL                        ; address next byte and
        LD      A,(HL)                    ; pick up the exponent ( - $50).

form_exp:
        ADD     A,$50                     ; now add $50 to form actual exponent
        LD      (DE),A                    ; and load into first destination byte.
        LD      A,$05                     ; load accumulator with $05 and
        SUB     C                         ; subtract C to give count of trailing
                                          ; zeros plus one.
        INC     HL                        ; increment source
        INC     DE                        ; increment destination
        LD      B,$00                     ; prepare to copy
        LDIR                              ; copy C bytes

        POP     BC                        ; restore 5 counter to BC ??.

        EX      (SP),HL                   ; put HL on stack as next literal pointer
                                          ; and the stack value - result pointer -
                                          ; to HL.

        EXX                               ; switch to alternate set.
        POP     HL                        ; restore next literal pointer from stack
                                          ; to H'L'.
        EXX                               ; switch back to main set.

        LD      B,A                       ; zero count to B
        XOR     A                         ; clear accumulator

stk_zeros:
        DEC     B                         ; decrement B counter
        RET     Z                         ; return if zero.          >>
                                          ; DE points to new STKEND
                                          ; HL to new number.

        LD      (DE),A                    ; else load zero to destination
        INC     DE                        ; increase destination
        JR      stk_zeros                 ; loop back to STK-ZEROS until done.

; -------------------------------
; THE 'SKIP CONSTANTS' SUBROUTINE
; -------------------------------
; This routine traverses variable-length entries in the table of constants,
; stacking intermediate, unwanted constants onto a dummy calculator stack,
; in the first five bytes of ROM. The destination DE normally points to the
; end of the calculator stack which might be in the normal place or in the
; system variables area during E-LINE-NO; INT-TO-FP; stk-ten. In any case,
; it would be simpler all round if the routine just shoved unwanted values
; where it is going to stick the wanted value.
; The instruction LD DE, $0000 can be removed.

skip_cons:
        AND     A                         ; test if initially zero.

skip_next:
        RET     Z                         ; return if zero.          >>

        PUSH    AF                        ; save count.
        PUSH    DE                        ; and normal STKEND

        LD      DE,$0000                  ; dummy value for STKEND at start of ROM
                                          ; Note. not a fault but this has to be
                                          ; moved elsewhere when running in RAM.
                                          ; e.g. with Expandor Systems 'Soft ROM'.
                                          ; Better still, write to the normal place.
        CALL    stk_const                 ; routine STK-CONST works through variable
                                          ; length records.

        POP     DE                        ; restore real STKEND
        POP     AF                        ; restore count
        DEC     A                         ; decrease
        JR      skip_next                 ; loop back to SKIP-NEXT

; ---------------
; Memory location
; ---------------
; This routine, when supplied with a base address in HL and an index in A
; will calculate the address of the A'th entry, where each entry occupies
; five bytes. It is used for reading the semi-tone table and addressing
; floating-point numbers in the calculator's memory area.

loc_mem:
        LD      C,A                       ; store the original number $00-$1F.
        RLCA                              ; double.
        RLCA                              ; quadruple.
        ADD     A,C                       ; now add original to multiply by five.

        LD      C,A                       ; place the result in C.
        LD      B,$00                     ; set B to 0.
        ADD     HL,BC                     ; add to form address of start of number in HL.
        RET                               ; return.

; ------------------------------
; Get from memory area ($E0 etc.)
; ------------------------------
; Literals $E0 to $FF
; A holds $00-$1F offset.
; The calculator stack increases by 5 bytes.

get_mem_xx:
        PUSH    DE                        ; save STKEND
        LD      HL,(MEM)                  ; MEM is base address of the memory cells.
        CALL    loc_mem                   ; routine LOC-MEM so that HL = first byte
        CALL    move_fp                   ; routine MOVE-FP moves 5 bytes with memory
                                          ; check.
                                          ; DE now points to new STKEND.
        POP     HL                        ; original STKEND is now RESULT pointer.
        RET                               ; return.

; --------------------------
; Stack a constant (A0 etc.)
; --------------------------
; This routine allows a one-byte instruction to stack up to 32 constants
; held in short form in a table of constants. In fact only 5 constants are
; required. On entry the A register holds the literal ANDed with 1F.
; It isn't very efficient and it would have been better to hold the
; numbers in full, five byte form and stack them in a similar manner
; to that used for semi-tone table values.

stk_const_xx:
        LD      H,D                       ; save STKEND - required for result
        LD      L,E                       ;
        EXX                               ; swap
        PUSH    HL                        ; save pointer to next literal
        LD      HL,stk_zero               ; Address: stk-zero - start of table of
                                          ; constants
        EXX                               ;
        CALL    skip_cons                 ; routine SKIP-CONS
        CALL    stk_const                 ; routine STK-CONST
        EXX                               ;
        POP     HL                        ; restore pointer to next literal.
        EXX                               ;
        RET                               ; return.

; --------------------------------
; Store in a memory area ($C0 etc.)
; --------------------------------
; Offsets $C0 to $DF
; Although 32 memory storage locations can be addressed, only six
; $C0 to $C5 are required by the ROM and only the thirty bytes (6*5)
; required for these are allocated. Spectrum programmers who wish to
; use the floating point routines from assembly language may wish to
; alter the system variable MEM to point to 160 bytes of RAM to have
; use the full range available.
; A holds the derived offset $00-$1F.
; This is a unary operation, so on entry HL points to the last value and DE
; points to STKEND.

st_mem_xx:
        PUSH    HL                        ; save the result pointer.
        EX      DE,HL                     ; transfer to DE.
        LD      HL,(MEM)                  ; fetch MEM the base of memory area.
        CALL    loc_mem                   ; routine LOC-MEM sets HL to the destination.
        EX      DE,HL                     ; swap - HL is start, DE is destination.
        CALL    move_fp                   ; routine MOVE-FP.
                                          ; note. a short ld bc,5; ldir
                                          ; the embedded memory check is not required
                                          ; so these instructions would be faster.
        EX      DE,HL                     ; DE = STKEND
        POP     HL                        ; restore original result pointer
        RET                               ; return.

; ------------------------------------
; Swap first number with second number
; ------------------------------------
; This routine exchanges the last two values on the calculator stack
; On entry, as always with binary operations,
; HL=first number, DE=second number
; On exit, HL=result, DE=stkend.

exchange:
        LD      B,$05                     ; there are five bytes to be swapped

; start of loop.

swap_byte:
        LD      A,(DE)                    ; each byte of second
        LD      C,(HL)                    ; each byte of first
        EX      DE,HL                     ; swap pointers
        LD      (DE),A                    ; store each byte of first
        LD      (HL),C                    ; store each byte of second
        INC     HL                        ; advance both
        INC     DE                        ; pointers.
        DJNZ    swap_byte                 ; loop back to SWAP-BYTE until all 5 done.

        EX      DE,HL                     ; even up the exchanges
                                          ; so that DE addresses STKEND.
        RET                               ; return.

; --------------------------
; Series generator (86 etc.)
; --------------------------
; The Spectrum uses Chebyshev polynomials to generate approximations for
; SIN, ATN, LN and EXP. These are named after the Russian mathematician
; Pafnuty Chebyshev, born in 1821, who did much pioneering work on numerical
; series. As far as calculators are concerned, Chebyshev polynomials have an
; advantage over other series, for example the Taylor series, as they can
; reach an approximation in just six iterations for SIN, eight for EXP and
; twelve for LN and ATN. The mechanics of the routine are interesting but
; for full treatment of how these are generated with demonstrations in
; Sinclair BASIC see "The Complete Spectrum ROM Disassembly" by Dr Ian Logan
; and Dr Frank O'Hara, published 1983 by Melbourne House.

series_xx:
        LD      B,A                       ; parameter $00 - $1F to B counter
        CALL    gen_ent_1                 ; routine GEN-ENT-1 is called.
                                          ; A recursive call to a special entry point
                                          ; in the calculator that puts the B register
                                          ; in the system variable BREG. The return
                                          ; address is the next location and where
                                          ; the calculator will expect its first
                                          ; instruction - now pointed to by HL'.
                                          ; The previous pointer to the series of
                                          ; five-byte numbers goes on the machine stack.

; The initialization phase.

        DEFB    $31                       ;;duplicate       x,x
        DEFB    $0F                       ;;addition        x+x
        DEFB    $C0                       ;;st-mem-0        x+x
        DEFB    $02                       ;;delete          .
        DEFB    $A0                       ;;stk-zero        0
        DEFB    $C2                       ;;st-mem-2        0

; a loop is now entered to perform the algebraic calculation for each of
; the numbers in the series

g_loop:
        DEFB    $31                       ;;duplicate       v,v.
        DEFB    $E0                       ;;get-mem-0       v,v,x+2
        DEFB    $04                       ;;multiply        v,v*x+2
        DEFB    $E2                       ;;get-mem-2       v,v*x+2,v
        DEFB    $C1                       ;;st-mem-1
        DEFB    $03                       ;;subtract
        DEFB    $38                       ;;end-calc

; the previous pointer is fetched from the machine stack to H'L' where it
; addresses one of the numbers of the series following the series literal.

        CALL    stk_data                  ; routine STK-DATA is called directly to
                                          ; push a value and advance H'L'.
        CALL    gen_ent_2                 ; routine GEN-ENT-2 recursively re-enters
                                          ; the calculator without disturbing
                                          ; system variable BREG
                                          ; H'L' value goes on the machine stack and is
                                          ; then loaded as usual with the next address.

        DEFB    $0F                       ;;addition
        DEFB    $01                       ;;exchange
        DEFB    $C2                       ;;st-mem-2
        DEFB    $02                       ;;delete

        DEFB    $35                       ;;dec-jr-nz
        DEFB    $EE                       ;;back to g_loop, G-LOOP

; when the counted loop is complete the final subtraction yields the result
; for example SIN X.

        DEFB    $E1                       ;;get-mem-1
        DEFB    $03                       ;;subtract
        DEFB    $38                       ;;end-calc

        RET                               ; return with H'L' pointing to location
                                          ; after last number in series.

; -----------------------
; Absolute magnitude (2A)
; -----------------------
; This calculator literal finds the absolute value of the last value,
; integer or floating point, on calculator stack.

abs:
        LD      B,$FF                     ; signal abs
        JR      neg_test                  ; forward to NEG-TEST

; -----------------------
; Handle unary minus (1B)
; -----------------------
; Unary so on entry HL points to last value, DE to STKEND.

negate:
negate:
        CALL    test_zero                 ; call routine TEST-ZERO and
        RET     C                         ; return if so leaving zero unchanged.

        LD      B,$00                     ; signal negate required before joining
                                          ; common code.

neg_test:
        LD      A,(HL)                    ; load first byte and
        AND     A                         ; test for zero
        JR      Z,int_case                ; forward to INT-CASE if a small integer

; for floating point numbers a single bit denotes the sign.

        INC     HL                        ; address the first byte of mantissa.
        LD      A,B                       ; action flag $FF=abs, $00=neg.
        AND     $80                       ; now         $80      $00
        OR      (HL)                      ; sets bit 7 for abs
        RLA                               ; sets carry for abs and if number negative
        CCF                               ; complement carry flag
        RRA                               ; and rotate back in altering sign
        LD      (HL),A                    ; put the altered adjusted number back
        DEC     HL                        ; HL points to result
        RET                               ; return with DE unchanged

; ---

; for integer numbers an entire byte denotes the sign.

int_case:
        PUSH    DE                        ; save STKEND.

        PUSH    HL                        ; save pointer to the last value/result.

        CALL    int_fetch                 ; routine INT-FETCH puts integer in DE
                                          ; and the sign in C.

        POP     HL                        ; restore the result pointer.

        LD      A,B                       ; $FF=abs, $00=neg
        OR      C                         ; $FF for abs, no change neg
        CPL                               ; $00 for abs, switched for neg
        LD      C,A                       ; transfer result to sign byte.

        CALL    int_store                 ; routine INT-STORE to re-write the integer.

        POP     DE                        ; restore STKEND.
        RET                               ; return.

; -----------
; Signum (29)
; -----------
; This routine replaces the last value on the calculator stack,
; which may be in floating point or integer form, with the integer values
; zero if zero, with one if positive and  with -minus one if negative.

sgn:
        CALL    test_zero                 ; call routine TEST-ZERO and
        RET     C                         ; exit if so as no change is required.

        PUSH    DE                        ; save pointer to STKEND.

        LD      DE,$0001                  ; the result will be 1.
        INC     HL                        ; skip over the exponent.
        RL      (HL)                      ; rotate the sign bit into the carry flag.
        DEC     HL                        ; step back to point to the result.
        SBC     A,A                       ; byte will be $FF if negative, $00 if positive.
        LD      C,A                       ; store the sign byte in the C register.
        CALL    int_store                 ; routine INT-STORE to overwrite the last
                                          ; value with 0001 and sign.

        POP     DE                        ; restore STKEND.
        RET                               ; return.

; -----------------------
; Handle IN function (2C)
; -----------------------
; This function reads a byte from an input port.

in:
        CALL    find_int2                 ; routine FIND-INT2 puts port address in BC.
                                          ; all 16 bits are put on the address line.
        IN      A,(C)                     ; read the port.

        JR      in_pk_stk                 ; exit to STACK-A (via IN-PK-STK to save a byte
                                          ; of instruction code).

; -------------------------
; Handle PEEK function (2B)
; -------------------------
; This function returns the contents of a memory address.
; The entire address space can be peeked including the ROM.

peek:
        CALL    find_int2                 ; routine FIND-INT2 puts address in BC.
        LD      A,(BC)                    ; load contents into A register.

in_pk_stk:
        JP      stack_a                   ; exit via STACK-A to put value on the
                                          ; calculator stack.

; ---------------
; USR number (2D)
; ---------------
; The USR function followed by a number 0-65535 is the method by which
; the Spectrum invokes machine code programs. This function returns the
; contents of the BC register pair.
; Note. that STACK-BC re-initializes the IY register if a user-written
; program has altered it.

usr_no:
        CALL    find_int2                 ; routine FIND-INT2 to fetch the
                                          ; supplied address into BC.

        LD      HL,stack_bc               ; address: STACK-BC is
        PUSH    HL                        ; pushed onto the machine stack.
        PUSH    BC                        ; then the address of the machine code
                                          ; routine.

        RET                               ; make an indirect jump to the routine
                                          ; and, hopefully, to STACK-BC also.

; ---------------
; USR string (19)
; ---------------
; The user function with a one-character string argument, calculates the
; address of the User Defined Graphic character that is in the string.
; As an alternative, the ASCII equivalent, upper or lower case,
; may be supplied. This provides a user-friendly method of redefining
; the 21 User Definable Graphics e.g.
; POKE USR "a", BIN 10000000 will put a dot in the top left corner of the
; character 144.
; Note. the curious double check on the range. With 26 UDGs the first check
; only is necessary. With anything less the second check only is required.
; It is highly likely that the first check was written by Steven Vickers.

usr_string:
        CALL    stk_fetch                 ; routine STK-FETCH fetches the string
                                          ; parameters.
        DEC     BC                        ; decrease BC by
        LD      A,B                       ; one to test
        OR      C                         ; the length.
        JR      NZ,report_a               ; to REPORT-A if not a single character.

        LD      A,(DE)                    ; fetch the character
        CALL    alpha                     ; routine ALPHA sets carry if 'A-Z' or 'a-z'.
        JR      C,usr_range               ; forward to USR-RANGE if ASCII.

        SUB     $90                       ; make udgs range 0-20d
        JR      C,report_a                ; to REPORT-A if too low. e.g. usr " ".

        CP      $15                       ; Note. this test is not necessary.
        JR      NC,report_a               ; to REPORT-A if higher than 20.

        INC     A                         ; make range 1-21d to match LSBs of ASCII

usr_range:
        DEC     A                         ; make range of bits 0-4 start at zero
        ADD     A,A                       ; multiply by eight
        ADD     A,A                       ; and lose any set bits
        ADD     A,A                       ; range now 0 - 25*8
        CP      $A8                       ; compare to 21*8
        JR      NC,report_a               ; to REPORT-A if originally higher
                                          ; than 'U','u' or graphics U.

        LD      BC,(UDG)                  ; fetch the UDG system variable value.
        ADD     A,C                       ; add the offset to character
        LD      C,A                       ; and store back in register C.
        JR      NC,usr_stack              ; forward to USR-STACK if no overflow.

        INC     B                         ; increment high byte.

usr_stack:
        JP      stack_bc                  ; jump back and exit via STACK-BC to store

; ---

report_a:
        RST     08H                       ; ERROR-1
        DEFB    $09                       ; Error Report: Invalid argument

; -------------
; Test for zero
; -------------
; Test if top value on calculator stack is zero.
; The carry flag is set if the last value is zero but no registers are altered.
; All five bytes will be zero but first four only need be tested.
; On entry HL points to the exponent the first byte of the value.

test_zero:
        PUSH    HL                        ; preserve HL which is used to address.
        PUSH    BC                        ; preserve BC which is used as a store.
        LD      B,A                       ; preserve A in B.

        LD      A,(HL)                    ; load first byte to accumulator
        INC     HL                        ; advance.
        OR      (HL)                      ; OR with second byte and clear carry.
        INC     HL                        ; advance.
        OR      (HL)                      ; OR with third byte.
        INC     HL                        ; advance.
        OR      (HL)                      ; OR with fourth byte.

        LD      A,B                       ; restore A without affecting flags.
        POP     BC                        ; restore the saved
        POP     HL                        ; registers.

        RET     NZ                        ; return if not zero and with carry reset.

        SCF                               ; set the carry flag.
        RET                               ; return with carry set if zero.

; -----------------------
; Greater than zero ($37)
; -----------------------
; Test if the last value on the calculator stack is greater than zero.
; This routine is also called directly from the end-tests of the comparison
; routine.

greater_0:
greater_0:
        CALL    test_zero                 ; routine TEST-ZERO
        RET     C                         ; return if was zero as this
                                          ; is also the Boolean 'false' value.

        LD      A,$FF                     ; prepare XOR mask for sign bit
        JR      sign_to_c                 ; forward to SIGN-TO-C
                                          ; to put sign in carry
                                          ; (carry will become set if sign is positive)
                                          ; and then overwrite location with 1 or 0
                                          ; as appropriate.

; ------------------------
; Handle NOT operator ($30)
; ------------------------
; This overwrites the last value with 1 if it was zero else with zero
; if it was any other value.
;
; e.g NOT 0 returns 1, NOT 1 returns 0, NOT -3 returns 0.
;
; The subroutine is also called directly from the end-tests of the comparison
; operator.

not:
not:
        CALL    test_zero                 ; routine TEST-ZERO sets carry if zero

        JR      fp_0slash1                ; to FP-0/1 to overwrite operand with
                                          ; 1 if carry is set else to overwrite with zero.

; -------------------
; Less than zero (36)
; -------------------
; Destructively test if last value on calculator stack is less than zero.
; Bit 7 of second byte will be set if so.

less_0:
        XOR     A                         ; set xor mask to zero
                                          ; (carry will become set if sign is negative).

; transfer sign of mantissa to Carry Flag.

sign_to_c:
        INC     HL                        ; address 2nd byte.
        XOR     (HL)                      ; bit 7 of HL will be set if number is negative.
        DEC     HL                        ; address 1st byte again.
        RLCA                              ; rotate bit 7 of A to carry.

; -----------
; Zero or one
; -----------
; This routine places an integer value of zero or one at the addressed location
; of the calculator stack or MEM area.  The value one is written if carry is
; set on entry else zero.

fp_0slash1:
        PUSH    HL                        ; save pointer to the first byte
        LD      A,$00                     ; load accumulator with zero - without
                                          ; disturbing flags.
        LD      (HL),A                    ; zero to first byte
        INC     HL                        ; address next
        LD      (HL),A                    ; zero to 2nd byte
        INC     HL                        ; address low byte of integer
        RLA                               ; carry to bit 0 of A
        LD      (HL),A                    ; load one or zero to low byte.
        RRA                               ; restore zero to accumulator.
        INC     HL                        ; address high byte of integer.
        LD      (HL),A                    ; put a zero there.
        INC     HL                        ; address fifth byte.
        LD      (HL),A                    ; put a zero there.
        POP     HL                        ; restore pointer to the first byte.
        RET                               ; return.

; -----------------------
; Handle OR operator (07)
; -----------------------
; The Boolean OR operator. eg. X OR Y
; The result is zero if both values are zero else a non-zero value.
;
; e.g.    0 OR 0  returns 0.
;        -3 OR 0  returns -3.
;         0 OR -3 returns 1.
;        -3 OR 2  returns 1.
;
; A binary operation.
; On entry HL points to first operand (X) and DE to second operand (Y).

or:
        EX      DE,HL                     ; make HL point to second number
        CALL    test_zero                 ; routine TEST-ZERO
        EX      DE,HL                     ; restore pointers
        RET     C                         ; return if result was zero - first operand,
                                          ; now the last value, is the result.

        SCF                               ; set carry flag
        JR      fp_0slash1                ; back to FP-0/1 to overwrite the first operand
                                          ; with the value 1.


; -----------------------------
; Handle number AND number (08)
; -----------------------------
; The Boolean AND operator.
;
; e.g.    -3 AND 2  returns -3.
;         -3 AND 0  returns 0.
;          0 and -2 returns 0.
;          0 and 0  returns 0.
;
; Compare with OR routine above.

no_and_no:
        EX      DE,HL                     ; make HL address second operand.

        CALL    test_zero                 ; routine TEST-ZERO sets carry if zero.

        EX      DE,HL                     ; restore pointers.
        RET     NC                        ; return if second non-zero, first is result.

;

        AND     A                         ; else clear carry.
        JR      fp_0slash1                ; back to FP-0/1 to overwrite first operand
                                          ; with zero for return value.

; -----------------------------
; Handle string AND number (10)
; -----------------------------
; e.g. "You Win" AND score>99 will return the string if condition is true
; or the null string if false.

str_and_no:
        EX      DE,HL                     ; make HL point to the number.
        CALL    test_zero                 ; routine TEST-ZERO.
        EX      DE,HL                     ; restore pointers.
        RET     NC                        ; return if number was not zero - the string
                                          ; is the result.

; if the number was zero (false) then the null string must be returned by
; altering the length of the string on the calculator stack to zero.

        PUSH    DE                        ; save pointer to the now obsolete number
                                          ; (which will become the new STKEND)

        DEC     DE                        ; point to the 5th byte of string descriptor.
        XOR     A                         ; clear the accumulator.
        LD      (DE),A                    ; place zero in high byte of length.
        DEC     DE                        ; address low byte of length.
        LD      (DE),A                    ; place zero there - now the null string.

        POP     DE                        ; restore pointer - new STKEND.
        RET                               ; return.

; -----------------------------------
; Perform comparison ($09-$0E, $11-$16)
; -----------------------------------
; True binary operations.
;
; A single entry point is used to evaluate six numeric and six string
; comparisons. On entry, the calculator literal is in the B register and
; the two numeric values, or the two string parameters, are on the
; calculator stack.
; The individual bits of the literal are manipulated to group similar
; operations although the SUB 8 instruction does nothing useful and merely
; alters the string test bit.
; Numbers are compared by subtracting one from the other, strings are
; compared by comparing every character until a mismatch, or the end of one
; or both, is reached.
;
; Numeric Comparisons.
; --------------------
; The 'x>y' example is the easiest as it employs straight-thru logic.
; Number y is subtracted from x and the result tested for greater-0 yielding
; a final value 1 (true) or 0 (false).
; For 'x<y' the same logic is used but the two values are first swapped on the
; calculator stack.
; For 'x=y' NOT is applied to the subtraction result yielding true if the
; difference was zero and false with anything else.
; The first three numeric comparisons are just the opposite of the last three
; so the same processing steps are used and then a final NOT is applied.
;
; literal    Test   No  sub 8       ExOrNot  1st RRCA  exch sub  ?   End-Tests
; =========  ====   == ======== === ======== ========  ==== ===  =  === === ===
; no-l-eql   x<=y   09 00000001 dec 00000000 00000000  ---- x-y  ?  --- >0? NOT
; no-gr-eql  x>=y   0A 00000010 dec 00000001 10000000c swap y-x  ?  --- >0? NOT
; nos-neql   x<>y   0B 00000011 dec 00000010 00000001  ---- x-y  ?  NOT --- NOT
; no-grtr    x>y    0C 00000100  -  00000100 00000010  ---- x-y  ?  --- >0? ---
; no-less    x<y    0D 00000101  -  00000101 10000010c swap y-x  ?  --- >0? ---
; nos-eql    x=y    0E 00000110  -  00000110 00000011  ---- x-y  ?  NOT --- ---
;
;                                                           comp -> C/F
;                                                           ====    ===
; str-l-eql  x$<=y$ 11 00001001 dec 00001000 00000100  ---- x$y$ 0  !or >0? NOT
; str-gr-eql x$>=y$ 12 00001010 dec 00001001 10000100c swap y$x$ 0  !or >0? NOT
; strs-neql  x$<>y$ 13 00001011 dec 00001010 00000101  ---- x$y$ 0  !or >0? NOT
; str-grtr   x$>y$  14 00001100  -  00001100 00000110  ---- x$y$ 0  !or >0? ---
; str-less   x$<y$  15 00001101  -  00001101 10000110c swap y$x$ 0  !or >0? ---
; strs-eql   x$=y$  16 00001110  -  00001110 00000111  ---- x$y$ 0  !or >0? ---
;
; String comparisons are a little different in that the eql/neql carry flag
; from the 2nd RRCA is, as before, fed into the first of the end tests but
; along the way it gets modified by the comparison process. The result on the
; stack always starts off as zero and the carry fed in determines if NOT is
; applied to it. So the only time the greater-0 test is applied is if the
; stack holds zero which is not very efficient as the test will always yield
; zero. The most likely explanation is that there were once separate end tests
; for numbers and strings.

;            etc.
no_l_eqlcomma:
        LD      A,B                       ; transfer literal to accumulator.
        SUB     $08                       ; subtract eight - which is not useful.

        BIT     2,A                       ; isolate '>', '<', '='.

        JR      NZ,ex_or_not              ; skip to EX-OR-NOT with these.

        DEC     A                         ; else make $00-$02, $08-$0A to match bits 0-2.

ex_or_not:
        RRCA                              ; the first RRCA sets carry for a swap.
        JR      NC,nu_or_str              ; forward to NU-OR-STR with other 8 cases

; for the other 4 cases the two values on the calculator stack are exchanged.

        PUSH    AF                        ; save A and carry.
        PUSH    HL                        ; save HL - pointer to first operand.
                                          ; (DE points to second operand).

        CALL    exchange                  ; routine exchange swaps the two values.
                                          ; (HL = second operand, DE = STKEND)

        POP     DE                        ; DE = first operand
        EX      DE,HL                     ; as we were.
        POP     AF                        ; restore A and carry.

; Note. it would be better if the 2nd RRCA preceded the string test.
; It would save two duplicate bytes and if we also got rid of that sub 8
; at the beginning we wouldn't have to alter which bit we test.

nu_or_str:
        BIT     2,A                       ; test if a string comparison.
        JR      NZ,strings                ; forward to STRINGS if so.

; continue with numeric comparisons.

        RRCA                              ; 2nd RRCA causes eql/neql to set carry.
        PUSH    AF                        ; save A and carry

        CALL    subtract                  ; routine subtract leaves result on stack.
        JR      end_tests                 ; forward to END-TESTS

; ---

strings:
        RRCA                              ; 2nd RRCA causes eql/neql to set carry.
        PUSH    AF                        ; save A and carry.

        CALL    stk_fetch                 ; routine STK-FETCH gets 2nd string params
        PUSH    DE                        ; save start2 *.
        PUSH    BC                        ; and the length.

        CALL    stk_fetch                 ; routine STK-FETCH gets 1st string
                                          ; parameters - start in DE, length in BC.
        POP     HL                        ; restore length of second to HL.

; A loop is now entered to compare, by subtraction, each corresponding character
; of the strings. For each successful match, the pointers are incremented and
; the lengths decreased and the branch taken back to here. If both string
; remainders become null at the same time, then an exact match exists.

byte_comp:
        LD      A,H                       ; test if the second string
        OR      L                         ; is the null string and hold flags.

        EX      (SP),HL                   ; put length2 on stack, bring start2 to HL *.
        LD      A,B                       ; hi byte of length1 to A

        JR      NZ,sec_plus               ; forward to SEC-PLUS if second not null.

        OR      C                         ; test length of first string.

secnd_low:
        POP     BC                        ; pop the second length off stack.
        JR      Z,both_null               ; forward to BOTH-NULL if first string is also
                                          ; of zero length.

; the true condition - first is longer than second (SECND-LESS)

        POP     AF                        ; restore carry (set if eql/neql)
        CCF                               ; complement carry flag.
                                          ; Note. equality becomes false.
                                          ; Inequality is true. By swapping or applying
                                          ; a terminal 'not', all comparisons have been
                                          ; manipulated so that this is success path.
        JR      str_test                  ; forward to leave via STR-TEST

; ---
; the branch was here with a match

both_null:
        POP     AF                        ; restore carry - set for eql/neql
        JR      str_test                  ; forward to STR-TEST

; ---
; the branch was here when 2nd string not null and low byte of first is yet
; to be tested.


sec_plus:
        OR      C                         ; test the length of first string.
        JR      Z,frst_less               ; forward to FRST-LESS if length is zero.

; both strings have at least one character left.

        LD      A,(DE)                    ; fetch character of first string.
        SUB     (HL)                      ; subtract with that of 2nd string.
        JR      C,frst_less               ; forward to FRST-LESS if carry set

        JR      NZ,secnd_low              ; back to SECND-LOW and then STR-TEST
                                          ; if not exact match.

        DEC     BC                        ; decrease length of 1st string.
        INC     DE                        ; increment 1st string pointer.

        INC     HL                        ; increment 2nd string pointer.
        EX      (SP),HL                   ; swap with length on stack
        DEC     HL                        ; decrement 2nd string length
        JR      byte_comp                 ; back to BYTE-COMP

; ---
; the false condition.

frst_less:
        POP     BC                        ; discard length
        POP     AF                        ; pop A
        AND     A                         ; clear the carry for false result.

; ---
; exact match and x$>y$ rejoin here

str_test:
        PUSH    AF                        ; save A and carry

        RST     28H                       ;; FP-CALC
        DEFB    $A0                       ;;stk-zero      an initial false value.
        DEFB    $38                       ;;end-calc

; both numeric and string paths converge here.

end_tests:
        POP     AF                        ; pop carry  - will be set if eql/neql
        PUSH    AF                        ; save it again.

        CALL    C,not                     ; routine NOT sets true(1) if equal(0)
                                          ; or, for strings, applies true result.

        POP     AF                        ; pop carry and
        PUSH    AF                        ; save A

        CALL    NC,greater_0              ; routine GREATER-0 tests numeric subtraction
                                          ; result but also needlessly tests the string
                                          ; value for zero - it must be.

        POP     AF                        ; pop A
        RRCA                              ; the third RRCA - test for '<=', '>=' or '<>'.
        CALL    NC,not                    ; apply a terminal NOT if so.
        RET                               ; return.

; -------------------------
; String concatenation ($17)
; -------------------------
; This literal combines two strings into one e.g. LET a$ = b$ + c$
; The two parameters of the two strings to be combined are on the stack.

strs_add:
        CALL    stk_fetch                 ; routine STK-FETCH fetches string parameters
                                          ; and deletes calculator stack entry.
        PUSH    DE                        ; save start address.
        PUSH    BC                        ; and length.

        CALL    stk_fetch                 ; routine STK-FETCH for first string
        POP     HL                        ; re-fetch first length
        PUSH    HL                        ; and save again
        PUSH    DE                        ; save start of second string
        PUSH    BC                        ; and its length.

        ADD     HL,BC                     ; add the two lengths.
        LD      B,H                       ; transfer to BC
        LD      C,L                       ; and create
        RST     30H                       ; BC-SPACES in workspace.
                                          ; DE points to start of space.

        CALL    stk_sto_string            ; routine STK-STO-$ stores parameters
                                          ; of new string updating STKEND.

        POP     BC                        ; length of first
        POP     HL                        ; address of start
        LD      A,B                       ; test for
        OR      C                         ; zero length.
        JR      Z,other_str               ; to OTHER-STR if null string

        LDIR                              ; copy string to workspace.

other_str:
        POP     BC                        ; now second length
        POP     HL                        ; and start of string
        LD      A,B                       ; test this one
        OR      C                         ; for zero length
        JR      Z,stk_pntrs               ; skip forward to STK-PNTRS if so as complete.

        LDIR                              ; else copy the bytes.
                                          ; and continue into next routine which
                                          ; sets the calculator stack pointers.

; --------------------
; Check stack pointers
; --------------------
; Register DE is set to STKEND and HL, the result pointer, is set to five
; locations below this.
; This routine is used when it is inconvenient to save these values at the
; time the calculator stack is manipulated due to other activity on the
; machine stack.
; This routine is also used to terminate the VAL and READ-IN  routines for
; the same reason and to initialize the calculator stack at the start of
; the CALCULATE routine.

stk_pntrs:
        LD      HL,(STKEND)               ; fetch STKEND value from system variable.
        LD      DE,-5                     ; the value -5
        PUSH    HL                        ; push STKEND value.

        ADD     HL,DE                     ; subtract 5 from HL.

        POP     DE                        ; pop STKEND to DE.
        RET                               ; return.

; ----------------
; Handle CHR$ (2F)
; ----------------
; This function returns a single character string that is a result of
; converting a number in the range 0-255 to a string e.g. CHR$ 65 = "A".

chrs:
        CALL    fp_to_a                   ; routine FP-TO-A puts the number in A.

        JR      C,report_bd               ; forward to REPORT-Bd if overflow
        JR      NZ,report_bd              ; forward to REPORT-Bd if negative

        PUSH    AF                        ; save the argument.

        LD      BC,$0001                  ; one space required.
        RST     30H                       ; BC-SPACES makes DE point to start

        POP     AF                        ; restore the number.

        LD      (DE),A                    ; and store in workspace

        CALL    stk_sto_string            ; routine STK-STO-$ stacks descriptor.

        EX      DE,HL                     ; make HL point to result and DE to STKEND.
        RET                               ; return.

; ---

report_bd:
        RST     08H                       ; ERROR-1
        DEFB    $0A                       ; Error Report: Integer out of range

; ----------------------------
; Handle VAL and VAL$ ($1D, $18)
; ----------------------------
; VAL treats the characters in a string as a numeric expression.
;     e.g. VAL "2.3" = 2.3, VAL "2+4" = 6, VAL ("2" + "4") = 24.
; VAL$ treats the characters in a string as a string expression.
;     e.g. VAL$ (z$+"(2)") = a$(2) if z$ happens to be "a$".

val:
valstring:
        LD      HL,(CH_ADD)               ; fetch value of system variable CH_ADD
        PUSH    HL                        ; and save on the machine stack.
        LD      A,B                       ; fetch the literal (either $1D or $18).
        ADD     A,$E3                     ; add $E3 to form $00 (setting carry) or $FB.
        SBC     A,A                       ; now form $FF bit 6 = numeric result
                                          ; or $00 bit 6 = string result.
        PUSH    AF                        ; save this mask on the stack

        CALL    stk_fetch                 ; routine STK-FETCH fetches the string operand
                                          ; from calculator stack.

        PUSH    DE                        ; save the address of the start of the string.
        INC     BC                        ; increment the length for a carriage return.

        RST     30H                       ; BC-SPACES creates the space in workspace.
        POP     HL                        ; restore start of string to HL.
        LD      (CH_ADD),DE               ; load CH_ADD with start DE in workspace.

        PUSH    DE                        ; save the start in workspace
        LDIR                              ; copy string from program or variables or
                                          ; workspace to the workspace area.
        EX      DE,HL                     ; end of string + 1 to HL
        DEC     HL                        ; decrement HL to point to end of new area.
        LD      (HL),$0D                  ; insert a carriage return at end.
        RES     7,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal checking syntax.
        CALL    scanning                  ; routine SCANNING evaluates string
                                          ; expression and result.

        RST     18H                       ; GET-CHAR fetches next character.
        CP      $0D                       ; is it the expected carriage return ?
        JR      NZ,v_rport_c              ; forward to V-RPORT-C if not
                                          ; 'Nonsense in BASIC'.

        POP     HL                        ; restore start of string in workspace.
        POP     AF                        ; restore expected result flag (bit 6).
        XOR     (IY+(FLAGS-C_IY))         ; xor with FLAGS now updated by SCANNING.
        AND     $40                       ; test bit 6 - should be zero if result types
                                          ; match.

v_rport_c:
        JP      NZ,report_c               ; jump back to REPORT-C with a result mismatch.

        LD      (CH_ADD),HL               ; set CH_ADD to the start of the string again.
        SET     7,(IY+(FLAGS-C_IY))       ; update FLAGS  - signal running program.
        CALL    scanning                  ; routine SCANNING evaluates the string
                                          ; in full leaving result on calculator stack.

        POP     HL                        ; restore saved character address in program.
        LD      (CH_ADD),HL               ; and reset the system variable CH_ADD.

        JR      stk_pntrs                 ; back to exit via STK-PNTRS.
                                          ; resetting the calculator stack pointers
                                          ; HL and DE from STKEND as it wasn't possible
                                          ; to preserve them during this routine.

; ----------------
; Handle STR$ (2E)
; ----------------
;
;

strstring:
        LD      BC,$0001                  ; create an initial byte in workspace
        RST     30H                       ; using BC-SPACES restart.

        LD      (K_CUR),HL                ; set system variable K_CUR to new location.
        PUSH    HL                        ; and save start on machine stack also.

        LD      HL,(CURCHL)               ; fetch value of system variable CURCHL
        PUSH    HL                        ; and save that too.

        LD      A,$FF                     ; select system channel 'R'.
        CALL    chan_open                 ; routine CHAN-OPEN opens it.
        CALL    print_fp                  ; routine PRINT-FP outputs the number to
                                          ; workspace updating K-CUR.

        POP     HL                        ; restore current channel.
        CALL    chan_flag                 ; routine CHAN-FLAG resets flags.

        POP     DE                        ; fetch saved start of string to DE.
        LD      HL,(K_CUR)                ; load HL with end of string from K_CUR.

        AND     A                         ; prepare for true subtraction.
        SBC     HL,DE                     ; subtract start from end to give length.
        LD      B,H                       ; transfer the length to
        LD      C,L                       ; the BC register pair.

        CALL    stk_sto_string            ; routine STK-STO-$ stores string parameters
                                          ; on the calculator stack.

        EX      DE,HL                     ; HL = last value, DE = STKEND.
        RET                               ; return.

; ------------
; Read-in (1A)
; ------------
; This is the calculator literal used by the INKEY$ function when a '#'
; is encountered after the keyword.
; INKEY$ # does not interact correctly with the keyboard, #0 or #1, and
; its uses are for other channels.

read_in:
        CALL    find_int1                 ; routine FIND-INT1 fetches stream to A
        CP      $10                       ; compare with 16 decimal.
        JP      NC,report_bb              ; jump to REPORT-Bb if not in range 0 - 15.
                                          ; 'Integer out of range'
                                          ; (REPORT-Bd is within range)

        LD      HL,(CURCHL)               ; fetch current channel CURCHL
        PUSH    HL                        ; save it
        CALL    chan_open                 ; routine CHAN-OPEN opens channel

        CALL    input_ad                  ; routine INPUT-AD - the channel must have an
                                          ; input stream or else error here from stream
                                          ; stub.
        LD      BC,$0000                  ; initialize length of string to zero
        JR      NC,r_i_store              ; forward to R-I-STORE if no key detected.

        INC     C                         ; increase length to one.

        RST     30H                       ; BC-SPACES creates space for one character
                                          ; in workspace.
        LD      (DE),A                    ; the character is inserted.

r_i_store:
        CALL    stk_sto_string            ; routine STK-STO-$ stacks the string
                                          ; parameters.
        POP     HL                        ; restore current channel address
        CALL    chan_flag                 ; routine CHAN-FLAG resets current channel
                                          ; system variable and flags.
        JP      stk_pntrs                 ; jump back to STK-PNTRS

; ----------------
; Handle CODE (1C)
; ----------------
; Returns the ASCII code of a character or first character of a string
; e.g. CODE "Aardvark" = 65, CODE "" = 0.

code:
        CALL    stk_fetch                 ; routine STK-FETCH to fetch and delete the
                                          ; string parameters.
                                          ; DE points to the start, BC holds the length.
        LD      A,B                       ; test length
        OR      C                         ; of the string.
        JR      Z,stk_code                ; skip to STK-CODE with zero if the null string.

        LD      A,(DE)                    ; else fetch the first character.

stk_code:
        JP      stack_a                   ; jump back to STACK-A (with memory check)

; ---------------
; Handle LEN (1E)
; ---------------
; Returns the length of a string.
; In Sinclair BASIC strings can be more than twenty thousand characters long
; so a sixteen-bit register is required to store the length

len:
        CALL    stk_fetch                 ; routine STK-FETCH to fetch and delete the
                                          ; string parameters from the calculator stack.
                                          ; register BC now holds the length of string.

        JP      stack_bc                  ; jump back to STACK-BC to save result on the
                                          ; calculator stack (with memory check).

; -------------------------
; Decrease the counter (35)
; -------------------------
; The calculator has an instruction that decrements a single-byte
; pseudo-register and makes consequential relative jumps just like
; the Z80's DJNZ instruction.

dec_jr_nz:
        EXX                               ; switch in set that addresses code

        PUSH    HL                        ; save pointer to offset byte
        LD      HL,BREG                   ; address BREG in system variables
        DEC     (HL)                      ; decrement it
        POP     HL                        ; restore pointer

        JR      NZ,jump_2                 ; to JUMP-2 if not zero

        INC     HL                        ; step past the jump length.
        EXX                               ; switch in the main set.
        RET                               ; return.

; Note. as a general rule the calculator avoids using the IY register
; otherwise the cumbersome 4 instructions in the middle could be replaced by
; dec (iy+$2d) - three bytes instead of six.


; ---------
; Jump (33)
; ---------
; This enables the calculator to perform relative jumps just like
; the Z80 chip's JR instruction

jump:
jump:
        EXX                               ;switch in pointer set

jump_2:
        LD      E,(HL)                    ; the jump byte 0-127 forward, 128-255 back.
        LD      A,E                       ; transfer to accumulator.
        RLA                               ; if backward jump, carry is set.
        SBC     A,A                       ; will be $FF if backward or $00 if forward.
        LD      D,A                       ; transfer to high byte.
        ADD     HL,DE                     ; advance calculator pointer forward or back.
        EXX                               ; switch back.
        RET                               ; return.

; -----------------
; Jump on true (00)
; -----------------
; This enables the calculator to perform conditional relative jumps
; dependent on whether the last test gave a true result

jump_true:
        INC     DE                        ; collect the
        INC     DE                        ; third byte
        LD      A,(DE)                    ; of the test
        DEC     DE                        ; result and
        DEC     DE                        ; backtrack.

        AND     A                         ; is result 0 or 1 ?
        JR      NZ,jump                   ; back to JUMP if true (1).

        EXX                               ; else switch in the pointer set.
        INC     HL                        ; step past the jump length.
        EXX                               ; switch in the main set.
        RET                               ; return.

; -----------------------
; End of calculation (38)
; -----------------------
; The end-calc literal terminates a mini-program written in the Spectrum's
; internal language.

end_calc:
        POP     AF                        ; drop the calculator return address RE-ENTRY
        EXX                               ; switch to the other set.

        EX      (SP),HL                   ; transfer H'L' to machine stack for the
                                          ; return address.
                                          ; when exiting recursion then the previous
                                          ; pointer is transferred to H'L'.

        EXX                               ; back to main set.
        RET                               ; return.


; ------------------------
; THE 'MODULUS' SUBROUTINE
; ------------------------
; (offset: $32 'n-mod-m')
;
;

n_mod_m:
        RST     28H                       ;; FP-CALC          17, 3.
        DEFB    $C0                       ;;st-mem-0          17, 3.
        DEFB    $02                       ;;delete            17.
        DEFB    $31                       ;;duplicate         17, 17.
        DEFB    $E0                       ;;get-mem-0         17, 17, 3.
        DEFB    $05                       ;;division          17, 17/3.
        DEFB    $27                       ;;int               17, 5.
        DEFB    $E0                       ;;get-mem-0         17, 5, 3.
        DEFB    $01                       ;;exchange          17, 3, 5.
        DEFB    $C0                       ;;st-mem-0          17, 3, 5.
        DEFB    $04                       ;;multiply          17, 15.
        DEFB    $03                       ;;subtract          2.
        DEFB    $E0                       ;;get-mem-0         2, 5.
        DEFB    $38                       ;;end-calc          2, 5.

        RET                               ; return.


; ------------------
; THE 'INT' FUNCTION
; ------------------
; (offset $27: 'int' )
;
; This function returns the integer of x, which is just the same as truncate
; for positive numbers. The truncate literal truncates negative numbers
; upwards so that -3.4 gives -3 whereas the BASIC INT function has to
; truncate negative numbers down so that INT -3.4 is -4.
; It is best to work through using, say, +-3.4 as examples.

int:
        RST     28H                       ;; FP-CALC              x.    (= 3.4 or -3.4).
        DEFB    $31                       ;;duplicate             x, x.
        DEFB    $36                       ;;less-0                x, (1/0)
        DEFB    $00                       ;;jump-true             x, (1/0)
        DEFB    $04                       ;;to x_neg, X-NEG

        DEFB    $3A                       ;;truncate              trunc 3.4 = 3.
        DEFB    $38                       ;;end-calc              3.

        RET                               ; return with + int x on stack.

; ---


x_neg:
        DEFB    $31                       ;;duplicate             -3.4, -3.4.
        DEFB    $3A                       ;;truncate              -3.4, -3.
        DEFB    $C0                       ;;st-mem-0              -3.4, -3.
        DEFB    $03                       ;;subtract              -.4
        DEFB    $E0                       ;;get-mem-0             -.4, -3.
        DEFB    $01                       ;;exchange              -3, -.4.
        DEFB    $30                       ;;not                   -3, (0).
        DEFB    $00                       ;;jump-true             -3.
        DEFB    $03                       ;;to exit, EXIT        -3.

        DEFB    $A1                       ;;stk-one               -3, 1.
        DEFB    $03                       ;;subtract              -4.

exit:
        DEFB    $38                       ;;end-calc              -4.

        RET                               ; return.


; ----------------
; Exponential (26)
; ----------------
;
;

exp:
exp:
        RST     28H                       ;; FP-CALC
        DEFB    $3D                       ;;re-stack
        DEFB    $34                       ;;stk-data
        DEFB    $F1                       ;;Exponent: $81, Bytes: 4
        DEFB    $38,$AA,$3B,$29           ;;
        DEFB    $04                       ;;multiply
        DEFB    $31                       ;;duplicate
        DEFB    $27                       ;;int
        DEFB    $C3                       ;;st-mem-3
        DEFB    $03                       ;;subtract
        DEFB    $31                       ;;duplicate
        DEFB    $0F                       ;;addition
        DEFB    $A1                       ;;stk-one
        DEFB    $03                       ;;subtract
        DEFB    $88                       ;;series-08
        DEFB    $13                       ;;Exponent: $63, Bytes: 1
        DEFB    $36                       ;;(+00,+00,+00)
        DEFB    $58                       ;;Exponent: $68, Bytes: 2
        DEFB    $65,$66                   ;;(+00,+00)
        DEFB    $9D                       ;;Exponent: $6D, Bytes: 3
        DEFB    $78,$65,$40               ;;(+00)
        DEFB    $A2                       ;;Exponent: $72, Bytes: 3
        DEFB    $60,$32,$C9               ;;(+00)
        DEFB    $E7                       ;;Exponent: $77, Bytes: 4
        DEFB    $21,$F7,$AF,$24           ;;
        DEFB    $EB                       ;;Exponent: $7B, Bytes: 4
        DEFB    $2F,$B0,$B0,$14           ;;
        DEFB    $EE                       ;;Exponent: $7E, Bytes: 4
        DEFB    $7E,$BB,$94,$58           ;;
        DEFB    $F1                       ;;Exponent: $81, Bytes: 4
        DEFB    $3A,$7E,$F8,$CF           ;;
        DEFB    $E3                       ;;get-mem-3
        DEFB    $38                       ;;end-calc

        CALL    fp_to_a                   ; routine FP-TO-A
        JR      NZ,n_negtv                ; to N-NEGTV

        JR      C,report_6b               ; to REPORT-6b

        ADD     A,(HL)                    ;
        JR      NC,result_ok              ; to RESULT-OK


report_6b:
        RST     08H                       ; ERROR-1
        DEFB    $05                       ; Error Report: Number too big

n_negtv:
        JR      C,rslt_zero               ; to RSLT-ZERO

        SUB     (HL)                      ;
        JR      NC,rslt_zero              ; to RSLT-ZERO

        NEG                               ; Negate

result_ok:
        LD      (HL),A                    ;
        RET                               ; return.

; ---


rslt_zero:
        RST     28H                       ;; FP-CALC
        DEFB    $02                       ;;delete
        DEFB    $A0                       ;;stk-zero
        DEFB    $38                       ;;end-calc

        RET                               ; return.


; ----------------------
; Natural logarithm (25)
; ----------------------
;
;

ln:
        RST     28H                       ;; FP-CALC
        DEFB    $3D                       ;;re-stack
        DEFB    $31                       ;;duplicate
        DEFB    $37                       ;;greater-0
        DEFB    $00                       ;;jump-true
        DEFB    $04                       ;;to valid, VALID

        DEFB    $38                       ;;end-calc


report_ab:
        RST     08H                       ; ERROR-1
        DEFB    $09                       ; Error Report: Invalid argument

valid:
        DEFB    $A0                       ;;stk-zero
        DEFB    $02                       ;;delete
        DEFB    $38                       ;;end-calc
        LD      A,(HL)                    ;

        LD      (HL),$80                  ;
        CALL    stack_a                   ; routine STACK-A

        RST     28H                       ;; FP-CALC
        DEFB    $34                       ;;stk-data
        DEFB    $38                       ;;Exponent: $88, Bytes: 1
        DEFB    $00                       ;;(+00,+00,+00)
        DEFB    $03                       ;;subtract
        DEFB    $01                       ;;exchange
        DEFB    $31                       ;;duplicate
        DEFB    $34                       ;;stk-data
        DEFB    $F0                       ;;Exponent: $80, Bytes: 4
        DEFB    $4C,$CC,$CC,$CD           ;;
        DEFB    $03                       ;;subtract
        DEFB    $37                       ;;greater-0
        DEFB    $00                       ;;jump-true
        DEFB    $08                       ;;to gre.8, GRE.8

        DEFB    $01                       ;;exchange
        DEFB    $A1                       ;;stk-one
        DEFB    $03                       ;;subtract
        DEFB    $01                       ;;exchange
        DEFB    $38                       ;;end-calc

        INC     (HL)                      ;

        RST     28H                       ;; FP-CALC

gre.8:
        DEFB    $01                       ;;exchange
        DEFB    $34                       ;;stk-data
        DEFB    $F0                       ;;Exponent: $80, Bytes: 4
        DEFB    $31,$72,$17,$F8           ;;
        DEFB    $04                       ;;multiply
        DEFB    $01                       ;;exchange
        DEFB    $A2                       ;;stk-half
        DEFB    $03                       ;;subtract
        DEFB    $A2                       ;;stk-half
        DEFB    $03                       ;;subtract
        DEFB    $31                       ;;duplicate
        DEFB    $34                       ;;stk-data
        DEFB    $32                       ;;Exponent: $82, Bytes: 1
        DEFB    $20                       ;;(+00,+00,+00)
        DEFB    $04                       ;;multiply
        DEFB    $A2                       ;;stk-half
        DEFB    $03                       ;;subtract
        DEFB    $8C                       ;;series-0C
        DEFB    $11                       ;;Exponent: $61, Bytes: 1
        DEFB    $AC                       ;;(+00,+00,+00)
        DEFB    $14                       ;;Exponent: $64, Bytes: 1
        DEFB    $09                       ;;(+00,+00,+00)
        DEFB    $56                       ;;Exponent: $66, Bytes: 2
        DEFB    $DA,$A5                   ;;(+00,+00)
        DEFB    $59                       ;;Exponent: $69, Bytes: 2
        DEFB    $30,$C5                   ;;(+00,+00)
        DEFB    $5C                       ;;Exponent: $6C, Bytes: 2
        DEFB    $90,$AA                   ;;(+00,+00)
        DEFB    $9E                       ;;Exponent: $6E, Bytes: 3
        DEFB    $70,$6F,$61               ;;(+00)
        DEFB    $A1                       ;;Exponent: $71, Bytes: 3
        DEFB    $CB,$DA,$96               ;;(+00)
        DEFB    $A4                       ;;Exponent: $74, Bytes: 3
        DEFB    $31,$9F,$B4               ;;(+00)
        DEFB    $E7                       ;;Exponent: $77, Bytes: 4
        DEFB    $A0,$FE,$5C,$FC           ;;
        DEFB    $EA                       ;;Exponent: $7A, Bytes: 4
        DEFB    $1B,$43,$CA,$36           ;;
        DEFB    $ED                       ;;Exponent: $7D, Bytes: 4
        DEFB    $A7,$9C,$7E,$5E           ;;
        DEFB    $F0                       ;;Exponent: $80, Bytes: 4
        DEFB    $6E,$23,$80,$93           ;;
        DEFB    $04                       ;;multiply
        DEFB    $0F                       ;;addition
        DEFB    $38                       ;;end-calc

        RET                               ; return.


; -----------------------------
; THE 'TRIGONOMETRIC' FUNCTIONS
; -----------------------------
; Trigonometry is rocket science. It is also used by carpenters and pyramid
; builders.
; Some uses can be quite abstract but the principles can be seen in simple
; right-angled triangles. Triangles have some special properties -
;
; 1) The sum of the three angles is always PI radians (180 degrees).
;    Very helpful if you know two angles and wish to find the third.
; 2) In any right-angled triangle the sum of the squares of the two shorter
;    sides is equal to the square of the longest side opposite the right-angle.
;    Very useful if you know the length of two sides and wish to know the
;    length of the third side.
; 3) Functions sine, cosine and tangent enable one to calculate the length
;    of an unknown side when the length of one other side and an angle is
;    known.
; 4) Functions arcsin, arccosine and arctan enable one to calculate an unknown
;    angle when the length of two of the sides is known.

;---------------------------------
; THE 'REDUCE ARGUMENT' SUBROUTINE
;---------------------------------
; (offset $39: 'get-argt')
;
; This routine performs two functions on the angle, in radians, that forms
; the argument to the sine and cosine functions.
; First it ensures that the angle 'wraps round'. That if a ship turns through
; an angle of, say, 3*PI radians (540 degrees) then the net effect is to turn
; through an angle of PI radians (180 degrees).
; Secondly it converts the angle in radians to a fraction of a right angle,
; depending within which quadrant the angle lies, with the periodicity
; resembling that of the desired sine value.
; The result lies in the range -1 to +1.
;
;                     90 deg.
;
;                     (pi/2)
;              II       +1        I
;                       |
;        sin+      |\   |   /|    sin+
;        cos-      | \  |  / |    cos+
;        tan-      |  \ | /  |    tan+
;                  |   \|/)  |
; 180 deg. (pi) 0 -|----+----|-- 0  (0)   0 degrees
;                  |   /|\   |
;        sin-      |  / | \  |    sin-
;        cos-      | /  |  \ |    cos+
;        tan+      |/   |   \|    tan-
;                       |
;              III      -1       IV
;                     (3pi/2)
;
;                     270 deg.
;

get_argt:
        RST     28H                       ;; FP-CALC      X.
        DEFB    $3D                       ;;re-stack
        DEFB    $34                       ;;stk-data
        DEFB    $EE                       ;;Exponent: $7E,
                                          ;;Bytes: 4
        DEFB    $22,$F9,$83,$6E           ;;              X, 1/(2*PI)
        DEFB    $04                       ;;multiply      X/(2*PI) = fraction
        DEFB    $31                       ;;duplicate
        DEFB    $A2                       ;;stk-half
        DEFB    $0F                       ;;addition
        DEFB    $27                       ;;int

        DEFB    $03                       ;;subtract      now range -.5 to .5

        DEFB    $31                       ;;duplicate
        DEFB    $0F                       ;;addition      now range -1 to 1.
        DEFB    $31                       ;;duplicate
        DEFB    $0F                       ;;addition      now range -2 to +2.

; quadrant I (0 to +1) and quadrant IV (-1 to 0) are now correct.
; quadrant II ranges +1 to +2.
; quadrant III ranges -2 to -1.

        DEFB    $31                       ;;duplicate     Y, Y.
        DEFB    $2A                       ;;abs           Y, abs(Y).    range 1 to 2
        DEFB    $A1                       ;;stk-one       Y, abs(Y), 1.
        DEFB    $03                       ;;subtract      Y, abs(Y)-1.  range 0 to 1
        DEFB    $31                       ;;duplicate     Y, Z, Z.
        DEFB    $37                       ;;greater-0     Y, Z, (1/0).

        DEFB    $C0                       ;;st-mem-0         store as possible sign
                                          ;;                 for cosine function.

        DEFB    $00                       ;;jump-true
        DEFB    $04                       ;;to zplus, ZPLUS  with quadrants II and III.

; else the angle lies in quadrant I or IV and value Y is already correct.

        DEFB    $02                       ;;delete        Y.   delete the test value.
        DEFB    $38                       ;;end-calc      Y.

        RET                               ; return.       with Q1 and Q4           >>>

; ---

; the branch was here with quadrants II (0 to 1) and III (1 to 0).
; Y will hold -2 to -1 if this is quadrant III.

zplus:
        DEFB    $A1                       ;;stk-one         Y, Z, 1.
        DEFB    $03                       ;;subtract        Y, Z-1.       Q3 = 0 to -1
        DEFB    $01                       ;;exchange        Z-1, Y.
        DEFB    $36                       ;;less-0          Z-1, (1/0).
        DEFB    $00                       ;;jump-true       Z-1.
        DEFB    $02                       ;;to yneg, YNEG
                                          ;;if angle in quadrant III

; else angle is within quadrant II (-1 to 0)

        DEFB    $1B                       ;;negate          range +1 to 0.

yneg:
        DEFB    $38                       ;;end-calc        quadrants II and III correct.

        RET                               ; return.


;----------------------
; THE 'COSINE' FUNCTION
;----------------------
; (offset $20: 'cos')
; Cosines are calculated as the sine of the opposite angle rectifying the
; sign depending on the quadrant rules.
;
;
;           /|
;        h /y|
;         /  |o
;        /x  |
;       /----|
;         a
;
; The cosine of angle x is the adjacent side (a) divided by the hypotenuse 1.
; However if we examine angle y then a/h is the sine of that angle.
; Since angle x plus angle y equals a right-angle, we can find angle y by
; subtracting angle x from pi/2.
; However it's just as easy to reduce the argument first and subtract the
; reduced argument from the value 1 (a reduced right-angle).
; It's even easier to subtract 1 from the angle and rectify the sign.
; In fact, after reducing the argument, the absolute value of the argument
; is used and rectified using the test result stored in mem-0 by 'get-argt'
; for that purpose.
;

cos:
        RST     28H                       ;; FP-CALC              angle in radians.
        DEFB    $39                       ;;get-argt              X     reduce -1 to +1

        DEFB    $2A                       ;;abs                   ABS X.   0 to 1
        DEFB    $A1                       ;;stk-one               ABS X, 1.
        DEFB    $03                       ;;subtract              now opposite angle
                                          ;;                      although sign is -ve.

        DEFB    $E0                       ;;get-mem-0             fetch the sign indicator
        DEFB    $00                       ;;jump-true
        DEFB    $06                       ;;fwd to c_ent, C-ENT
                                          ;;forward to common code if in QII or QIII.

        DEFB    $1B                       ;;negate                else make sign +ve.
        DEFB    $33                       ;;jump
        DEFB    $03                       ;;fwd to c_ent, C-ENT
                                          ;; with quadrants I and IV.

;--------------------
; THE 'SINE' FUNCTION
;--------------------
; (offset $1F: 'sin')
; This is a fundamental transcendental function from which others such as cos
; and tan are directly, or indirectly, derived.
; It uses the series generator to produce Chebyshev polynomials.
;
;
;           /|
;        1 / |
;         /  |x
;        /a  |
;       /----|
;         y
;
; The 'get-argt' function is designed to modify the angle and its sign
; in line with the desired sine value and afterwards it can launch straight
; into common code.

sin:
        RST     28H                       ;; FP-CALC      angle in radians
        DEFB    $39                       ;;get-argt      reduce - sign now correct.

c_ent:
        DEFB    $31                       ;;duplicate
        DEFB    $31                       ;;duplicate
        DEFB    $04                       ;;multiply
        DEFB    $31                       ;;duplicate
        DEFB    $0F                       ;;addition
        DEFB    $A1                       ;;stk-one
        DEFB    $03                       ;;subtract

        DEFB    $86                       ;;series-06
        DEFB    $14                       ;;Exponent: $64, Bytes: 1
        DEFB    $E6                       ;;(+00,+00,+00)
        DEFB    $5C                       ;;Exponent: $6C, Bytes: 2
        DEFB    $1F,$0B                   ;;(+00,+00)
        DEFB    $A3                       ;;Exponent: $73, Bytes: 3
        DEFB    $8F,$38,$EE               ;;(+00)
        DEFB    $E9                       ;;Exponent: $79, Bytes: 4
        DEFB    $15,$63,$BB,$23           ;;
        DEFB    $EE                       ;;Exponent: $7E, Bytes: 4
        DEFB    $92,$0D,$CD,$ED           ;;
        DEFB    $F1                       ;;Exponent: $81, Bytes: 4
        DEFB    $23,$5D,$1B,$EA           ;;
        DEFB    $04                       ;;multiply
        DEFB    $38                       ;;end-calc

        RET                               ; return.

;-----------------------
; THE 'TANGENT' FUNCTION
;-----------------------
; (offset $21: 'tan')
;
; Evaluates tangent x as    sin(x) / cos(x).
;
;
;           /|
;        h / |
;         /  |o
;        /x  |
;       /----|
;         a
;
; the tangent of angle x is the ratio of the length of the opposite side
; divided by the length of the adjacent side. As the opposite length can
; be calculates using sin(x) and the adjacent length using cos(x) then
; the tangent can be defined in terms of the previous two functions.

; Error 6 if the argument, in radians, is too close to one like pi/2
; which has an infinite tangent. e.g. PRINT TAN (PI/2)  evaluates as 1/0.
; Similarly PRINT TAN (3*PI/2), TAN (5*PI/2) etc.

tan:
        RST     28H                       ;; FP-CALC          x.
        DEFB    $31                       ;;duplicate         x, x.
        DEFB    $1F                       ;;sin               x, sin x.
        DEFB    $01                       ;;exchange          sin x, x.
        DEFB    $20                       ;;cos               sin x, cos x.
        DEFB    $05                       ;;division          sin x/cos x (= tan x).
        DEFB    $38                       ;;end-calc          tan x.

        RET                               ; return.

;----------------------
; THE 'ARCTAN' FUNCTION
;----------------------
; (Offset $24: 'atn')
; the inverse tangent function with the result in radians.
; This is a fundamental transcendental function from which others such as asn
; and acs are directly, or indirectly, derived.
; It uses the series generator to produce Chebyshev polynomials.

atn:
        CALL    re_stack                  ; routine re-stack
        LD      A,(HL)                    ; fetch exponent byte.
        CP      $81                       ; compare to that for 'one'
        JR      C,small                   ; forward, if less, to SMALL

        RST     28H                       ;; FP-CALC
        DEFB    $A1                       ;;stk-one
        DEFB    $1B                       ;;negate
        DEFB    $01                       ;;exchange
        DEFB    $05                       ;;division
        DEFB    $31                       ;;duplicate
        DEFB    $36                       ;;less-0
        DEFB    $A3                       ;;stk-pi/2
        DEFB    $01                       ;;exchange
        DEFB    $00                       ;;jump-true
        DEFB    $06                       ;;to cases, CASES

        DEFB    $1B                       ;;negate
        DEFB    $33                       ;;jump
        DEFB    $03                       ;;to cases, CASES

small:
        RST     28H                       ;; FP-CALC
        DEFB    $A0                       ;;stk-zero

cases:
        DEFB    $01                       ;;exchange
        DEFB    $31                       ;;duplicate
        DEFB    $31                       ;;duplicate
        DEFB    $04                       ;;multiply
        DEFB    $31                       ;;duplicate
        DEFB    $0F                       ;;addition
        DEFB    $A1                       ;;stk-one
        DEFB    $03                       ;;subtract
        DEFB    $8C                       ;;series-0C
        DEFB    $10                       ;;Exponent: $60, Bytes: 1
        DEFB    $B2                       ;;(+00,+00,+00)
        DEFB    $13                       ;;Exponent: $63, Bytes: 1
        DEFB    $0E                       ;;(+00,+00,+00)
        DEFB    $55                       ;;Exponent: $65, Bytes: 2
        DEFB    $E4,$8D                   ;;(+00,+00)
        DEFB    $58                       ;;Exponent: $68, Bytes: 2
        DEFB    $39,$BC                   ;;(+00,+00)
        DEFB    $5B                       ;;Exponent: $6B, Bytes: 2
        DEFB    $98,$FD                   ;;(+00,+00)
        DEFB    $9E                       ;;Exponent: $6E, Bytes: 3
        DEFB    $00,$36,$75               ;;(+00)
        DEFB    $A0                       ;;Exponent: $70, Bytes: 3
        DEFB    $DB,$E8,$B4               ;;(+00)
        DEFB    $63                       ;;Exponent: $73, Bytes: 2
        DEFB    $42,$C4                   ;;(+00,+00)
        DEFB    $E6                       ;;Exponent: $76, Bytes: 4
        DEFB    $B5,$09,$36,$BE           ;;
        DEFB    $E9                       ;;Exponent: $79, Bytes: 4
        DEFB    $36,$73,$1B,$5D           ;;
        DEFB    $EC                       ;;Exponent: $7C, Bytes: 4
        DEFB    $D8,$DE,$63,$BE           ;;
        DEFB    $F0                       ;;Exponent: $80, Bytes: 4
        DEFB    $61,$A1,$B3,$0C           ;;
        DEFB    $04                       ;;multiply
        DEFB    $0F                       ;;addition
        DEFB    $38                       ;;end-calc

        RET                               ; return.


;----------------------
; THE 'ARCSIN' FUNCTION
;----------------------
; (Offset $22: 'asn')
; the inverse sine function with result in radians.
; derived from arctan function above.
; Error A unless the argument is between -1 and +1 inclusive.
; uses an adaptation of the formula asn(x) = atn(x/sqr(1-x*x))
;
;
;           /|
;        1 / |
;         /  |x
;        /a  |
;       /----|
;         y
;
; e.g. we know the opposite side (x) and hypotenuse (1)
; and we wish to find angle a in radians.
; we can derive length y by Pythagorus and then use ATN instead.
; since y*y + x*x = 1*1 (Pythagorus Theorem) then
; y=sqr(1-x*x)                         - no need to multiply 1 by itself.
; so, asn(a) = atn(x/y)
; or more fully,
; asn(a) = atn(x/sqr(1-x*x))

; Close but no cigar.

; While PRINT ATN (x/SQR (1-x*x)) gives the same results as PRINT ASN x,
; it leads to division by zero when x is 1 or -1.
; To overcome this, 1 is added to y giving half the required angle and the
; result is then doubled.
; That is PRINT ATN (x/(SQR (1-x*x) +1)) *2
; A value higher than 1 gives the required error as attempting to find  the
; square root of a negative number generates an error in Sinclair BASIC.

asn:
        RST     28H                       ;; FP-CALC      x.
        DEFB    $31                       ;;duplicate     x, x.
        DEFB    $31                       ;;duplicate     x, x, x.
        DEFB    $04                       ;;multiply      x, x*x.
        DEFB    $A1                       ;;stk-one       x, x*x, 1.
        DEFB    $03                       ;;subtract      x, x*x-1.
        DEFB    $1B                       ;;negate        x, 1-x*x.
        DEFB    $28                       ;;sqr           x, sqr(1-x*x) = y
        DEFB    $A1                       ;;stk-one       x, y, 1.
        DEFB    $0F                       ;;addition      x, y+1.
        DEFB    $05                       ;;division      x/y+1.
        DEFB    $24                       ;;atn           a/2       (half the angle)
        DEFB    $31                       ;;duplicate     a/2, a/2.
        DEFB    $0F                       ;;addition      a.
        DEFB    $38                       ;;end-calc      a.

        RET                               ; return.


;-------------------------
; THE 'ARCCOS' FUNCTION
;-------------------------
; (Offset $23: 'acs')
; the inverse cosine function with the result in radians.
; Error A unless the argument is between -1 and +1.
; Result in range 0 to pi.
; Derived from asn above which is in turn derived from the preceding atn.
; It could have been derived directly from atn using acs(x) = atn(sqr(1-x*x)/x).
; However, as sine and cosine are horizontal translations of each other,
; uses acs(x) = pi/2 - asn(x)

; e.g. the arccosine of a known x value will give the required angle b in
; radians.
; We know, from above, how to calculate the angle a using asn(x).
; Since the three angles of any triangle add up to 180 degrees, or pi radians,
; and the largest angle in this case is a right-angle (pi/2 radians), then
; we can calculate angle b as pi/2 (both angles) minus asn(x) (angle a).
;
;
;           /|
;        1 /b|
;         /  |x
;        /a  |
;       /----|
;         y
;

acs:
        RST     28H                       ;; FP-CALC      x.
        DEFB    $22                       ;;asn           asn(x).
        DEFB    $A3                       ;;stk-pi/2      asn(x), pi/2.
        DEFB    $03                       ;;subtract      asn(x) - pi/2.
        DEFB    $1B                       ;;negate        pi/2 -asn(x)  =  acs(x).
        DEFB    $38                       ;;end-calc      acs(x).

        RET                               ; return.


; --------------------------
; THE 'SQUARE ROOT' FUNCTION
; --------------------------
; (Offset $28: 'sqr')
; This routine is remarkable only in its brevity - 7 bytes.
; It wasn't written here but in the ZX81 where the programmers had to squeeze
; a bulky operating sytem into an 8K ROM. It simply calculates
; the square root by stacking the value .5 and continuing into the 'to-power'
; routine. With more space available the much faster Newton-Raphson method
; should have been used as on the Jupiter Ace.

sqr:
        RST     28H                       ;; FP-CALC
        DEFB    $31                       ;;duplicate
        DEFB    $30                       ;;not
        DEFB    $00                       ;;jump-true
        DEFB    $1E                       ;;to last, LAST

        DEFB    $A2                       ;;stk-half
        DEFB    $38                       ;;end-calc


; ------------------------------
; THE 'EXPONENTIATION' OPERATION
; ------------------------------
; (Offset $06: 'to-power')
; This raises the first number X to the power of the second number Y.
; As with the ZX80,
; 0 ^ 0 = 1.
; 0 ^ +n = 0.
; 0 ^ -n = arithmetic overflow.
;

to_power:
        RST     28H                       ;; FP-CALC              X, Y.
        DEFB    $01                       ;;exchange              Y, X.
        DEFB    $31                       ;;duplicate             Y, X, X.
        DEFB    $30                       ;;not                   Y, X, (1/0).
        DEFB    $00                       ;;jump-true
        DEFB    $07                       ;;to xiso, XISO   if X is zero.

; else X is non-zero. Function 'ln' will catch a negative value of X.

        DEFB    $25                       ;;ln                    Y, LN X.
        DEFB    $04                       ;;multiply              Y * LN X.
        DEFB    $38                       ;;end-calc

        JP      exp                       ; jump back to EXP routine   ->

; ---

; these routines form the three simple results when the number is zero.
; begin by deleting the known zero to leave Y the power factor.

xiso:
        DEFB    $02                       ;;delete                Y.
        DEFB    $31                       ;;duplicate             Y, Y.
        DEFB    $30                       ;;not                   Y, (1/0).
        DEFB    $00                       ;;jump-true
        DEFB    $09                       ;;to one, ONE         if Y is zero.

        DEFB    $A0                       ;;stk-zero              Y, 0.
        DEFB    $01                       ;;exchange              0, Y.
        DEFB    $37                       ;;greater-0             0, (1/0).
        DEFB    $00                       ;;jump-true             0.
        DEFB    $06                       ;;to last, LAST        if Y was any positive
                                          ;;                      number.

; else force division by zero thereby raising an Arithmetic overflow error.
; There are some one and two-byte alternatives but perhaps the most formal
; might have been to use end-calc; rst 08; defb 05.

        DEFB    $A1                       ;;stk-one               0, 1.
        DEFB    $01                       ;;exchange              1, 0.
        DEFB    $05                       ;;division              1/0        ouch!

; ---

one:
        DEFB    $02                       ;;delete                .
        DEFB    $A1                       ;;stk-one               1.

last:
        DEFB    $38                       ;;end-calc              last value is 1 or 0.

        RET                               ; return.               Whew!


;*********************************
;** Spectrum 128 Patch Routines **
;*********************************

; The new code added to the standard 48K Spectrum ROM is mainly devoted to the scanning and decoding of the keypad.
; These routines occupy addresses 386E through to 3B3A. Addresses 3B3B through to 3C96 contain a variety of routines for the following purposes: displaying the new tokens 'PLAY' and 'SPECTRUM',
; dealing with the keypad when using INKEY$, handling new 128 BASIC error messages, and producing the TV tuner display. Addresses 3BE1 to 3BFE and addresses 3C97 to 3CFF are unused and all contain 00.
; Documented by Paul Farrow.

; --------------------------------
; SCAN THE KEYPAD AND THE KEYBOARD
; --------------------------------
; This patch will attempt to scan the keypad if in 128K mode and will then scan the keyboard.

keys:
        PUSH    IX
        BIT     4,(IY+(FLAGS-C_IY))       ; [FLAGS] Test if in 128K mode
        JR      Z,keys_cont               ; Z=in 48K mode

        CALL    keypad                    ; Attempt to scan the keypad

keys_cont:
        CALL    keyboard                  ; Scan the keyboard
        POP     IX
        RET

; ----------------------------------
; READ THE STATE OF THE OUTPUT LINES
; ----------------------------------
; This routine returns the state of the four output lines (bits 0-3) in the lower four bits of L. The LSB of L corresponds to the output communication line to the keypad.
; In this way the state of the other three outputs are maintained when the state of the LSB of L is changed and sent out to register 14 of the AY-3-8912.

read_outputs:
        LD      C,$FD                     ; FFFD = Address of the
        LD      D,$FF                     ; command register (register 7)
        LD      E,$BF                     ; BFFD = Address of the
        LD      B,D                       ; data register (register 14)
        LD      A,$07
        OUT     (C),A                     ; Select command register
        IN      H,(C)                     ; Read its status
        LD      A,$0E
        OUT     (C),A                     ; Select data register
        IN      A,(C)                     ; Read its status
        OR      $F0                       ; Mask off the input lines
        LD      L,A                       ; L=state of output lines at the
        RET                               ; keypad socket

; --------------------------
; SET THE OUTPUT LINE, BIT 0
; --------------------------
; The output line to the keypad is set via the LSB of L.

set_reg14:
        LD      B,D
        LD      A,$0E
        OUT     (C),A                     ; Select the data register
        LD      B,E
        OUT     (C),L                     ; Send L out to the data register
        RET                               ; Set the output line

; ----------------------------------------
; FETCH THE STATE OF THE INPUT LINE, BIT 5
; ----------------------------------------
; Return the state of the input line from the keypad in bit 5 of A.

get_reg14:
        LD      B,D
        LD      A,$0E
        OUT     (C),A                     ; Select the data register
        IN      A,(C)                     ; Read the input line
        RET

; ------------------------------
; SET THE OUTPUT LINE LOW, BIT 0
; ------------------------------

reset_line:
        LD      A,L
        AND     $FE                       ; Reset bit 0 of L
        LD      L,A
        JR      set_reg14                 ; Send out L to the data register

; -------------------------------
; SET THE OUTPUT LINE HIGH, BIT 0
; -------------------------------

set_line:
        LD      A,L
        OR      $01                       ; Set bit 0 of L
        LD      L,A
        JR      set_reg14                 ; Send out L to the data register

; -------------------
; MINOR DELAY ROUTINE
; -------------------
; Delay for (B*13)+5 T-States.

delay:
        DJNZ    delay
        RET

; -------------------
; MAJOR DELAY ROUTINE
; -------------------
; Delay for (B*271)+5 T-states.

delay2:
        PUSH    BC
        LD      B,$10
        CALL    delay                     ; Inner delay of 135 T-States
        POP     BC
        DJNZ    delay2

        RET

; ------------------------------------
; MONITOR FOR THE INPUT LINE TO GO LOW
; ------------------------------------
; Monitor the input line, bit 5, for up to (B*108)+5 T-states.

mon_b5_lo:
        PUSH    BC
        CALL    get_reg14                 ; Read the state of the input line
        POP     BC
        AND     $20                       ; Test bit 5, the input line
        JR      Z,ext_mon_lo              ; Exit if input line found low
        DJNZ    mon_b5_lo                 ; Repeat until timeout expires

ext_mon_lo:
        RET

; -------------------------------------
; MONITOR FOR THE INPUT LINE TO GO HIGH
; -------------------------------------
; Monitor the input line, bit 5, for up to (B*108)+5 T-states.

mon_b5_hi:
        PUSH    BC
        CALL    get_reg14                 ; Read the state of the input line
        POP     BC
        AND     $20                       ; Test bit 5, the input line
        JR      NZ,ext_mon_hi             ; Exit if input line found low
        DJNZ    mon_b5_hi                 ; Repeat until timeout expires

ext_mon_hi:
        RET

; -------------------------
; READ KEY PRESS STATUS BIT
; -------------------------
; This entry point is used to read in the status bit for a keypad row. If a key is being pressed in the current row then the bit read in will be a 1.

read_status:
        CALL    read_outputs              ; Read the output lines
        LD      B,$01                     ; Read in one bit
        JR      read_bit

; ----------------
; READ IN A NIBBLE
; ----------------
; This entry point is used to read in a nibble of data from the keypad. It is used for two functions. The first is to read in the poll nibble and the second is to read in a row of key press data.
; For a nibble of key press data, a bit read in as 1 indicates that the corresponding key was pressed.

read_nibble:
        CALL    read_outputs              ; Read the state of the output lines
        LD      B,$04                     ; Read in four bits

read_bit:
        PUSH    BC
        CALL    get_reg14                 ; Read the input line from the keypad
        POP     BC
        AND     $20                       ; This line should initially be high
        JR      Z,line_error2             ; Z=read in a 0, there must be an error

        XOR     A                         ; The bits read in will be stored in register A

bit_loop:
        PUSH    BC                        ; Preserve the loop count and any bits
        PUSH    AF                        ; read in so far
        CALL    set_line                  ; Set the output line high

        LD      B,$A3                     ; Monitor for 17609 T-states for the
        CALL    mon_b5_lo                 ; input line to go low
        JR      NZ,line_error             ; NZ=the line did not go low

        CALL    reset_line                ; Set the output line low
        JR      bl_continue               ; Insert a delay of 12 T-states

        DEFB    $FF, $FF

bl_continue:
        LD      B,$2B                     ; Delay for 564 T-states
        CALL    delay
        CALL    get_reg14                 ; Read in the bit value
        BIT     5,A
        JR      Z,bl_read_0               ; Z=read in a 0

        POP     AF                        ; Retrieve read in bits
        SCF                               ; Set carry bit
        JR      bl_store

bl_read_0:
        POP     AF                        ; Retrieve read in bits
        SCF
        CCF                               ; Clear carry bit

bl_store:
        RRA                               ; Shift the carry bit into bit 0 of A
        PUSH    AF                        ; Save bits read in
        CALL    set_line                  ; Set the output line high

        LD      B,$26                     ; Delay for 499 T-states
        CALL    delay

        CALL    reset_line                ; Set the output line low

        LD      B,$23                     ; Delay for 460 T-states
        CALL    delay

        POP     AF                        ; Retrieve read in bits
        POP     BC                        ; Retrieve loop counter and repeat
        DJNZ    bit_loop                  ; for all bits to read in

        RET

; ----------
; LINE ERROR
; ----------
; The input line was found at the wrong level. The output line is now set high which will eventually cause the keypad to abandon its transmissions.
; The upper nibble of system variable FLAGS/ROW3 will be cleared to indicate that communications to the keypad is no longer in progress.

line_error:
        POP     AF
        POP     BC                        ; Clear the stack

line_error2:
        CALL    set_line                  ; Set the output line high

        XOR     A                         ; Clear FLAGS nibble
        LD      (ROW01),A                 ; [FLAGS/ROW3]

        INC     A                         ; Return zero flag reset
        SCF
        CCF                               ; Return carry flag reset
        RET

; ---------------
; POLL THE KEYPAD
; ---------------
; The Spectrum 128 polls the keypad by changing the state of the output line and monitoring for responses from the keypad on the input line.
; Before a poll occurs, the poll counter must be decremented until it reaches zero. This counter causes a delay of three seconds before a communications attempt to the keypad is made.
; The routine can exit at five different places and it is the state of the A register, the zero flag and the carry flag which indicates the cause of the exit. This is summarised below:
;
; A Register    Zero Flag       Carry Flag    Cause
; 0             set             set           Communications already established
; 0             set             reset         Nibble read in OK
; 1             reset           reset         Nibble read in with an error or i/p line initially low
; 1             reset           set           Poll counter has not yet reached zero
;
; The third bit of the nibble read in must be set for the poll to be subsequently accepted.

attempt_poll:
        CALL    read_outputs              ; Read the output line states

        LD      A,(ROW01)                 ; [FLAGS/ROW3] Has communications already been
        AND     $80                       ; established with the keypad?
        JR      NZ,ap_skip_poll           ; NZ=yes, so skip the poll

        CALL    get_reg14                 ; Read the input line
        AND     $20                       ; It should be high initially
        JR      Z,line_error2             ; Z=error, input line found low

        LD      A,(ROW01)                 ; [FLAGS/ROW3] Test if poll counter already zero thus
        AND     A                         ; indicating a previous comms error
        JR      NZ,poll_keypad            ; NZ=ready to poll the keypad

        INC     A                         ; Indicate comms not established
        LD      (ROW01),A                 ; [FLAGS/ROW3]
        LD      A,$4C                     ; Reset the poll counter
        LD      (ROW23),A                 ; [ROW2/ROW1]
        JR      pk_exit                   ; Exit the routine

poll_keypad:
        LD      A,(ROW23)                 ; [ROW2/ROW1] Decrement the poll counter
        DEC     A
        LD      (ROW23),A                 ; [ROW2/ROW1]
        JR      NZ,pk_exit                ; Exit the routine if it is not yet zero

; The poll counter has reached zero so a poll of the keypad can now occur.

        XOR     A
        LD      (ROW01),A                 ; [FLAGS/ROW3] Indicate that a poll can occur
        LD      (ROW23),A                 ; [ROW2/ROW1]
        LD      (ROW45),A                 ; [ROW4/ROW5] Clear all the row nibble stores

        CALL    reset_line                ; Set the output line low

        LD      B,$21                     ; Wait up to 3569 T-States for the
        CALL    mon_b5_lo                 ; input line to go low
        JR      NZ,line_error2            ; NZ=line did not go low

        CALL    set_line                  ; Set the output line high

        LD      B,$24                     ; Wait up to 3893 T-States for the
        CALL    mon_b5_hi                 ; input line to go high
        JR      Z,line_error2             ; NZ=line did not go high

        CALL    reset_line                ; Set the output line low

        LD      B,$0F
        CALL    delay2                    ; Delay for 4070 T-States
        CALL    read_nibble               ; Read in a nibble of data
        JR      NZ,line_error2            ; NZ=error occurred when reading in nibble

        SET     7,A                       ; Set bit 7
        AND     $F0                       ; Keep only the upper four bits
                                          ; (Bit 6 will be set if poll successful)
        LD      (ROW01),A                 ; [FLAGS/ROW3] Store the flags nibble
        XOR     A
        SRL     A                         ; Exit: Zero flag set, Carry flag reset
        RET

ap_skip_poll:
        XOR     A                         ; Communications already established
        SCF                               ; Exit: Zero flag set, Carry flag set
        RET

pk_exit:
        XOR     A                         ; Poll counter not zero
        INC     A
        SCF                               ; Exit: Zero flag reset, Carry flag set
        RET

; -----------------------
; SCAN THE KEYPAD ROUTINE
; -----------------------
; If a successful poll of the keypad occurs then the five rows of keys are read in and a unique key code generated.

keypad_scan:
        CALL    attempt_poll              ; Try to poll the keypad

        LD      A,(ROW01)                 ; [FLAGS/ROW3] Test the flags nibble
        CPL
        AND     $C0                       ; Bits 6 and 7 must be set in FLAGS
        RET     NZ                        ; NZ=poll was not successful

; The poll was successful so now read in data for the five keypad rows.

        LD      IX,ROW45                  ; [ROW4/ROW5]
        LD      B,$05                     ; The five rows

ks_loop:
        PUSH    BC                        ; Save counter

        CALL    read_status               ; Read the key press status bit
        JP      NZ,ks_error               ; NZ=error occurred

        BIT     7,A                       ; Test the bit read in
        JR      Z,ks_next                 ; Z=no key pressed in this row

        CALL    read_nibble               ; Read in the row's nibble of data
        JR      NZ,ks_error               ; NZ=error occurred

        POP     BC                        ; Fetch the nibble loop counter
        PUSH    BC
        LD      C,A                       ; Move the nibble read in to C
        LD      A,(IX+$00)                ; Fetch the nibble store
        BIT     0,B                       ; Test if an upper or lower nibble
        JR      Z,ks_upper                ; Z=upper nibble

        SRL     C                         ; Shift the nibble to the lower position
        SRL     C
        SRL     C
        SRL     C
        AND     $F0                       ; Mask off the lower nibble of the
        JR      ks_store                  ; nibble store

ks_upper:
        AND     $0F                       ; Mask off the upper nibble of the nibble store

ks_store:
        OR      C                         ; Combine the existing and new
        LD      (IX+$00),A                ; nibbles and store them

ks_next:
        POP     BC                        ; Retrieve the row counter
        BIT     0,B                       ; Test if next nibble store is required
        JR      NZ,ks_new                 ; NZ=use same nibble store

        DEC     IX                        ; Point to the next nibble store

ks_new:
        DJNZ    ks_loop                   ; Repeat for the next keypad row

; All five rows have now been read so compose a unique code for the key pressed.

        LD      E,$80                     ; Signal no key press found yet
        LD      IX,ROW01                  ; [FLAGS/ROW3]
        LD      HL,key_masks              ; Point to the key mask data
        LD      B,$03                     ; Scan three nibbles

gen_loop:
        LD      A,(IX+$00)                ; Fetch a pair of nibbles
        AND     (HL)                      ; This will mask off the FLAGS nibble and the SHIFT/0 key

        JR      Z,gen_next                ; Z=no key pressed in these nibbles

        BIT     7,E                       ; Test if a key has already been found
        JR      Z,gen_invalid             ; Z=multiple keys pressed

        PUSH    BC                        ; Save the loop counter
        PUSH    AF                        ; Save the byte of key bit data
        LD      A,B                       ; Move loop counter to A
        JR      gen_cont                  ; A delay of 12 T-States

        DEFB    $FF, $FF                  ; Unused locations

gen_cont:
        DEC     A                         ; These lines of code generate base
        SLA     A                         ; values of 7, 15 and 23 for the three
        SLA     A                         ; nibble stores 5B88, 5B89 & 5B8A.
        SLA     A
        OR      $07
        LD      B,A                       ; B=(loop counter-1)*8+7
        POP     AF                        ; Fetch the byte of key press data

gen_bit:
        SLA     A                         ; Shift until a set key bit drops into the
        JP      C,gen_found               ; carry flag

        DJNZ    gen_bit                   ; Decrement B for each 'unsuccessful' shift of the A register

gen_found:
        LD      E,B                       ; E=a unique number for the key pressed, between 1 - 19 except 2 & 3

        POP     BC                        ; As a result shifting the set key bit
                                          ; into the carry flag, the A register will
                                          ; hold 00 if only one key was pressed
        JR      NZ,gen_invalid            ; NZ=multiple keys pressed

gen_next:
        INC     IX                        ; Point to the next nibble store
        INC     HL                        ; Point to the corresponding mask data
        DJNZ    gen_loop                  ; Repeat for all three 'nibble' bytes

        BIT     7,E                       ; Test if any keys were pressed
        JR      NZ,gen_point              ; NZ=no keys were pressed

        LD      A,E                       ; Copy the key code
        AND     $FC                       ; Test for the '.' key (E=1)
        JR      Z,gen_point               ; Z='.' key pressed

        DEC     E
        DEC     E                         ; Key code in range 2 - 17

; The E register now holds a unique key code value between 1 and 17.

gen_point:
        LD      A,(ROW45)                 ; [ROW4/ROW5] Test if the SHIFT key was pressed
        AND     $08
        JR      Z,gen_noshift             ; Z=the SHIFT key was not pressed

; The SHIFT key was pressed or no key was pressed.

        LD      A,E                       ; Fetch the key code
        AND     $7F                       ; Mask off 'no key pressed' bit
        ADD     A,$12                     ; Add on a shift offset of 12
        LD      E,A

; Add a base offset of 5A to all key codes. Note that no key press will result in a key code of DA. This is the only code with bit 7 set and so will be detected later.

gen_noshift:
        LD      A,E
        ADD     A,$5A                     ; Add a base offset of 5A
        LD      E,A                       ; Return key codes in range 5B - 7D
        XOR     A
        RET                               ; Exit: Zero flag set, key found OK

; These two lines belong with the loop above to read in the five keypad rows and are jumped to when an error occurs during reading in a nibble of data.

ks_error:
        POP     BC                        ; Clear the stack and exit
        RET                               ; Exit: Zero flag reset

gen_invalid:
        XOR     A                         ; Exit: Zero flag reset indicating an
        INC     A                         ; invalid key press
        RET

; ----------------
; KEYPAD MASK DATA
; ----------------

key_masks:
        DEFB    $0F, $FF, $F2             ; Key mask data

; ---------------
; READ THE KEYPAD
; ---------------
; This routine reads the keypad and handles key repeat and decoding. The bulk of the key repeat code is very similar to that used in the equivalent keyboard routine and works are follows.
; A double system of KSTATE system variables (KSTATE0 - KSTATE3 and KSTATE4 - KSTATE7) is used to allow the detection of one key while in the repeat period of the previous key.
; In this way, a 'spike' from another key will not stop the previous key from repeating. For a new key to be acknowledged, it must be held down for at least 1/5th of a second, i.e. ten calls to KEYPAD.
; The KSTATE system variables store the following data:
;
;       KSTATE0/4       Un-decoded Key Value (00-27 for keyboard, 5B-7D for keypad, FF for no key)
;       KSTATE1/5       10 Call Counter
;       KSTATE2/6       Repeat Delay
;       KSTATE3/7       Decoded Key Value
;
; The code returned is then stored in system variable LAST_K (5C08) and a new key signalled by setting bit 5 of FLAGS (5C3B).
;
; If the Spectrum 128 were to operate identically to the standard 48K Spectrum when in 48K mode, it would have to spend zero time in reading the keypad.
; As this is not possible, the loading on the CPU is reduced by scanning the keypad upon every other interrupt. A '10 Call Counter' is then used to ensure that a key is held down for at least 1/5th of a second
; before it is registered. Note that this is twice as long as for keyboard key presses and so the keypad key repeat delay is halved.
;
; At every other interrupt the keypad scanning routine is skipped. The net result of the routine is simply to decrement both '10 Call Counters', if appropriate. By loading the E register with 80 ensures that
; the call to KP_TEST will reject the key code and cause a return. A test for keyboard key codes prevents the Call Counter decrements affecting a keyboard key press. It would have been more efficient to execute
; a return upon every other call to KEYPAD and then to have used a '5 Call Counter' just as the keyboard routine does.
;
; A side effect of both the keyboard and keypad using the same KSTATE system variables is that if a key is held down on the keypad and then a key is held down on the keyboard, both keys will be monitored and
; repeated alternatively, but with a reduced repeat delay. This delay is between the keypad key repeat delay and the keyboard key repeat delay. This occurs because both the keypad and keyboard routines will
; decrement the KSTATE system variable Call Counters. The keypad routine 'knows' of the existence of keyboard key codes but the reverse is not true.

keypad:
        LD      E,$80                     ; Signal no key pressed
        LD      A,(FRAMES)                ; [FRAMES]
        AND     $01                       ; Scan the keypad every other
        JR      NZ,kp_check               ; interrupt

        CALL    keypad_scan
        RET     NZ                        ; NZ=no valid key pressed

kp_check:
        LD HL,KSTATE                      ; [KSTATE0] Test the first KSTATE variable

kp_loop:
        BIT     7,(HL)                    ; Is the set free?
        JR      NZ,kp_ch_set              ; NZ=yes

        LD      A,(HL)                    ; Fetch the un-decoded key value
        CP      $5B                       ; Is it a keyboard code?
        JR      C,kp_ch_set               ; C=yes, so do not decrement counter

        INC     HL
        DEC     (HL)                      ; Decrement the 10 Call Counter
        DEC     HL
        JR      NZ,kp_ch_set              ; If the counter reaches zero, then
                                          ; signal the set is free
        LD      (HL),$FF

kp_ch_set:
        LD      A,L                       ; Jump back and test the second set if
        LD      HL,KSTATE_04              ; [KSTATE4] not yet considered
        CP      L
        JR      NZ,kp_loop

        CALL    kp_test                   ; Test for valid key combinations and
        RET     NZ                        ; return if invalid

        LD      A,E                       ; Test if the key in the first set is being
        LD      HL,KSTATE                 ; [KSTATE0] repeated
        CP      (HL)
        JR      Z,kp_repeat               ; Jump if being repeated

        EX      DE,HL                     ; Save the address of KSTATE0
        LD      HL,KSTATE_04              ; [KSTATE4] Test if the key in the second set is
        CP      (HL)                      ; being repeated
        JR      Z,kp_repeat               ; Jump if being repeated

; A new key will not be accepted unless one of the KSTATE sets is free.

        BIT     7,(HL)                    ; Test if the second set is free
        JR      NZ,kp_new                 ; Jump if set is free

        EX      DE,HL
        BIT     7,(HL)                    ; Test if the first set is free
        RET     Z                         ; Return if no set is free

kp_new:
        LD      E,A                       ; Pass the key code to the E register
        LD      (HL),A                    ; and to KSTATE0/4
        INC     HL
        LD      (HL),$0A                  ; Set the '10 Call Counter' to 10
        INC     HL

        LD      A,(REPDEL)                ; [REPDEL] Fetch the initial repeat delay
        SRL     A                         ; Divide delay by two
        LD      (HL),A                    ; Store the repeat delay
        INC     HL

        CALL    kp_decode                 ; Decode the keypad key code
        LD      (HL),E                    ; and store it in KSTATE3/7

; This section is common for both new keys and repeated keys.

kp_end:
        LD      A,E
        LD      (LASTK),A                 ; [LAST_K] Store the key value in LAST_K
        LD      HL,FLAGS                  ; FLAGS
        SET     5,(HL)                    ; Signal a new key pressed
        RET

; -------------------------
; THE KEY REPEAT SUBROUTINE
; -------------------------

kp_repeat:
        INC     HL
        LD      (HL),$0A                  ; Reset the '10 Call Counter' to 10
        INC     HL
        DEC     (HL)                      ; Decrement the repeat delay
        RET     NZ                        ; Return if not zero

        LD      A,(REPPER)                ; [REPPER] The subsequent repeat delay is
        SRL     A                         ; divided by two and stored
        LD      (HL),A
        INC     HL
        LD      E,(HL)                    ; The key repeating is fetched
        JR      kp_end                    ; and then returned in LAST_K

; ----------------------------------------
; THE TEST FOR A VALID KEY CODE SUBROUTINE
; ----------------------------------------
; The zero flag is returned set if the key code is valid. No key press, SHIFT only or invalid shifted key presses return the zero flag reset.

kp_test:
        LD      A,E
        LD      HL,FLAGS3                 ; FLAGS3 Test if in BASIC or EDIT mode
        BIT     0,(HL)
        JR      Z,kpt_edit                ; Z=EDIT mode

; Test key codes when in BASIC/CALCULATOR mode

        CP      $6D                       ; Test for shifted keys
        JR      NC,kpt_invalid            ; and signal an error if found

kpt_ok:
        XOR     A                         ; Signal valid key code
        RET                               ; Exit: Zero flag set

; Test key codes when in EDIT/MENU mode.

kpt_edit:
        CP      $80                       ; Test for no key press
        JR      NC,kpt_invalid            ; NC=no key press

        CP      $6C                       ; Test for SHIFT on its own
        JR      NZ,kpt_ok                 ; NZ=valid key code

        DEFB    $00, $00, $00             ; Delay for 64 T-States
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00

kpt_invalid:
        XOR     A                         ; Signal invalid key code
        INC     A
        RET                               ; Exit: Zero flag reset

; ---------------------------
; THE KEY DECODING SUBROUTINE
; ---------------------------

kp_decode:
        PUSH    HL                        ; Save the KSTATE pointer
        LD      A,E
        SUB     $5B                       ; Reduce the key code range to
        LD      D,$00                     ; 00 - 22 and transfer to DE
        LD      E,A

        LD      HL,FLAGS3                 ; FLAGS3 Test if in EDIT or BASIC mode
        BIT     0,(HL)
        JR      Z,kpd_edit                ; Z=EDIT/MENU mode

; Use Table 1 when in CALCULATOR/BASIC mode.

        LD      HL,kpd_table1
        JR      kpd_exit                  ; Look up the key value

; Deal with EDIT/MENU mode.

kpd_edit:
        LD      HL,kpd_table4             ; Use Table 4 for unshifted key
        CP      $11                       ; presses
        JR      C,kpd_exit

; Deal with shifted keys in EDIT/MENU mode.

; Use Table 3 with SHIFT 1 (delete to beginning of line), SHIFT 2 (delete to end of line), SHIFT 3 (SHIFT TOGGLE). Note that although SHIFT TOGGLE produces a unique valid code,
; it actually performs no function when editing a BASIC program.

        LD      HL,kpd_table3
        CP      $15                       ; Test for SHIFT 1
        JR      Z,kpd_exit

        CP      $16                       ; Test for SHIFT 2
        JR      Z,kpd_exit

        JR      kpd_cont                  ; Delay for 12 T-States

        DEFB    $00, $FF, $FF             ; Unused locations

kpd_cont:
        CP      $17                       ; Test for SHIFT 3
        JR      Z,kpd_exit

; Use Table 2 with SHIFT 4 (delete to beginning of word) and SHIFT 5 (delete to end of word).

        LD      HL,kpd_table2
        CP      $21                       ; Test for SHIFT 4 and above
        JR      NC,kpd_exit

;Use Table 1 for all other shifted key presses.

        LD      HL,kpd_table1

kpd_exit:
        ADD     HL,DE                     ; Look up the key value
        LD      E,(HL)
        POP     HL                        ; Retrieve the KSTATE address
        RET

; --------------------------------
; THE KEYPAD DECODE LOOK-UP TABLES
; --------------------------------

kpd_table1:
        DEFB    $2E, $0D, $33             ; '.', ENTER, 3
        DEFB    $32, $31                  ; 2, 1

kpd_table2:
        DEFB    $29, $28, $2A             ; ), (, *
        DEFB    $2F, $2D, $39             ; /, - , 9
        DEFB    $38, $37, $2B             ; 8, 7, +

kpd_table3:
        DEFB    $36, $35, $34             ; 6, 5, 4
        DEFB    $30                       ; 0

kpd_table4:
        DEFB    $A5, $0D, $A6             ; Bottom, ENTER, Top
        DEFB    $A7, $A8, $A9             ; End of line, Start of line, TOGGLE
        DEFB    $AA, $0B, $0C             ; DEL right, Up, DEL
        DEFB    $07, $09, $0A             ; CMND, Right, Down
        DEFB    $08, $AC, $AD             ; Left, Down ten, Up ten
        DEFB    $AE, $AF                  ; End word, Beginning of word
        DEFB    $B0, $B1, $B2             ; DEL to end of line, DEL to start of line, SHIFT TOGGLE
        DEFB    $B3, $B4                  ; DEL to end of word, DEL to beginning of word

; -----------------------------
; PRINT NEW ERROR MESSAGE PATCH
; -----------------------------

print_new_error_patch:
        BIT     4,(IY+(FLAGS-C_IY))       ; FLAGS 3 - In 128K mode?
        JR      NZ,1f                     ; NZ=128K mode

; In 48K mode

        XOR     A                         ; Replicate code from standard ROM that the patch over-wrote
        LD      DE,$1536
        RET

; In 128K mode
1:
        LD      HL,routine_error          ; Vector table entry in Editor ROM -> JP $03A2

; Return to Editor ROM at address in HL
ret_hl_editor_rom:
        EX      (SP),HL                   ; Change the return address
        JP      PRINTER_BUFFER_48         ; Page Editor ROM and return to the address on the stack

; -------------------------------------
; STATEMENT INTERPRETATION RETURN PATCH
; -------------------------------------

statement_patch:
        BIT     4,(IY+(FLAGS-C_IY))       ; In 128K mode?
        JR      NZ,1f                     ; NZ=128K mode

; In 48K mode

        BIT     7,(IY+(NSPPC-C_IY))       ; replicate code from standard ROM that the patch over-wrote
        RET

; In 128K mode

1:      LD      HL,routine_stat_ret       ; Handle in Editor ROM by jumping to Vector table entry in Editor ROM -> JP #182A
        JR      ret_hl_editor_rom

; --------------------------
; GO TO NEXT STATEMENT PATCH
; --------------------------

next_stmt_patch:
        BIT     4,(IY+(FLAGS-C_IY))       ; In 128K mode?
        JR      NZ,1f                     ; NZ=128K mode

; In 48K mode

        RST     18H                       ; replicate code from standard ROM that the patch over-wrote
        CP      $0D
        RET

; In 128K mode

1:      LD      HL,routine_stat_next      ; Handle in Editor ROM by jumping to Vector table entry in Editor ROM -> JP #18A8
        JR      ret_hl_editor_rom

; --------------------------------------
; INKEY$ ROUTINE TO DEAL WITH THE KEYPAD
; --------------------------------------

keyscan2:
        CALL    key_scan                  ; KEYSCAN Scan the keyboard
        LD      C,$00
        JR      NZ,kpi_scan               ; NZ=multiple keys

        CALL    k_test                    ; K_TEST
        JR      NC,kpi_scan               ; NC=shift only or no key

        DEC     D
        LD      E,A
        CALL    k_decode                  ; K_DECODE
        JP      s_cont_get_str            ; S_CONT Get string and continue scanning

kpi_scan:
        BIT     4,(IY+(FLAGS-C_IY))       ; 128K mode?
        JP      Z,s_ikstring_stk          ; S_IK$_STK Z=no, stack keyboard code

        DI                                ; Disable interrupts whilst scanning
        CALL    keypad_scan               ; the keypad
        EI
        JR      NZ,kpi_invalid            ; NZ=multiple keys

        CALL    kp_test                   ; Test the keypad
        JR      NZ,kpi_invalid            ; NZ=no key, shift only or invalid combination

        CALL    kp_decode                 ; Form the key code
        LD      A,E
        JP      s_cont_get_str            ; S_CONT Get string and continue scanning

kpi_invalid:
        LD      C,$00                     ; Signal no key, i.e. length=0
        JP      s_ikstring_stk            ; S_IK$_STK

; ---------------------
; PRINT TOKEN/UDG PATCH
; ---------------------

; On entry:
;   A = char to print (144-255 / 0x90-0xff)
;   If printing keyword:
;     Bit 0 of [IY+(FLAGS-C_IY)] clear if leading space required.
;     [[CURCHL]] = print routine to call
;     ... any settings that routine at [[CURCHL]] requires ...
; On exit:
;   If printing a keyword:
;     A:
;       If [[CURCHL]] changes A:
;         that value
;       Else:
;         For RND / INKEY$ / PI:
;           A = entry A - 165
;         For <= / >= / <> / OPEN # / CLOSE #:
;           A = last char of keyword * 2
;         For all other keywords:
;           A = ' '
;     F:
;       H / X3 set
;       If upper screen in use:
;         Z / PV set
;       If keyword one of SPECTRUM / PLAY / RND / INKEY$ / PI / <= / >= / <> / OPEN # / CLOSE #:
;         C set
;     If keyword SPECTRUM/PLAY:
;       D = 4
;       E = Flags set for entry A SUB 163
;     Other keywords:
;       D = entry A - 165
;       E = Flags set for entry A SUB 165
;     If lower screen in use:
;       B = [S_POSN_Y_L]
;       C = [S_POSN_X_L]
;       HL = [DF_CC_L]
;     If upper screen in use:
;       B = [S_POSN_Y]
;       C = [S_POSN_X]
;       HL = [DF_CC]
;     If printer in use:
;       B: Whatever [[CURCHL]] does to B
;       If keyword SPECTRUM/PLAY:
;         C = Whatever [[CURCHL]] does to C
;         HL = unchanged, even if [[CURCHL]] modifies it
;       Other keywords:
;         C = [P_POSN_X]
;         HL = [PR_CC]
print_token_udg_patch:
        CP      $A3                       ; SPECTRUM (T)
        JR      Z,2f

        CP      $A4                       ; PLAY (U)
        JR      Z,2f

1:      SUB     $A5                       ; Check as per original ROM
        JP      NC,po_t                   ; If TOKEN jump to po_t

; Printing a UDG char
        JP      rejoin_po_t_udg           ; Rejoin original ROM routine

; Character $A3 or $A4
2:      BIT     4,(IY+(FLAGS-C_IY))       ; FLAGS - Bit 4=1 if in 128K mode
        JR      Z,1b                      ; If 48K mode print UDG

; In 128K mode here
; SPECTRUM or PLAY
        LD      DE,4f
        PUSH    DE                        ; Stack return address

        SUB     $A3                       ; Check whether the SPECTRUM token - and clears carry, since A >= $A3

        LD      DE,tkn_spectrum           ; SPECTRUM token
        JR      Z,3f

        LD      DE,tkn_play               ; PLAY token
; DE now points to correct token
3:      LD      A,$04                     ; Signal not RND, INKEY$ or PI so that a trailing space is printed
        PUSH    AF
        JP      po_table_1                ; Rejoin printing routine po_table_1, with carry clear

; Return address from above

4:      SCF                               ; Return as if no trailing space - don't think this affects future routine calls

        BIT     1,(IY+(FLAGS-C_IY))       ; Test if printer is in use
        RET     NZ                        ; NZ=printer in use

        JP      po_fetch                  ; PO-FETCH - Return via Position Fetch routine

tkn_spectrum:
        DEFM    "SPECTRU"                 ; SPECTRUM token
        DEFB    'M'+$80

tkn_play:
        DEFM    "PLA"                     ; PLAY token
        DEFB    'Y'+$80

kp_scan2:
        JP      kp_scan                   ; This is not called from either ROM. It can be used to scan the keypad.

        DEFB    $00, $00, $00             ; Unused locations
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $FF, $FF

kp_scan:
        JP      keypad_scan               ; This was to be called via the vector table in the EDITOR ROM but due to a programming error it never gets called.

; -----------------------
; TV TUNER VECTOR ENTRIES
; -----------------------

; Note this entry point is only referenced from ROM0
test_screen:
        JP      tv_tuner
        JP      tv_tuner
        JP      tv_tuner
        JP      tv_tuner

; ----------------
; TV TUNER ROUTINE
; ----------------
; This routine generates a display showing all possible colours and emitting a continuous cycle of a 440 Hz tone for 1 second followed by silence for 1 second.
; Its purpose is to ease the tuning in of TV sets to the Spectrum 128's RF signal. The display consists of vertical stripes of width four character squares showing each of the eight colours
; available at both their normal and bright intensities. The display begins with white on the left progressing up to black on the right. With in each colour stripe in the first eight rows is
; shown the year '1986' in varying ink colours. This leads to a display that shows all possible ink colours on all possible paper colours.

tv_tuner:
        LD      A,$7F                     ; Test for the BREAK key
        IN      A,($FE)
        RRA
        RET     C                         ; C=SPACE not pressed

        LD      A,$FE
        IN      A,($FE)
        RRA
        RET     C                         ; C=SPACE not pressed

        LD      A,$07
        OUT     ($FE),A                   ; Set the border to white

        LD      A,$02                     ; Open channel 2 (main screen)
        CALL    chan_open

        XOR     A
        LD      (TV_FLAG),A               ; [TV_FLAG] Signal using main screen

        LD      A,$16                     ; Print character 'AT'
        RST     10H

        XOR     A                         ; Print character '0'
        RST     10H

        XOR     A                         ; Print character '0'
        RST     10H

        LD      E,$08                     ; Number of characters per colour
        LD      B,E                       ; Paper counter + 1
        LD      D,B                       ; Ink counter + 1

tvt_row:
        LD      A,B                       ; Calculate the paper colour
        DEC     A                         ; Bits 3-5 of each screen attribute
        RL      A                         ; holds the paper colour; bits 0-2
        RL      A                         ; the ink colour
        RL      A
        ADD     A,D                       ; Add the ink colour
        DEC     A
        LD      (ATTR_T),A                ; [ATTR_T] Store as temporary attribute value

        LD      HL,tvt_data               ; TVT_DATA Point to the 'year' data
        LD      C,E                       ; Get number of characters to print

tvt_year:
        LD      A,(HL)                    ; Fetch a character from the data
        RST     10H                       ; Print it
        INC     HL
        DEC     C
        JR      NZ,tvt_year               ; Repeat for the 8 characters

        DJNZ    tvt_row                   ; Repeat for all colours in this row

        LD      B,E                       ; Reset paper colour
        DEC     D                         ; Next ink colour
        JR      NZ,tvt_row                ; Produce next row with new ink colour

        LD      HL,display_file+0x0800    ; Point to 2nd third of display file
        LD      D,H
        LD      E,L
        INC     DE                        ; Point to the next display cell
        XOR     A
        LD      (HL),A                    ; Clear first display cell
        LD      BC,$0FFF
        LDIR                              ; Clear lower 2 thirds of display file

        EX      DE,HL                     ; HL points to start of attributes file
        LD      DE,attributes_file+0x0100
                                          ; Point to 2nd third of attributes file
        LD      BC,$0200
        LDIR                              ; Copy screen attributes

; Now that the display has been constructed, produce a continuous cycle of a 440 Hz tone for 1 second followed by a period of silence for 1 second (actually 962ms).

        DI                                ; Disable interrupts so that a pure tone can be generated

tvt_tone:
        LD      DE,$0370                  ; DE=twice the tone frequency in Hz
        LD      L,$07                     ; Border colour of white

tvt_duration:
        LD      BC,$0099                  ; Delay for 950.4us

tvt_period:
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,tvt_period

        LD      A,L
        XOR     $10                       ; Toggle the speaker output whilst
        LD      L,A                       ; preserving the border colour
        OUT     ($FE),A

        DEC     DE                        ; Generate the tone for 1 second
        LD      A,D
        OR      E
        JR      NZ,tvt_duration

; At this point the speaker is turned off, so delay for 1 second.

        LD      BC,$0000                  ; Delay for 480.4us

tvt_delay1:
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,tvt_delay1

tvt_delay2:
        DEC     BC                        ; Delay for 480.4us
        LD      A,B
        OR      C
        JR      NZ,tvt_delay2

        JR      tvt_tone                  ; Repeat the tone cycle

tvt_data:
        DEFB    $13, $00                  ; Bright, off
        DEFB    $31, $39                  ; '1', '9'
        DEFB    $13, $01                  ; Bright, on
        DEFB    $38, $36                  ; '8', '6'

; ------
; UNUSED
; ------

        DEFB    $00, $00, $00             ; Unused locations
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00
        DEFB    $00, $00, $00

; -------------------------------
; THE 'ZX SPECTRUM CHARACTER SET'
; -------------------------------

char_set:

; $20 - Character: ' '          CHR$(32)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $21 - Character: '!'          CHR$(33)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000

; $22 - Character: '"'          CHR$(34)

        DEFB    %00000000
        DEFB    %00100100
        DEFB    %00100100
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $23 - Character: '#'          CHR$(35)

        DEFB    %00000000
        DEFB    %00100100
        DEFB    %01111110
        DEFB    %00100100
        DEFB    %00100100
        DEFB    %01111110
        DEFB    %00100100
        DEFB    %00000000

; $24 - Character: '$'          CHR$(36)

        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00101000
        DEFB    %00111110
        DEFB    %00001010
        DEFB    %00111110
        DEFB    %00001000

; $25 - Character: '%'          CHR$(37)

        DEFB    %00000000
        DEFB    %01100010
        DEFB    %01100100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100110
        DEFB    %01000110
        DEFB    %00000000

; $26 - Character: '&'          CHR$(38)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00101010
        DEFB    %01000100
        DEFB    %00111010
        DEFB    %00000000

; $27 - Character: '''          CHR$(39)

        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $28 - Character: '('          CHR$(40)

        DEFB    %00000000
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00000100
        DEFB    %00000000

; $29 - Character: ')'          CHR$(41)

        DEFB    %00000000
        DEFB    %00100000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %00000000

; $2A - Character: '*'          CHR$(42)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010100
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00001000
        DEFB    %00010100
        DEFB    %00000000

; $2B - Character: '+'          CHR$(43)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00000000

; $2C - Character: ','          CHR$(44)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00010000

; $2D - Character: '-'          CHR$(45)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111110
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $2E - Character: '.'          CHR$(46)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00011000
        DEFB    %00011000
        DEFB    %00000000

; $2F - Character: '/'          CHR$(47)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000010
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %00000000

; $30 - Character: '0'          CHR$(48)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000110
        DEFB    %01001010
        DEFB    %01010010
        DEFB    %01100010
        DEFB    %00111100
        DEFB    %00000000

; $31 - Character: '1'          CHR$(49)

        DEFB    %00000000
        DEFB    %00011000
        DEFB    %00101000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00000000

; $32 - Character: '2'          CHR$(50)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00000010
        DEFB    %00111100
        DEFB    %01000000
        DEFB    %01111110
        DEFB    %00000000

; $33 - Character: '3'          CHR$(51)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00001100
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $34 - Character: '4'          CHR$(52)

        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00011000
        DEFB    %00101000
        DEFB    %01001000
        DEFB    %01111110
        DEFB    %00001000
        DEFB    %00000000

; $35 - Character: '5'          CHR$(53)

        DEFB    %00000000
        DEFB    %01111110
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $36 - Character: '6'          CHR$(54)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $37 - Character: '7'          CHR$(55)

        DEFB    %00000000
        DEFB    %01111110
        DEFB    %00000010
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000

; $38 - Character: '8'          CHR$(56)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $39 - Character: '9'          CHR$(57)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111110
        DEFB    %00000010
        DEFB    %00111100
        DEFB    %00000000

; $3A - Character: ':'          CHR$(58)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000

; $3B - Character: ';'          CHR$(59)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00100000

; $3C - Character: '<'          CHR$(60)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00001000
        DEFB    %00000100
        DEFB    %00000000

; $3D - Character: '='          CHR$(61)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111110
        DEFB    %00000000
        DEFB    %00111110
        DEFB    %00000000
        DEFB    %00000000

; $3E - Character: '>'          CHR$(62)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00001000
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00000000

; $3F - Character: '?'          CHR$(63)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00000000

; $40 - Character: '@'          CHR$(64)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01001010
        DEFB    %01010110
        DEFB    %01011110
        DEFB    %01000000
        DEFB    %00111100
        DEFB    %00000000

; $41 - Character: 'A'          CHR$(65)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111110
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00000000

; $42 - Character: 'B'          CHR$(66)

        DEFB    %00000000
        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111100
        DEFB    %00000000

; $43 - Character: 'C'          CHR$(67)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $44 - Character: 'D'          CHR$(68)

        DEFB    %00000000
        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000100
        DEFB    %01111000
        DEFB    %00000000

; $45 - Character: 'E'          CHR$(69)

        DEFB    %00000000
        DEFB    %01111110
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01111110
        DEFB    %00000000

; $46 - Character: 'F'          CHR$(70)

        DEFB    %00000000
        DEFB    %01111110
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %00000000

; $47 - Character: 'G'          CHR$(71)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000000
        DEFB    %01001110
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $48 - Character: 'H'          CHR$(72)

        DEFB    %00000000
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111110
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00000000

; $49 - Character: 'I'          CHR$(73)

        DEFB    %00000000
        DEFB    %00111110
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00000000

; $4A - Character: 'J'          CHR$(74)

        DEFB    %00000000
        DEFB    %00000010
        DEFB    %00000010
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $4B - Character: 'K'          CHR$(75)

        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01001000
        DEFB    %01110000
        DEFB    %01001000
        DEFB    %01000100
        DEFB    %01000010
        DEFB    %00000000

; $4C - Character: 'L'          CHR$(76)

        DEFB    %00000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01111110
        DEFB    %00000000

; $4D - Character: 'M'          CHR$(77)

        DEFB    %00000000
        DEFB    %01000010
        DEFB    %01100110
        DEFB    %01011010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00000000

; $4E - Character: 'N'          CHR$(78)

        DEFB    %00000000
        DEFB    %01000010
        DEFB    %01100010
        DEFB    %01010010
        DEFB    %01001010
        DEFB    %01000110
        DEFB    %01000010
        DEFB    %00000000

; $4F - Character: 'O'          CHR$(79)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $50 - Character: 'P'          CHR$(80)

        DEFB    %00000000
        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111100
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %00000000

; $51 - Character: 'Q'          CHR$(81)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01010010
        DEFB    %01001010
        DEFB    %00111100
        DEFB    %00000000

; $52 - Character: 'R'          CHR$(82)

        DEFB    %00000000
        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111100
        DEFB    %01000100
        DEFB    %01000010
        DEFB    %00000000

; $53 - Character: 'S'          CHR$(83)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000000
        DEFB    %00111100
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $54 - Character: 'T'          CHR$(84)

        DEFB    %00000000
        DEFB    %11111110
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000

; $55 - Character: 'U'          CHR$(85)

        DEFB    %00000000
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100
last_u_byte:
        DEFB    %00000000

; $56 - Character: 'V'          CHR$(86)

        DEFB    %00000000
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00100100
        DEFB    %00011000
        DEFB    %00000000

; $57 - Character: 'W'          CHR$(87)

        DEFB    %00000000
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01011010
        DEFB    %00100100
        DEFB    %00000000

; $58 - Character: 'X'          CHR$(88)

        DEFB    %00000000
        DEFB    %01000010
        DEFB    %00100100
        DEFB    %00011000
        DEFB    %00011000
        DEFB    %00100100
        DEFB    %01000010
        DEFB    %00000000

; $59 - Character: 'Y'          CHR$(89)

        DEFB    %00000000
        DEFB    %10000010
        DEFB    %01000100
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000

; $5A - Character: 'Z'          CHR$(90)

        DEFB    %00000000
        DEFB    %01111110
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %01111110
        DEFB    %00000000

; $5B - Character: '['          CHR$(91)

        DEFB    %00000000
        DEFB    %00001110
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001110
        DEFB    %00000000

; $5C - Character: '\'          CHR$(92)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01000000
        DEFB    %00100000
        DEFB    %00010000
        DEFB    %00001000
        DEFB    %00000100
        DEFB    %00000000

; $5D - Character: ']'          CHR$(93)

        DEFB    %00000000
        DEFB    %01110000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %01110000
        DEFB    %00000000

; $5E - Character: '^'          CHR$(94)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00111000
        DEFB    %01010100
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000

; $5F - Character: '_'          CHR$(95)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %11111111

; $60 - Character: 'ukp'        CHR$(96)

        DEFB    %00000000
        DEFB    %00011100
        DEFB    %00100010
        DEFB    %01111000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %01111110
        DEFB    %00000000

; $61 - Character: 'a'          CHR$(97)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111000
        DEFB    %00000100
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000000

; $62 - Character: 'b'          CHR$(98)

        DEFB    %00000000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00111100
        DEFB    %00100010
        DEFB    %00100010
        DEFB    %00111100
        DEFB    %00000000

; $63 - Character: 'c'          CHR$(99)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00011100
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00011100
        DEFB    %00000000

; $64 - Character: 'd'          CHR$(100)

        DEFB    %00000000
        DEFB    %00000100
        DEFB    %00000100
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000000

; $65 - Character: 'e'          CHR$(101)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111000
        DEFB    %01000100
        DEFB    %01111000
        DEFB    %01000000
        DEFB    %00111100
        DEFB    %00000000

; $66 - Character: 'f'          CHR$(102)

        DEFB    %00000000
        DEFB    %00001100
        DEFB    %00010000
        DEFB    %00011000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000

; $67 - Character: 'g'          CHR$(103)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000100
        DEFB    %00111000

; $68 - Character: 'h'          CHR$(104)

        DEFB    %00000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00000000

; $69 - Character: 'i'          CHR$(105)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00110000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00111000
        DEFB    %00000000

; $6A - Character: 'j'          CHR$(106)

        DEFB    %00000000
        DEFB    %00000100
        DEFB    %00000000
        DEFB    %00000100
        DEFB    %00000100
        DEFB    %00000100
        DEFB    %00100100
        DEFB    %00011000

; $6B - Character: 'k'          CHR$(107)

        DEFB    %00000000
        DEFB    %00100000
        DEFB    %00101000
        DEFB    %00110000
        DEFB    %00110000
        DEFB    %00101000
        DEFB    %00100100
        DEFB    %00000000

; $6C - Character: 'l'          CHR$(108)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00001100
        DEFB    %00000000

; $6D - Character: 'm'          CHR$(109)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01101000
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %00000000

; $6E - Character: 'n'          CHR$(110)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00000000

; $6F - Character: 'o'          CHR$(111)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111000
        DEFB    %00000000

; $70 - Character: 'p'          CHR$(112)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01111000
        DEFB    %01000000
        DEFB    %01000000

; $71 - Character: 'q'          CHR$(113)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000100
        DEFB    %00000110

; $72 - Character: 'r'          CHR$(114)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00011100
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00000000

; $73 - Character: 's'          CHR$(115)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111000
        DEFB    %01000000
        DEFB    %00111000
        DEFB    %00000100
        DEFB    %01111000
        DEFB    %00000000

; $74 - Character: 't'          CHR$(116)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00111000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00001100
        DEFB    %00000000

; $75 - Character: 'u'          CHR$(117)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111000
        DEFB    %00000000

; $76 - Character: 'v'          CHR$(118)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00101000
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00000000

; $77 - Character: 'w'          CHR$(119)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %00101000
        DEFB    %00000000

; $78 - Character: 'x'          CHR$(120)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01000100
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00101000
        DEFB    %01000100
        DEFB    %00000000

; $79 - Character: 'y'          CHR$(121)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000100
        DEFB    %00111000

; $7A - Character: 'z'          CHR$(122)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %01111100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %01111100
        DEFB    %00000000

; $7B - Character: '{'          CHR$(123)

        DEFB    %00000000
        DEFB    %00001110
        DEFB    %00001000
        DEFB    %00110000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001110
        DEFB    %00000000

; $7C - Character: '|'          CHR$(124)

        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00000000

; $7D - Character: '}'          CHR$(125)

        DEFB    %00000000
        DEFB    %01110000
        DEFB    %00010000
        DEFB    %00001100
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %01110000
        DEFB    %00000000

; $7E - Character: '~'          CHR$(126)

        DEFB    %00000000
        DEFB    %00010100
        DEFB    %00101000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $7F - Character: '(c)'        CHR$(127)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %10011001
        DEFB    %10100001
        DEFB    %10100001
        DEFB    %10011001
        DEFB    %01000010
        DEFB    %00111100

; END
