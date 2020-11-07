# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by all.sh. DO NOT EDIT!

.set SYSVAR_COUNT, 58                     // number of system variables
.set SYSVAR_MASK_BYTES, 8                 // number of bytes required to store enough
                                          // 64 bit bitmasks to mask all sysvars

.data

.align 0
sysvarnames:
sysvar_COL_name:
  .asciz "COL"
sysvar_WIDTH_name:
  .asciz "WIDTH"
sysvar_TVPARS_name:
  .asciz "TVPARS"
sysvar_RASP_name:
  .asciz "RASP"
sysvar_PIP_name:
  .asciz "PIP"
sysvar_FLAGS_name:
  .asciz "FLAGS"
sysvar_FLAGS2_name:
  .asciz "FLAGS2"
sysvar_TV_FLAG_name:
  .asciz "TV_FLAG"
sysvar_BORDCR_name:
  .asciz "BORDCR"
sysvar_ERR_NR_name:
  .asciz "ERR_NR"
sysvar_DF_SZ_name:
  .asciz "DF_SZ"
sysvar_SCR_CT_name:
  .asciz "SCR_CT"
sysvar_P_POSN_name:
  .asciz "P_POSN"
sysvar_ECHO_E_COL_name:
  .asciz "ECHO_E_COL"
sysvar_ECHO_E_ROW_name:
  .asciz "ECHO_E_ROW"
sysvar_S_POSN_COL_name:
  .asciz "S_POSN_COL"
sysvar_S_POSN_ROW_name:
  .asciz "S_POSN_ROW"
sysvar_S_POSNL_COL_name:
  .asciz "S_POSNL_COL"
sysvar_S_POSNL_ROW_name:
  .asciz "S_POSNL_ROW"
sysvar_P_FLAG_name:
  .asciz "P_FLAG"
sysvar_BREG_name:
  .asciz "BREG"
sysvar_REPDEL_name:
  .asciz "REPDEL"
sysvar_REPPER_name:
  .asciz "REPPER"
sysvar_ATTR_P_name:
  .asciz "ATTR_P"
sysvar_MASK_P_name:
  .asciz "MASK_P"
sysvar_ATTR_T_name:
  .asciz "ATTR_T"
sysvar_MASK_T_name:
  .asciz "MASK_T"
sysvar_BAUD_name:
  .asciz "BAUD"
sysvar_SERFL_name:
  .asciz "SERFL"
sysvar_RNFIRST_name:
  .asciz "RNFIRST"
sysvar_RNSTEP_name:
  .asciz "RNSTEP"
sysvar_STRMS_name:
  .asciz "STRMS"
sysvar_COORDS_name:
  .asciz "COORDS"
sysvar_COORDS_Y_name:
  .asciz "COORDS_Y"
sysvar_TVDATA_name:
  .asciz "TVDATA"
sysvar_SFNEXT_name:
  .asciz "SFNEXT"
sysvar_SFSPACE_name:
  .asciz "SFSPACE"
sysvar_CHARS_name:
  .asciz "CHARS"
sysvar_LIST_SP_name:
  .asciz "LIST_SP"
sysvar_VARS_name:
  .asciz "VARS"
sysvar_CHANS_name:
  .asciz "CHANS"
sysvar_CURCHL_name:
  .asciz "CURCHL"
sysvar_PROG_name:
  .asciz "PROG"
sysvar_DATADD_name:
  .asciz "DATADD"
sysvar_E_LINE_name:
  .asciz "E_LINE"
sysvar_CH_ADD_name:
  .asciz "CH_ADD"
sysvar_X_PTR_name:
  .asciz "X_PTR"
sysvar_WORKSP_name:
  .asciz "WORKSP"
sysvar_STKBOT_name:
  .asciz "STKBOT"
sysvar_STKEND_name:
  .asciz "STKEND"
sysvar_RAMTOP_name:
  .asciz "RAMTOP"
sysvar_P_RAMT_name:
  .asciz "P_RAMT"
sysvar_UDG_name:
  .asciz "UDG"
sysvar_ERR_SP_name:
  .asciz "ERR_SP"
sysvar_DF_CC_name:
  .asciz "DF_CC"
sysvar_DF_CCL_name:
  .asciz "DF_CCL"
sysvar_PR_CC_name:
  .asciz "PR_CC"
sysvar_MEMBOT_name:
  .asciz "MEMBOT"

.align 0
sysvarsizes:
sysvar_COL_size:
  .byte 1
sysvar_WIDTH_size:
  .byte 1
sysvar_TVPARS_size:
  .byte 1
