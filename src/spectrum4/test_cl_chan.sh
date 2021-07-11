#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

function header {
  echo '# This file is part of the Spectrum +4 Project.'
  echo '# Licencing information can be found in the LICENCE file'
  echo '# (C) 2021 Spectrum +4 Authors. All rights reserved.'
  echo ''
  echo "# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'
  echo ''
  echo '.text'
}

cd "$(dirname "${0}")"

{
  header
  for ((df_sz=1; df_sz < 61; df_sz++)); do
    hexdfsz=$(printf "%02x" $df_sz)
    y=$((61-df_sz))
    screenthird=$((y/20))
    yoffset=$((y%20))
    dfoffset=$((screenthird*216*16*20 + 216*yoffset))
    hexdfoffset=$(printf "%04x" $dfoffset)
    echo
    echo
    echo "cl_chan_${hexdfsz}_setup:"
    echo "  _strb   0x${hexdfsz}, DF_SZ"
    echo "  _strb   0x6f, BORDCR"
    echo "  _strb   0b11110011, P_FLAG"
    echo "  _strh   0x0001, STRMS                   // Stream -3 points to first channel"
    echo "  _str    heap, CHANS                     // [CHANS] = start of heap"
    echo "  _str    'K', heap+0x10                  // Set channel identifier for first channel"
    echo "  ret"
    echo
    echo "cl_chan_${hexdfsz}_effects:"
    echo "  _str    heap, CURCHL                    // Current channel is keyboard"
    echo "  _resbit 1, FLAGS                        // Printer not in use"
    echo "  _resbit 5, FLAGS                        // No new key"
    echo "  _setbit 4, FLAGS2                       // K channel in use"
    echo "  _setbit 0, TV_FLAG                      // Lower screen in use"
    echo "  _strb   0x6f, ATTR_T                    // [BORDCR]"
    echo "  _strb   0x00, MASK_T"
    echo "  _strb   0b10100010, P_FLAG              // even (temp) bits cleared"
    echo "  _str    print_out, heap"
    echo "  _str    key_input, heap+8"
    echo "  _strb   109, S_POSN_X_L"
    echo "  _strb   59, S_POSN_Y_L"
    echo "  _strb   109, ECHO_E_X"
    echo "  _strb   59, ECHO_E_Y"
    echo "  _str    (display_file + 0x${hexdfoffset}), DF_CC_L"
    echo "  ret"
    echo
    echo "cl_chan_${hexdfsz}_effects_regs:"
    echo "  mov     x0, #59"
    echo "  mov     x1, #109"
    echo "  adr     x2, (display_file + 0x${hexdfoffset})"
    echo "  ldrb    w3, [x28, TV_FLAG-sysvars]"
    echo "  mov     x4, #${yoffset}"
    echo "  mov     x5, #216"
    echo "  ldr     x6, =0x10e00"
    echo "  ldrb    w9, [x28, FLAGS2-sysvars]"
    echo "  mov     x10, 'K'"
    echo "  nzcv    #0b0110"
    echo "  ret"
  done
} > "test_cl_chan.s"