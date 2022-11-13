.text
.align 2
# Entry point for NEW (with interrupts disabled when running in bare metal since this routine will enable interrupts)
new:                                     // L019D
  adrp    x0, char_set - 0x20 * 0x20
  add     x0, x0, :lo12:(char_set - 0x20 * 0x20)  // x0 = where, in theory character zero would be.
  str     x0, [x28, CHARS-sysvars]                // [CHARS] = theoretical address of char zero.
  ldr     x1, [x28, RAMTOP-sysvars]               // x1 = [RAMTOP].
  add     x1, x1, 1                               // x1 = [RAMTOP] + 1.
  and     sp, x1, #~0x0f                          // sp = highest 16-byte aligned address equal to or lower than ([RAMTOP] + 1).
  mov     x29, 0                                  // Frame pointer 0 indicates end of stack.
.if       UART_DEBUG
  mov     x0, msg_rpi_model
  bl      uart_puts
  ldr     w0, rpi_model
  bl      uart_x0
  bl      uart_newline
  mov     x0, msg_rpi_revision
  bl      uart_puts
  ldr     w0, rpi_revision
  bl      uart_x0
  bl      uart_newline

# logarm  ACCDATA_EL1
# logarm  ACTLR_EL1
# logarm  ACTLR_EL2
  logarm  ACTLR_EL3
# logarm  AFSR0_EL1
# logarm  AFSR0_EL2
# logarm  AFSR0_EL3
# logarm  AFSR1_EL1
# logarm  AFSR1_EL2
# logarm  AFSR1_EL3
# logarm  AIDR_EL1
# logarm  AMAIR_EL1
# logarm  AMAIR_EL2
# logarm  AMAIR_EL3
# logarm  BRBCR_EL1
# logarm  BRBCR_EL2
# logarm  BRBFCR_EL1
# logarm  BRBIDR0_EL1
# logarm  BRBINFINJ_EL1
# logarm  BRBSRCINJ_EL1
# logarm  BRBTGTINJ_EL1
# logarm  BRBTS_EL1
# logarm  CCSIDR_EL1
# logarm  CLIDR_EL1
  logarm  CNTFRQ_EL0
# logarm  CNTHCTL_EL2
# logarm  CNTHP_CTL_EL2
# logarm  CNTHP_CVAL_EL2
# logarm  CNTHP_TVAL_EL2
# logarm  CNTKCTL_EL1
# logarm  CNTPCT_EL0
# logarm  CNTPS_CTL_EL1
# logarm  CNTPS_CVAL_EL1
# logarm  CNTPS_TVAL_EL1
# logarm  CNTP_CTL_EL0
# logarm  CNTP_CVAL_EL0
# logarm  CNTP_TVAL_EL0
# logarm  CNTVCT_EL0
# logarm  CNTVOFF_EL2
# logarm  CNTV_CTL_EL0
# logarm  CNTV_CVAL_EL0
# logarm  CNTV_TVAL_EL0
# logarm  CONTEXTIDR_EL1
# logarm  CPACR_EL1
# logarm  CPTR_EL2
# logarm  CPTR_EL3
# logarm  CSSELR_EL1
  logarm  CTR_EL0
  logarm  CurrentEL
# logarm  DACR32_EL2
  logarm  DAIF
# logarm  DBGAUTHSTATUS_EL1
# logarm  DBGCLAIMCLR_EL1
# logarm  DBGCLAIMSET_EL1
# logarm  DBGDTRRX_EL0
# logarm  DBGDTRTX_EL0
# logarm  DBGDTR_EL0
# logarm  DBGPRCR_EL1
# logarm  DBGVCR32_EL2
# logarm  DCZID_EL0
# logarm  DISR_EL1
# logarm  DLR_EL0
# logarm  DSPSR_EL0
# logarm  ELR_EL1
# logarm  ELR_EL2
  logarm  ELR_EL3
