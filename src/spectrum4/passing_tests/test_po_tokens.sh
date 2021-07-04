#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


set -eu

keywords=(
  "RND"
  "INKEY$"
  "PI"
  "FN"
  "POINT"
  "SCREEN$"
  "ATTR"
  "AT"
  "TAB"
  "VAL$"
  "CODE"
  "VAL"
  "LEN"
  "SIN"
  "COS"
  "TAN"
  "ASN"
  "ACS"
  "ATN"
  "LN"
  "EXP"
  "INT"
  "SQR"
  "SGN"
  "ABS"
  "PEEK"
  "IN"
  "USR"
  "STR$"
  "CHR$"
  "NOT"
  "BIN"
  "OR"
  "AND"
  "<="
  ">="
  "<>"
  "LINE"
  "THEN"
  "TO"
  "STEP"
  "DEF FN"
  "CAT"
  "FORMAT"
  "MOVE"
  "ERASE"
  "OPEN #"
  "CLOSE #"
  "MERGE"
  "VERIFY"
  "BEEP"
  "CIRCLE"
  "INK"
  "PAPER"
  "FLASH"
  "BRIGHT"
  "INVERSE"
  "OVER"
  "OUT"
  "LPRINT"
  "LLIST"
  "STOP"
  "READ"
  "DATA"
  "RESTORE"
  "NEW"
  "BORDER"
  "CONTINUE"
  "DIM"
  "REM"
  "FOR"
  "GO TO"
  "GO SUB"
  "INPUT"
  "LOAD"
  "LIST"
  "LET"
  "PAUSE"
  "NEXT"
  "POKE"
  "PRINT"
  "PLOT"
  "RUN"
  "SAVE"
  "RANDOMIZE"
  "IF"
  "CLS"
  "DRAW"
  "CLEAR"
  "RETURN"
  "COPY"
)

cd "$(dirname "${0}")"

for fake_or_fake_reg_update in f s; do
  for flagsbit0 in 0 1; do
    {
      echo '# This file is part of the Spectrum +4 Project.'
      echo '# Licencing information can be found in the LICENCE file'
      echo '# (C) 2021 Spectrum +4 Authors. All rights reserved.'
      echo ''
      echo "# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'
      echo ''
      echo '.text'
      echo ''
      echo ''

      tkntableoffset=2
      for ((i=0; i<91;i++)); do
        hexi=$(printf "%02x" $i)
        keyword=${keywords[$i]}
        tkntableoffset=$((tkntableoffset+${#keyword}+1))
        testname="po_tokens_${flagsbit0}${fake_or_fake_reg_update}${hexi}"
        msgname="msg_${testname}"
        trailingspace=' '
        leadingspace=''
        leadingspace_description='leading space suppressed'
        if [ "${fake_or_fake_reg_update}" == "f" ]; then
          mock_description="doesn't disturb any registers"
        else
          mock_description='disturbs all registers in the register file'
        fi

        if [ "${flagsbit0}" == "0" ]; then
          leadingspace=' '
          leadingspace_description='leading space _not_ suppressed'
        fi
        case "${keyword}" in
          "RND" | "INKEY$" | "PI" | "FN" | "POINT" | "SCREEN$" | "ATTR" | "AT" | "TAB" | "VAL$" | "CODE" | "VAL" | "LEN" | "SIN" | "COS" | "TAN" | "ASN" | "ACS" | "ATN" | "LN" | "EXP" | "INT" | "SQR" | "SGN" | "ABS" | "PEEK" | "IN" | "USR" | "STR$" | "CHR$" | "NOT" | "BIN" | "<=" | ">=" | "<>")
            leadingspace=''
            leadingspace_description='leading space suppressed'
            ;;
        esac
        case "${keyword}" in
          "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #")
          trailingspace=''
          ;;
        esac
        expectedtext="${leadingspace}${keyword}${trailingspace}"
        echo ''
        echo ''
        echo '.align 2'
        echo "# Test ${testname} tests po_tokens when passed w3=0x${hexi} (BASIC keyword \"${keyword}\")"
        echo "# with bit 0 of [FLAGS] set to ${flagsbit0} (${leadingspace_description}) when used with"
        echo "# a mock print-out routine that ${mock_description}."
        echo "# Expected output is \"${expectedtext}\"."
        echo "${testname}_setup:"
        if [ "${fake_or_fake_reg_update}" == "f" ]; then
          echo "  _str    fake_channel_block, CURCHL                 // [CURCHL] = fake_channel_block"
        else
          echo "  _str    fake_reg_update_channel_block, CURCHL      // [CURCHL] = fake_reg_update_channel_block"
        fi
        echo "  _strb   ${flagsbit0}, FLAGS                          // ${leadingspace_description}"
        echo ''
        echo '.align 2'
        echo "${testname}_setup_regs:"
        echo "  mov     w3, 0x${hexi}"
        echo '  ret'
        echo ''
        echo '.align 2'
        echo "${testname}_effects:"
        echo '  stp     x29, x30, [sp, #-16]!                        // Push frame pointer, procedure link register on stack.'
        echo '  mov     x29, sp                                      // Update frame pointer to new stack location.'
        echo "  adr     x2, ${msgname}"
        echo "  bl      print_string                                 // Expect output \"${expectedtext}\""
        echo '  ldp     x29, x30, [sp], #16                          // Pop frame pointer, procedure link register off stack.'
        echo '  ret'
        echo ''
        echo '.align 2'
        echo "${testname}_effects_regs:"
        case "${keyword}" in
          "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #")
            echo '  mov     x0, #0x0'
            echo '  nzcv    0b1000'
            ;;
          "FN")
            echo "  mov     x0, ' '"
            echo '  nzcv    0b0110'
            ;;
          *)
            echo "  mov     x0, ' '"
            echo '  nzcv    0b0010'
            ;;
        esac
        if [ "${fake_or_fake_reg_update}" == "f" ]; then
          echo '  adr     x1, fake_printout'
        else
          echo '  adr     x1, fake_printout_touch_regs'
        fi
        echo "  adr     x4, tkn_table+${tkntableoffset}"
        echo "  mov     x5, 0x${hexi}"
        echo "  mov     x6, '${keyword: -1}'"
        echo '  ret'
        echo ''
        echo '.align 0'
        echo "${msgname}: .asciz \"${expectedtext}\""
      done
    } > "test_po_tokens.${fake_or_fake_reg_update}${flagsbit0}.s"
  done
done
