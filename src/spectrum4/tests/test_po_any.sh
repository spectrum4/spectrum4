#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

function test_setup {

  if [ "${lower_screen_in_use}" == "0" ]; then
    echo "  _resbit 0, TV_FLAG                           // lower screen not in use (used by po_fetch)"
  else
    echo "  _setbit 0, TV_FLAG                           // lower screen in use (used by po_fetch)"
  fi
  echo "  _setbit 4, FLAGS                             // 128K mode"
  echo "  _strb   0b00001111, P_FLAG                   // OVER 1, INVERSE 1"
  if [ "${printer_in_use}" == "0" ]; then
    echo "  _resbit 1, FLAGS                             // printer not in use"
    echo "  _strb   0x1e, DF_SZ                          // lower screen is 30 lines"
    echo "  _strb   0b01010011, MASK_T"
    echo "  _strb   0b01100101, ATTR_T"
    if [ "${a}" -lt 165 ]; then
      echo "  _strb   0b00111000, attributes_file + 108*20*${screenthird} + ${yoffset}*108 + ${x}"
      for p in {0..15}; do
        q=$(((p+1)%16))
        r=$(((p+2)%16))
        s=$(((p+3)%16))
        pqrs=$(printf "0x%01x%01x%01x%01x" $p $q $r $s)
        echo "  _strhbe ${pqrs}, display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2 + ${p}*216*20"
      done
    fi
  else
    echo "  _setbit 1, FLAGS                             // printer in use"
    if [ "${a}" -lt 165 ]; then
      for p in {0..15}; do
        q=$(((p+1)%16))
        r=$(((p+2)%16))
        s=$(((p+3)%16))
        pqrs=$(printf "0x%01x%01x%01x%01x" $p $q $r $s)
        echo "  _strhbe ${pqrs}, printer_buffer + ${x}*2 + ${p}*216"
      done
    fi
  fi
  echo "  ret"
  echo
  echo '.align 2'
  echo "${testname}_setup_regs:"
  if [ "${a}" -lt 165 ]; then
    if [ "${printer_in_use}" == "0" ]; then
      if [ "${lower_screen_in_use}" == "0" ]; then
        echo "  mov     w0, 60-${yoffset}-${screenthird}*20"
      else
        echo "  mov     w0, 120-${DF_SZ}-${yoffset}-${screenthird}*20"
      fi
      echo "  adrp    x2, display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2"
      echo "  add     x2, x2, :lo12:(display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2)"
    else
      echo "  adrp    x2, printer_buffer + ${x}*2"
      echo "  add     x2, x2, :lo12:(printer_buffer + ${x}*2)"
    fi
    echo "  mov     w1, 109-${x}"
  fi
  echo "  mov     w3, 0x${hexa}"
  echo '  ret'
}