# logarm  ERRIDR_EL1
# logarm  ERRSELR_EL1
# logarm  ERXADDR_EL1
# logarm  ERXCTLR_EL1
# logarm  ERXFR_EL1
# logarm  ERXMISC0_EL1
# logarm  ERXMISC1_EL1
# logarm  ERXMISC2_EL1
# logarm  ERXMISC3_EL1
# logarm  ERXPFGCDN_EL1
# logarm  ERXPFGCTL_EL1
# logarm  ERXPFGF_EL1
# logarm  ERXSTATUS_EL1
# logarm  ESR_EL1
# logarm  ESR_EL2
# logarm  ESR_EL3
# logarm  FAR_EL1
# logarm  FAR_EL2
# logarm  FAR_EL3
# logarm  FPCR
# logarm  FPEXC32_EL2
# logarm  FPSR
# logarm  HACR_EL2
# logarm  HCR_EL2
# logarm  HPFAR_EL2
# logarm  HSTR_EL2
# logarm  ICC_ASGI1R_EL1
# logarm  ICC_BPR0_EL1
# logarm  ICC_BPR1_EL1
# logarm  ICC_CTLR_EL1
# logarm  ICC_CTLR_EL3
# logarm  ICC_DIR_EL1
# logarm  ICC_EOIR0_EL1
# logarm  ICC_EOIR1_EL1
# logarm  ICC_HPPIR0_EL1
# logarm  ICC_HPPIR1_EL1
# logarm  ICC_IAR0_EL1
# logarm  ICC_IAR1_EL1
# logarm  ICC_IGRPEN0_EL1
# logarm  ICC_IGRPEN1_EL1
# logarm  ICC_IGRPEN1_EL3
# logarm  ICC_PMR_EL1
# logarm  ICC_RPR_EL1
# logarm  ICC_SGI0R_EL1
# logarm  ICC_SGI1R_EL1
# logarm  ICC_SRE_EL1
# logarm  ICC_SRE_EL2
# logarm  ICC_SRE_EL3
# logarm  ICH_EISR_EL2
# logarm  ICH_ELRSR_EL2
# logarm  ICH_HCR_EL2
# logarm  ICH_MISR_EL2
# logarm  ICH_VMCR_EL2
# logarm  ICH_VTR_EL2
  logarm  ID_AA64AFR0_EL1
  logarm  ID_AA64AFR1_EL1
  logarm  ID_AA64DFR0_EL1
  logarm  ID_AA64DFR1_EL1
  logarm  ID_AA64ISAR0_EL1
  logarm  ID_AA64ISAR1_EL1
# logarm  ID_AA64ISAR2_EL1
  logarm  ID_AA64MMFR0_EL1
  logarm  ID_AA64MMFR1_EL1
  logarm  ID_AA64MMFR2_EL1
  logarm  ID_AA64PFR0_EL1
  logarm  ID_AA64PFR1_EL1
  logarm  ID_AFR0_EL1
  logarm  ID_DFR0_EL1
# logarm  ID_DFR1_EL1
  logarm  ID_ISAR0_EL1
  logarm  ID_ISAR1_EL1
  logarm  ID_ISAR2_EL1
  logarm  ID_ISAR3_EL1
  logarm  ID_ISAR4_EL1
  logarm  ID_ISAR5_EL1
# logarm  ID_ISAR6_EL1
  logarm  ID_MMFR0_EL1
  logarm  ID_MMFR1_EL1
  logarm  ID_MMFR2_EL1
  logarm  ID_MMFR3_EL1
  logarm  ID_MMFR4_EL1
# logarm  ID_MMFR5_EL1
  logarm  ID_PFR0_EL1
  logarm  ID_PFR1_EL1
