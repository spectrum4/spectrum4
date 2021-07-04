# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by test_po_scr.sh. DO NOT EDIT!

.text


po_scr_upper_screen_02_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_02_01_setup_regs:
  ld      bc, 0x020d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_02_01_effects:
  ld      bc, 0x020d
  call    cl_set                          ; since B > [DF_SZ] (2>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_02_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (2>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_05_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_05_01_setup_regs:
  ld      bc, 0x050d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_05_01_effects:
  ld      bc, 0x050d
  call    cl_set                          ; since B > [DF_SZ] (5>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_05_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (5>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_08_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_08_01_setup_regs:
  ld      bc, 0x080d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_08_01_effects:
  ld      bc, 0x080d
  call    cl_set                          ; since B > [DF_SZ] (8>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_08_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (8>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_0b_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_0b_01_setup_regs:
  ld      bc, 0x0b0d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_0b_01_effects:
  ld      bc, 0x0b0d
  call    cl_set                          ; since B > [DF_SZ] (11>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_0b_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (11>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_0e_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_0e_01_setup_regs:
  ld      bc, 0x0e0d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_0e_01_effects:
  ld      bc, 0x0e0d
  call    cl_set                          ; since B > [DF_SZ] (14>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_0e_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (14>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_11_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_11_01_setup_regs:
  ld      bc, 0x110d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_11_01_effects:
  ld      bc, 0x110d
  call    cl_set                          ; since B > [DF_SZ] (17>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_11_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (17>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_14_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_14_01_setup_regs:
  ld      bc, 0x140d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_14_01_effects:
  ld      bc, 0x140d
  call    cl_set                          ; since B > [DF_SZ] (20>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_14_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (20>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_17_01_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x01, DF_SZ                     ; lower screen is 1 lines
  ret

po_scr_upper_screen_17_01_setup_regs:
  ld      bc, 0x170d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_17_01_effects:
  ld      bc, 0x170d
  call    cl_set                          ; since B > [DF_SZ] (23>1) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_17_01_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (23>1) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_0d_0c_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x0c, DF_SZ                     ; lower screen is 12 lines
  ret

po_scr_upper_screen_0d_0c_setup_regs:
  ld      bc, 0x0d0d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_0d_0c_effects:
  ld      bc, 0x0d0d
  call    cl_set                          ; since B > [DF_SZ] (13>12) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_0d_0c_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (13>12) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_10_0c_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x0c, DF_SZ                     ; lower screen is 12 lines
  ret

po_scr_upper_screen_10_0c_setup_regs:
  ld      bc, 0x100d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_10_0c_effects:
  ld      bc, 0x100d
  call    cl_set                          ; since B > [DF_SZ] (16>12) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_10_0c_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (16>12) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_13_0c_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x0c, DF_SZ                     ; lower screen is 12 lines
  ret

po_scr_upper_screen_13_0c_setup_regs:
  ld      bc, 0x130d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_13_0c_effects:
  ld      bc, 0x130d
  call    cl_set                          ; since B > [DF_SZ] (19>12) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_13_0c_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (19>12) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_16_0c_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x0c, DF_SZ                     ; lower screen is 12 lines
  ret

po_scr_upper_screen_16_0c_setup_regs:
  ld      bc, 0x160d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_16_0c_effects:
  ld      bc, 0x160d
  call    cl_set                          ; since B > [DF_SZ] (22>12) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_16_0c_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (22>12) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_14_13_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x13, DF_SZ                     ; lower screen is 19 lines
  ret

po_scr_upper_screen_14_13_setup_regs:
  ld      bc, 0x140d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_14_13_effects:
  ld      bc, 0x140d
  call    cl_set                          ; since B > [DF_SZ] (20>19) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_14_13_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (20>19) this routine simply calls CL_SET with same inputs
  ret


po_scr_upper_screen_17_13_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice if there is scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; not lower screen
  _strb   0x13, DF_SZ                     ; lower screen is 19 lines
  ret

po_scr_upper_screen_17_13_setup_regs:
  ld      bc, 0x170d                      ; B > [DF_SZ]
  ret

po_scr_upper_screen_17_13_effects:
  ld      bc, 0x170d
  call    cl_set                          ; since B > [DF_SZ] (23>19) this routine simply calls CL_SET with same inputs
  ret

po_scr_upper_screen_17_13_effects_regs:
  call    cl_set                          ; since B > [DF_SZ] (23>19) this routine simply calls CL_SET with same inputs
  ret