function test_po_mosaic_half {

  b0=$(((a%2)*255))
  b1=$((((a>>1)%2)*255))
  b2=$((((a>>2)%2)*255))
  b3=$((((a>>3)%2)*255))
  hexb0=$(printf "%02x" $b0)
  hexb1=$(printf "%02x" $b1)
  hexb2=$(printf "%02x" $b2)
  hexb3=$(printf "%02x" $b3)

  echo
  echo '.align 2'
  echo "${testname}_effects:"
  if [ "${printer_in_use}" == "0" ]; then
    echo "  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack."
    echo "  mov     x29, sp                                 // Update frame pointer to new stack location."
  else
    echo "  _setbit 1, FLAGS2                               // Mark printer buffer as containing data"
  fi

  for p in {0..7}; do
    echo "  _strb   0x${hexb1}, MEMBOT + $((p*2))"
    echo "  _strb   0x${hexb0}, MEMBOT + $((p*2 + 1))"
  done
  for p in {8..15}; do
    echo "  _strb   0x${hexb3}, MEMBOT + $((p*2))"
    echo "  _strb   0x${hexb2}, MEMBOT + $((p*2 + 1))"
  done

  for p in {0..15}; do
    q=$(((p+1)%16))
    r=$(((p+2)%16))
    s=$(((p+3)%16))
    pqrs=$((s + 16 * r + 256 * q + 4096 * p))
    if [ "${p}" -lt 8 ]; then
      b=$((b1 * 256 + b0))
    else
      b=$((b3 * 256 + b2))
    fi
    res=$(printf "0x%04x" $((b ^ pqrs ^ 65535)))
    if [ "${printer_in_use}" == "0" ]; then
      echo "  _strhbe ${res}, display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2 + ${p}*216*20"
    else
      echo "  _strhbe ${res}, printer_buffer + ${x}*2 + ${p}*216"
    fi
  done

  if [ "${printer_in_use}" == "0" ]; then
    echo "  adrp    x0, display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2"
    echo "  add     x0, x0, :lo12:(display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2)"
    echo "  bl      po_attr"
    echo "  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack."
  fi

  echo '  ret'
  echo
  echo '.align 2'
  echo "${testname}_effects_regs:"
  if [ "${printer_in_use}" == "0" ]; then
    echo "  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack."
    echo "  mov     x29, sp                                 // Update frame pointer to new stack location."
    echo "  stp     x0, x1, [sp, #-16]!"
    echo "  str     x24, [sp, #-16]!"
    echo "  adrp    x0, display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2"
    echo "  add     x0, x0, :lo12:(display_file + 216*20*16*${screenthird} + ${yoffset}*216 + ${x}*2)"
    echo "  bl      po_attr"
    echo "  mov     w0, 60-${yoffset}-${screenthird}*20"
    echo "  ldr     x24, [sp], #0x10"
    echo "  ldp     x0, x1, [sp], #0x10"
  fi

  echo "  sub     w1, w1, #1"
  echo "  add     x2, x2, #2"
  echo "  add     x4, x28, MEMBOT-sysvars"

  if [ "${printer_in_use}" == "0" ]; then
    echo "  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack."
  else
    echo "  mov     w3, #8"
    echo "  mov     x5, #0x00${hexb3}00${hexb3}00${hexb3}00${hexb3}"
    echo "  mov     w6, #0xf"
    echo "  mov     w7, #0xffffffff"
    echo "  adrp    x9, printer_buffer_end"
    echo "  add     x9, x9, :lo12:printer_buffer_end"
    echo "  mov     x10, #0x${hexb2}${hexb3}"
    echo "  mov     x11, x9"
    echo "  nzcv    0b0010"
  fi
  echo '  ret'
}