# logarm  IFSR32_EL2
# logarm  ISR_EL1
# logarm  MAIR_EL1
# logarm  MAIR_EL2
# logarm  MAIR_EL3
# logarm  MDCCINT_EL1
# logarm  MDCCSR_EL0
# logarm  MDCR_EL2
# logarm  MDCR_EL3
# logarm  MDRAR_EL1
# logarm  MDSCR_EL1
  logarm  MIDR_EL1
# logarm  MPAM0_EL1
# logarm  MPAM1_EL1
# logarm  MPAM2_EL2
# logarm  MPAM3_EL3
# logarm  MPAMHCR_EL2
# logarm  MPAMIDR_EL1
# logarm  MPAMVPM0_EL2
# logarm  MPAMVPM1_EL2
# logarm  MPAMVPM2_EL2
# logarm  MPAMVPM3_EL2
# logarm  MPAMVPM4_EL2
# logarm  MPAMVPM5_EL2
# logarm  MPAMVPM6_EL2
# logarm  MPAMVPM7_EL2
# logarm  MPAMVPMV_EL2
# logarm  MPIDR_EL1
# logarm  MVFR0_EL1
# logarm  MVFR1_EL1
# logarm  MVFR2_EL1
  logarm  NZCV
# logarm  OSDLR_EL1
# logarm  OSDTRRX_EL1
# logarm  OSDTRTX_EL1
# logarm  OSECCR_EL1
# logarm  OSLAR_EL1
# logarm  OSLSR_EL1
# logarm  PAR_EL1
# logarm  PMCCFILTR_EL0
# logarm  PMCCNTR_EL0
# logarm  PMCEID0_EL0
# logarm  PMCEID1_EL0
# logarm  PMCNTENCLR_EL0
# logarm  PMCNTENSET_EL0
# logarm  PMCR_EL0
# logarm  PMINTENCLR_EL1
# logarm  PMINTENSET_EL1
# logarm  PMOVSCLR_EL0
# logarm  PMOVSSET_EL0
# logarm  PMSELR_EL0
# logarm  PMSWINC_EL0
# logarm  PMUSERENR_EL0
# logarm  PMXEVCNTR_EL0
# logarm  PMXEVTYPER_EL0
  logarm  REVIDR_EL1
# logarm  RMR_EL1
# logarm  RMR_EL2
# logarm  RMR_EL3
# logarm  RVBAR_EL1
# logarm  RVBAR_EL2
# logarm  RVBAR_EL3
  logarm  SCR_EL3
  logarm  SCTLR_EL1
  logarm  SCTLR_EL2
  logarm  SCTLR_EL3
# logarm  SDER32_EL3
# logarm  SPSR_EL1
# logarm  SPSR_EL2
  logarm  SPSR_EL3
# logarm  SPSR_abt
# logarm  SPSR_fiq
# logarm  SPSR_irq
# logarm  SPSR_und
# logarm  SPSel
  logarm  SP_EL0
  logarm  SP_EL1
  logarm  SP_EL2