sysvar_RASP_size:
  .byte 1
sysvar_PIP_size:
  .byte 1
sysvar_FLAGS_size:
  .byte 1
sysvar_FLAGS2_size:
  .byte 1
sysvar_TV_FLAG_size:
  .byte 1
sysvar_BORDCR_size:
  .byte 1
sysvar_ERR_NR_size:
  .byte 1
sysvar_DF_SZ_size:
  .byte 1
sysvar_SCR_CT_size:
  .byte 1
sysvar_P_POSN_size:
  .byte 1
sysvar_ECHO_E_COL_size:
  .byte 1
sysvar_ECHO_E_ROW_size:
  .byte 1
sysvar_S_POSN_COL_size:
  .byte 1
sysvar_S_POSN_ROW_size:
  .byte 1
sysvar_S_POSNL_COL_size:
  .byte 1
sysvar_S_POSNL_ROW_size:
  .byte 1
sysvar_P_FLAG_size:
  .byte 1
sysvar_BREG_size:
  .byte 1
sysvar_REPDEL_size:
  .byte 1
sysvar_REPPER_size:
  .byte 1
sysvar_ATTR_P_size:
  .byte 1
sysvar_MASK_P_size:
  .byte 1
sysvar_ATTR_T_size:
  .byte 1
sysvar_MASK_T_size:
  .byte 1
sysvar_BAUD_size:
  .byte 2
sysvar_SERFL_size:
  .byte 2
sysvar_RNFIRST_size:
  .byte 2
sysvar_RNSTEP_size:
  .byte 2
sysvar_STRMS_size:
  .byte 2*19
sysvar_COORDS_size:
  .byte 2
sysvar_COORDS_Y_size:
  .byte 2
sysvar_TVDATA_size:
  .byte 2
sysvar_SFNEXT_size:
  .byte 8
sysvar_SFSPACE_size:
  .byte 8
sysvar_CHARS_size:
  .byte 8
sysvar_LIST_SP_size:
  .byte 8
sysvar_VARS_size:
  .byte 8
sysvar_CHANS_size:
  .byte 8
sysvar_CURCHL_size:
  .byte 8
sysvar_PROG_size:
  .byte 8
sysvar_DATADD_size:
  .byte 8
sysvar_E_LINE_size:
  .byte 8
sysvar_CH_ADD_size:
  .byte 8
sysvar_X_PTR_size:
  .byte 8
sysvar_WORKSP_size:
  .byte 8
sysvar_STKBOT_size:
  .byte 8
sysvar_STKEND_size:
  .byte 8
sysvar_RAMTOP_size:
  .byte 8
sysvar_P_RAMT_size:
  .byte 8
sysvar_UDG_size:
  .byte 8
sysvar_ERR_SP_size:
  .byte 8
sysvar_DF_CC_size:
  .byte 8
sysvar_DF_CCL_size:
  .byte 8
sysvar_PR_CC_size:
  .byte 8
sysvar_MEMBOT_size:
  .byte 32

.align 3
sysvaraddresses:
  .quad COL
  .quad WIDTH
  .quad TVPARS
  .quad RASP
  .quad PIP
  .quad FLAGS
  .quad FLAGS2
  .quad TV_FLAG
  .quad BORDCR
  .quad ERR_NR
  .quad DF_SZ
  .quad SCR_CT
  .quad P_POSN
  .quad ECHO_E_COL
  .quad ECHO_E_ROW
  .quad S_POSN_COL
  .quad S_POSN_ROW
  .quad S_POSNL_COL
  .quad S_POSNL_ROW
  .quad P_FLAG
  .quad BREG
  .quad REPDEL
  .quad REPPER
  .quad ATTR_P
  .quad MASK_P
  .quad ATTR_T
  .quad MASK_T
  .quad BAUD
  .quad SERFL
  .quad RNFIRST
  .quad RNSTEP
  .quad STRMS
  .quad COORDS
  .quad COORDS_Y
  .quad TVDATA
  .quad SFNEXT
  .quad SFSPACE
  .quad CHARS
  .quad LIST_SP
  .quad VARS
  .quad CHANS
  .quad CURCHL
  .quad PROG
  .quad DATADD
  .quad E_LINE
  .quad CH_ADD
  .quad X_PTR
  .quad WORKSP
  .quad STKBOT
  .quad STKEND
  .quad RAMTOP
  .quad P_RAMT
  .quad UDG
  .quad ERR_SP
  .quad DF_CC
  .quad DF_CCL
  .quad PR_CC
  .quad MEMBOT