keywords=(
  "SPECTRUM"
  "PLAY"
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

for printer_in_use in 0 1; do
  for lower_screen_in_use in 0 1; do
    {
      echo '# This file is part of the Spectrum +4 Project.'
      echo '# Licencing information can be found in the LICENCE file'
      echo '# (C) 2021 Spectrum +4 Authors. All rights reserved.'
      echo
      echo "# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'
      echo
      echo
      echo '.if ROMS_INCLUDE'
      echo '.else'
      echo '  .include "chan_flag.s"'
      echo '  .include "chan_k.s"'
      echo '  .include "chan_open.s"'
      echo '  .include "chan_p.s"'
      echo '  .include "chan_s.s"'
      echo '  .include "chn_cd_lu.s"'
      echo '  .include "cl_addr.s"'
      echo '  .include "cl_set.s"'
      echo '  .include "copy_buff.s"'
      echo '  .include "indexer.s"'
      echo '  .include "po_attr.s"'
      echo '  .include "po_char.s"'
      echo '  .include "po_char_2.s"'
      echo '  .include "po_mosaic_half.s"'
      echo '  .include "po_msg.s"'
      echo '  .include "po_scr.s"'
      echo '  .include "po_search.s"'
      echo '  .include "po_store.s"'
      echo '  .include "po_t_udg.s"'
      echo '  .include "po_table.s"'
      echo '  .include "po_table_1.s"'
      echo '  .include "pr_all.s"'
      echo '  .include "print_w0.s"'
      echo '  .include "temps.s"'
      echo '  .include "rejoin_po_t_udg.s"'
      echo '  .include "po_tokens.s"'
      echo '  .include "po_fetch.s"'
      echo '  .include "print_token_udg_patch.s"'
      echo '  .include "new_tokens.s"'
      echo '  .include "tkn_table.s"'
      echo '.endif'
      echo
      echo '.text'


      # Test ASCII characters

      for a in {32..127}; do
        # TODO !
        :
      done


      # Test mosaic characters

      for a in {128..143}; do
        hexa=$(printf "%02x" $a)
        testname="po_any_${hexa}_${printer_in_use}${lower_screen_in_use}"
        x=9
        if [ "${printer_in_use}" == "0" ]; then
          DF_SZ=30
          if [ "${lower_screen_in_use}" == "1" ]; then
            screenthird=2
            yoffset=7
          else
            screenthird=0
            yoffset=11
          fi
        fi
        echo
        echo ".align 2"
        echo "${testname}_setup:"
        test_setup
        if [ "${a}" -ge 128 ] && [ "${a}" -lt 144 ]; then
          test_po_mosaic_half
        fi
      done


      # Test UDGs

      for a in {144..164}; do
        # TODO !
        :
      done


      # Test keyword characters

      for fake_or_fake_reg_update in f s; do
        for flagsbit0 in 0 1; do
          for a in {163..255}; do
            if [ "${a}" -le 165 ]; then
              tkntableoffset=2
            fi
            j=$((a-163))
            keyword=${keywords[$j]}
            tkntableoffset=$((tkntableoffset+${#keyword}+1))
            hexa=$(printf "%02x" $a)
            testname="po_any_${hexa}_${fake_or_fake_reg_update}${flagsbit0}${printer_in_use}${lower_screen_in_use}"


            i=$((a-165))
            msgname="msg_${testname}"
            trailingspace=' '
            if [ "${fake_or_fake_reg_update}" == "f" ]; then
              mock_description="doesn't disturb any registers"
            else
              mock_description='disturbs several registers in the register file'
            fi
            if [ "${flagsbit0}" == "0" ]; then
              leadingspace=' '
              leadingspace_description='leading space allowed'
            else
              leadingspace=''
              leadingspace_description='leading space suppressed'
            fi
            case "${keyword}" in
              "RND" | "INKEY$" | "PI" | "FN" | "POINT" | "SCREEN$" | "ATTR" | "AT" | "TAB" | "VAL$" | "CODE" | "VAL" | "LEN" | "SIN" | "COS" | "TAN" | "ASN" | "ACS" | "ATN" | "LN" | "EXP" | "INT" | "SQR" | "SGN" | "ABS" | "PEEK" | "IN" | "USR" | "STR$" | "CHR$" | "NOT" | "BIN" | "<=" | ">=" | "<>")
                leadingspace=''
                leadingspace_description="${leadingspace_description} although \"$keyword\" has no leading space"
                ;;
            esac
            case "${keyword}" in
              "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #")
              trailingspace=''
              ;;
            esac
            expectedtext="${leadingspace}${keyword}${trailingspace}"
            echo
            echo
            echo "# Test ${testname} tests po_any when passed w3=0x${hexa} (BASIC keyword \"${keyword}\")"
            echo "# with bit 0 of FLAGS set to ${flagsbit0} (${leadingspace_description}) using a mock print-out"
            echo "# routine that ${mock_description}."
            echo "# Expected output is \"${leadingspace}${keyword}${trailingspace}\"."
            echo
            echo ".align 2"
            echo "${testname}_setup:"
            if [ "${fake_or_fake_reg_update}" == "f" ]; then
              echo "  _str    fake_channel_block, CURCHL           // test channel block that uses fake_printout routine"
            else
              echo "  _str    fake_reg_update_channel_block, CURCHL"
              echo "                                               // test channel block that uses fake_printout_touch_registers routine"
            fi
            if [ "${flagsbit0}" == "0" ]; then
              echo "  _resbit 0, FLAGS                             // leading space allowed"
            else
              echo "  _setbit 0, FLAGS                             // leading space suppressed"
            fi
            test_setup

            echo
            echo '.align 2'
            echo "${testname}_effects:"
            echo "  stp     x29, x30, [sp, #-16]!                        // Push frame pointer, procedure link register on stack."
            echo "  mov     x29, sp                                      // Update frame pointer to new stack location."
            echo "  adr     x2, ${msgname}"
            echo "  bl      print_string                                 // Expect output \"${expectedtext}\""
            echo "  ldp     x29, x30, [sp], #16                          // Pop frame pointer, procedure link register off stack."
            echo "  ret"
            echo
            echo '.align 2'
            echo "${testname}_effects_regs:"
            if [ "${printer_in_use}" == "1" ]; then
              case "${keyword}" in
                "SPECTRUM" | "PLAY")
                if [ "${fake_or_fake_reg_update}" == "f" ]; then
                  echo "  mov     x0, ' '"
                  echo '  adr     x1, fake_printout'
                else
                  echo "  mov     x0, #0x0a00"
                  echo "  mov     x1, #0x0a01"
                fi
                ;;
                *)
                echo "  ldrb    w0, [x28, FLAGS-sysvars]"
                echo "  ldrb    w1, [x28, P_POSN_X-sysvars]"
                echo "  ldr     x2, [x28, PR_CC-sysvars]"
                ;;
              esac
            elif [ "${lower_screen_in_use}" == "1" ]; then
              echo "  ldrb    w0, [x28, S_POSN_Y_L-sysvars]"
              echo "  ldrb    w1, [x28, S_POSN_X_L-sysvars]"
              echo "  ldr     x2, [x28, DF_CC_L-sysvars]"
            else
              echo "  ldrb    w0, [x28, S_POSN_Y-sysvars]"
              echo "  ldrb    w1, [x28, S_POSN_X-sysvars]"
              echo "  ldr     x2, [x28, DF_CC-sysvars]"
            fi
            case "${keyword}" in
              "SPECTRUM" | "PLAY")
              echo "  sub     x3, x3, #0xa3"
              echo "  ldrb    w4, [x28, FLAGS-sysvars]"
              echo "  mov     x5, #4"
              ;;
              *)
              echo "  sub     x3, x3, #0xa5"
              echo "  adr     x4, tkn_table+${tkntableoffset}"
              echo "  mov     x5, x3"
              ;;
            esac
            echo "  mov     x6, '${keyword: -1}'"
            case "${keyword}" in
              "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #")
              echo "  nzcv    #0b1000"
              ;;
              "FN")
              if [ "${fake_or_fake_reg_update}" == "f" ]; then
                echo "  nzcv    #0b0110"
              else
                echo "  nzcv    #0b0101"
              fi
              ;;
              *)
              if [ "${fake_or_fake_reg_update}" == "f" ]; then
                echo "  nzcv    #0b0010"
              else
                echo "  nzcv    #0b0101"
              fi
              ;;
            esac
            if [ "${fake_or_fake_reg_update}" == "s" ]; then
              echo "  mov     x7, #0x0a07"
              echo "  mov     x8, #0x0a08"
              echo "  mov     x9, #0x0a09"
              echo "  mov     x10, #0x0a0a"
              echo "  mov     x11, #0x0a0b"
              echo "  mov     x12, #0x0a0c"
              echo "  mov     x13, #0x0a0d"
              echo "  mov     x14, #0x0a0e"
              echo "  mov     x15, #0x0a0f"
              echo "  mov     x16, #0x0a10"
              echo "  mov     x17, #0x0a11"
              echo "  mov     x18, #0x0a12"
              echo "  mov     x19, #0x0a13"
              echo "  mov     x20, #0x0a14"
              echo "  mov     x21, #0x0a15"
              echo "  mov     x22, #0x0a16"
              echo "  mov     x23, #0x0a17"
              echo "  mov     x24, #0x0a18"
              echo "  mov     x25, #0x0a19"
              echo "  mov     x26, #0x0a1a"
              echo "  mov     x27, #0x0a1b"
            fi
            echo '  ret'
            echo
            echo '.align 0'
            echo "${msgname}: .asciz \"${expectedtext}\""
            echo
            echo '.ltorg'
          done
        done
      done
    } | ../../../utils/asm-format/asm-format > "test_po_any.${printer_in_use}${lower_screen_in_use}.gen-s"
  done
done