# logarm  TCR_EL1
# logarm  TCR_EL2
# logarm  TCR_EL3
# logarm  TPIDRRO_EL0
# logarm  TPIDR_EL0
# logarm  TPIDR_EL1
# logarm  TPIDR_EL2
# logarm  TPIDR_EL3
# logarm  TRBBASER_EL1
# logarm  TRBIDR_EL1
# logarm  TRBLIMITR_EL1
# logarm  TRBMAR_EL1
# logarm  TRBPTR_EL1
# logarm  TRBSR_EL1
# logarm  TRBTRG_EL1
# logarm  TRCAUTHSTATUS
# logarm  TRCAUXCTLR
# logarm  TRCBBCTLR
# logarm  TRCCCCTLR
# logarm  TRCCIDCCTLR0
# logarm  TRCCIDCCTLR1
# logarm  TRCCLAIMCLR
# logarm  TRCCLAIMSET
# logarm  TRCCONFIGR
# logarm  TRCDEVARCH
# logarm  TRCDEVID
# logarm  TRCEVENTCTL0R
# logarm  TRCEVENTCTL1R
# logarm  TRCIDR0
# logarm  TRCIDR1
# logarm  TRCIDR10
# logarm  TRCIDR11
# logarm  TRCIDR12
# logarm  TRCIDR13
# logarm  TRCIDR2
# logarm  TRCIDR3
# logarm  TRCIDR4
# logarm  TRCIDR5
# logarm  TRCIDR6
# logarm  TRCIDR7
# logarm  TRCIDR8
# logarm  TRCIDR9
# logarm  TRCIMSPEC0
# logarm  TRCOSLSR
# logarm  TRCPRGCTLR
# logarm  TRCQCTLR
# logarm  TRCRSR
# logarm  TRCSEQRSTEVR
# logarm  TRCSEQSTR
# logarm  TRCSTALLCTLR
# logarm  TRCSTATR
# logarm  TRCSYNCPR
# logarm  TRCTRACEIDR
# logarm  TRCTSCTLR
# logarm  TRCVICTLR
# logarm  TRCVIIECTLR
# logarm  TRCVIPCSSCTLR
# logarm  TRCVISSCTLR
# logarm  TRCVMIDCCTLR0
# logarm  TRCVMIDCCTLR1
# logarm  TTBR0_EL1
# logarm  TTBR0_EL2
# logarm  TTBR0_EL3
# logarm  TTBR1_EL1
# logarm  VBAR_EL1
# logarm  VBAR_EL2
# logarm  VBAR_EL3
# logarm  VDISR_EL2
# logarm  VMPIDR_EL2
# logarm  VPIDR_EL2
# logarm  VSESR_EL2
# logarm  VTCR_EL2
# logarm  VTTBR_EL2
.endif
  ldrb    w1, [x28, FLAGS-sysvars]                // w1 = [FLAGS].
  orr     w1, w1, #0x10                           // w1 = [FLAGS] with bit 4 set.
                                                  // [This bit is unused by 48K BASIC].
  strb    w1, [x28, FLAGS-sysvars]                // Update [FLAGS] to have bit 4 set.
  mov     w2, 0x000B                              // = 11; timing constant for 9600 baud. Maybe useful for UART?
  strh    w2, [x28, BAUD-sysvars]                 // [BAUD] = 0x000B
  strb    wzr, [x28, SERFL-sysvars]               // 0x5B61. Indicate no byte waiting in RS232 receive buffer.
  strb    wzr, [x28, COL-sysvars]                 // 0x5B63. Set RS232 output column position to 0.
  strb    wzr, [x28, TVPARS-sysvars]              // 0x5B65. Indicate no control code parameters expected.
  mov     w3, 0x50                                // Default to a printer width of 80 columns.
  strb    w3, [x28, WIDTH-sysvars]                // 0x5B64. Set RS232 printer output width.
  mov     w4, 0x000A                              // Use 10 as the initial renumber line and increment.
  strh    w4, [x28, RNFIRST-sysvars]              // Store the initial line number when renumbering.
  strh    w4, [x28, RNSTEP-sysvars]               // Store the renumber line increment.
  adrp    x5, heap
  add     x5, x5, #:lo12:heap                     // x5 = start of heap
  str     x5, [x28, CHANS-sysvars]                // [CHANS] = start of heap
  mov     x6, (initial_channel_info_END - initial_channel_info)/8
                                                  // x6 = number of double words (8 bytes) in initial_channel_info block
  adrp    x7, initial_channel_info
  add     x7, x7, :lo12:initial_channel_info
  // Loop to copy initial_channel_info block to [CHANS] = start of heap = heap
  3:
    ldr     x8, [x7], #8
    str     x8, [x5], #8
    subs    x6, x6, #1
    b.ne    3b
  sub     x9, x5, 1
  str     x9, [x28, DATADD-sysvars]
  str     x5, [x28, PROG-sysvars]
  str     x5, [x28, VARS-sysvars]
  mov     w10, 0x80
  strb    w10, [x5], 1
  str     x5, [x28, E_LINE-sysvars]
  mov     w11, 0x0D
  strb    w11, [x5], 1
  strb    w10, [x5], 1
  str     x5, [x28, WORKSP-sysvars]
  str     x5, [x28, STKBOT-sysvars]
  str     x5, [x28, STKEND-sysvars]
  mov     w12, 0x38
  strb    w12, [x28, ATTR_P-sysvars]
  strb    w12, [x28, ATTR_T-sysvars]
  strb    w12, [x28, BORDCR-sysvars]
  movl    w0, BORDER_COLOUR                       // w0 = default border colour
  bl      paint_border
  mov     w13, 0x0523                             // The values five and thirty five.
  strh    w13, [x28, REPDEL-sysvars]              // REPDEL. Set the default values for key delay and key repeat.
// Not translated the following instructions, since they may well need to work differently.
// TODO: check this after implementing keyboard reading routines
//   DEC  (IY-0x3A)     // Set KSTATE+0 to 0xFF.
//   DEC  (IY-0x36)     // Set KSTATE+4 to 0xFF.
  add     x5, x28, STRMS - sysvars
  mov     x6, (initial_stream_data_END - initial_stream_data)/2
                                                  // x6 = number of half words (2 bytes) in initial_stream_data block
  adr     x7, initial_stream_data
  // Loop to copy initial_stream_data block to [STRMS]
  4:
    ldrh    w8, [x7], #2
    strh    w8, [x5], #2
    subs    x6, x6, #1
    b.ne    4b
  ldrb    w0, [x28, FLAGS-sysvars]
  and     w0, w0, #~0x02
  strb    w0, [x28, FLAGS-sysvars]                // clear bit 1 of FLAGS (signal printer not in use)
  mov     w5, #0xff
  strb    w5, [x28, ERR_NR-sysvars]               // Signal no error.
  mov     w5, #0x02
  strb    w5, [x28, DF_SZ-sysvars]                // Set the lower screen size to two rows.
  bl      cls
// TODO: Commented out, since this method doesn't return unless a key is pressed, and we don't have keypress routines yet...
# bl      tv_tuner
  ldrb    w2, [x28, S_POSN_X_L-sysvars]
  sub     w2, w2, #0x28
  strb    w2, [x28, S_POSN_X_L-sysvars]
  ldr     x2, [x28, DF_CC_L-sysvars]
  add     x2, x2, #0x50
  str     x2, [x28, DF_CC_L-sysvars]

  adr     x2, msg_copyright
  bl      print_message
  mov     w5, #0x02
  strb    w5, [x28, DF_SZ-sysvars]                // Set the lower screen size to two rows.
  ldrb    w1, [x28, TV_FLAG-sysvars]
  orr     w1, w1, #0x20
  strb    w1, [x28, TV_FLAG-sysvars]              // set bit 5 of TV_FLAG (signal lower screen will require clearing)
// TODO: Check this - but I think swap stack routines aren't needed at all. On
// the 128K, I believe the stack is in the RAM page that gets paged out, and so
// it is forced to use separate stacks per RAM bank that gets paged in.
# add     x0, x28, TSTACK-sysvars
# str     x0, [x28, OLDSP-sysvars]
# bl      swap_stack
  mov     w0, #0x38
  strb    w0, [x28, EC11-sysvars]
  strb    w0, [x28, EC0F-sysvars]
  bl      init_mode
# bl      swap_stack
  b       main_menu


msg_rpi_model:
  .asciz "Raspberry Pi model: "

msg_rpi_revision:
  .asciz "Raspberry Pi revision: "

msg_midr_el1:
  .asciz "Register MIDR_EL1 value: "

msg_revidr_el1:
  .asciz "Register REVIDR_EL1 value: "
