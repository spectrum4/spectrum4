# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.arch armv8-a
.cpu cortex-a53

# Note, if we target just rpi4 / rpi400 later, we can change this as follows:
# .cpu cortex-a72

.global _start


.set SCREEN_WIDTH,     1920
.set SCREEN_HEIGHT,    1200
.set BORDER_LEFT,      96
.set BORDER_RIGHT,     96
.set BORDER_TOP,       128
.set BORDER_BOTTOM,    112

.set FIRST_UDG_CHAR,   'A'
.set UDG_COUNT,        21                         // Number of User Defined Graphics to copy (=> 'A'-'U').


.include "macros.s"


.text
.align 2
_start:

  mrs     x0, currentel
  and     x0, x0, #0x0c                           // Check if in EL3
  cmp     x0, #0x0c
  b.ne    sleep                                   // If not in EL3, halt - nothing more we can do.

  mrs     x0, mpidr_el1                           // x0 = Multiprocessor Affinity Register value.
  ands    x0, x0, #0x3                            // x0 = core number.
  b.ne    sleep                                   // Put all cores except core 0 to sleep.

  mrs     x0, s3_1_c11_c0_2                       // L2CTLR_EL1

                                                  // +=====================================+
                                                  // | L2CTLR_EL1 L2 Control Register, EL1 |
                                                  // +=====================================+
                                                  //
                                                  // rpi3b: https://developer.arm.com/documentation/ddi0500/j/System-Control/AArch64-register-descriptions/L2-Control-Register?lang=en
                                                  // rpi4b: https://developer.arm.com/documentation/100095/0003/System-Control/AArch64-register-descriptions/L2-Control-Register--EL1?lang=en
  mov     x1, #0x22
  orr     x0, x0, x1
  msr     s3_1_c11_c0_2, x0                       // set L2 read/write cache latency to 3

                                                  // +=================================================+
                                                  // | CPUECTLR_EL1 CPU Extended Control Register, EL1 |
                                                  // +=================================================+
                                                  //
                                                  // rpi3b: https://developer.arm.com/documentation/ddi0500/j/System-Control/AArch64-register-descriptions/CPU-Extended-Control-Register--EL1?lang=en
                                                  // rpi4b: https://developer.arm.com/documentation/100095/0003/System-Control/AArch64-register-descriptions/CPU-Extended-Control-Register--EL1?lang=en
                                                  //
                                                  //                                    D   L     L
                                                  //                                    T   2     2                                  S
                                                  //                                    W   I     L                                  M      P
                                                  //                                    D   F     D                                  P      D
                                                  //                                    A   P     P                                  E      R
                                                  //    0000 0000 0000 0000 0000 0000 0 P 0 D   0 D  0000 0000 0000 0000 0000 0000 0 N 00 0 C
                                                  //
                                                  //    6666/5555/5555/5544/4444/4444/3 3 3 3/3 3 33/3322/2222/2222/1111/1111/11
                                                  //    3210/9876/5432/1098/7654/3210/9 8 7 6/5 4 32/1098/7654/3210/9876/5432/1098/7 6 54/3 210
                                                  //
  mov     x0, 0x40                                // 0b 0000/0000/0000/0000/0000/0000/0 0 0 0/0 0 00/0000/0000/0000/0000/0000/0000/0 1 00/0 000
                                                  // 0x    0    0    0    0    0    0       0      0    0    0    0    0    0    0      4     0
                                                  //
                                                  // DTWDAP: 0b0   => Enable table walk descriptor access prefetch
                                                  // L2IFPD: 0b00  => L2 instruction fetch prefetch distance 0 requests (disables instruction prefetch)
                                                  // L2LDPD: 0b00  => L2 load data prefetch distance 16 requests
                                                  // SMPEN:  0b1   => Enables data coherency with other cores in the cluster (required also for single core)
                                                  // PDRC:   0b000 => Processor dynamic retention disabled
  msr     s3_1_c15_c2_1, x0

                                                  // +========================================+
                                                  // | SCTLR_EL1 System Control Register, EL1 |
                                                  // +========================================+
                                                  //
                                                  // rpi3b: https://developer.arm.com/documentation/ddi0500/j/System-Control/AArch64-register-descriptions/System-Control-Register--EL1?lang=en
                                                  // rpi4b: https://developer.arm.com/documentation/100095/0003/System-Control/AArch64-register-descriptions/System-Control-Register--EL1?lang=en
                                                  //
                                                  //                                                 C
                                                  //                                                 P
                                                  //                                                 1
                                                  //                        n   n                  T 5
                                                  //           U   E      W T   T U D        U S I H B S
                                                  //           C E 0      X W   W T Z        M E T E E A S
                                                  //    0011 0 I E E 1101 N E 0 I C E 0 I 10 A D D E N 0 A C A M
                                                  //
                                                  //    3322/2 2 2 2/2222/1 1 1 1/1 1 1 1/11
                                                  //    1098/7 6 5 4/3210/9 8 7 6/5 4 3 2/10 9 8/7 6 5 4/3 2 1 0
                                                  //
  ldr     x0, =0x30d0088a                         // 0b 0011/0 0 0 0/1101/0 0 0 0/0 0 0 0/10 0 0/1 0 0 0/1 0 1 0
                                                  // 0x    3       0    d       0       0      8       8       a
                                                  //
                                                  // UCI:     0b0 => EL0 access to DC CVAU, DC CIVAC, DC CVAC and IC IVAU disabled
                                                  // EE:      0b0 => Translation tables are little endian
                                                  // E0E:     0b0 => Data access are little endian
                                                  // WXN:     0b0 => Writable memory regions can also be executed
                                                  // nTWE:    0b0 => WFE instructions at EL0 are trapped (raise an exception)
                                                  // nTWI:    0b0 => WFI instructions at EL0 are trapped (raise an exception)
                                                  // UCT:     0b0 => Disables EL0 access to the CTR_EL0 register (cache information, read only) (security: side channel attacks)
                                                  // DZE:     0b0 => Disables execution access to the DC ZVA instruction at EL0 (clearing cache lines)
                                                  // I:       0b0 => Disable instruction cache
                                                  // UMA:     0b0 => Disable access to the interrupt masks from EL0
                                                  // SED:     0b0 => Disable SETEND instruction under aarch32 in EL0
                                                  // ITD:     0b1 => Disable Thumb IT instruction at EL0
                                                  // THEE:    0b0 => T32EE (Thumb big endian) not implemented on cortex-a53/cortex-a72 (effectively RES0)
                                                  // CP15BEN: 0b0 => CP15 barrier operations disabled in aarch32 in EL0
                                                  // SA0:     0b0 => Disable EL0 Stack Alignment (16 byte bounday) check
                                                  // SA:      0b1 => Enable Stack Alignment (16 byte bounday) check
                                                  // C:       0b0 => Data and unified caches disabled
                                                  // A:       0b1 => Enable alignment fault checking
                                                  // M:       0b0 => MMU disabled
  msr     sctlr_el1, x0

                                                  // +================================================+
                                                  // | HCR_EL2 Hypervisor Configuration Register, EL2 |
                                                  // +================================================+
                                                  //
                                                  // rpi3b: https://developer.arm.com/documentation/ddi0500/j/System-Control/AArch64-register-descriptions/Hypervisor-Configuration-Register?lang=en
                                                  // rpi4b: https://developer.arm.com/documentation/100095/0003/System-Control/AArch64-register-descriptions/Hypervisor-Configuration-Register--EL2?lang=en
                                                  //
                                                  //                                                                    T
                                                  //                                                T         T       T I   T T T T                          S
                                                  //                                                R H T T T T T T T A D T I I I I T T   B    V     A I F P W
                                                  //                                          I C R V C D G V L P P S C C S D D D D W W D S  F S V V M M M T I V
                                                  //    0000 0000 0000 0000 0000 0000 0000 00 D D W M D Z E M B U C W R P C 3 2 1 0 E I C U  B E I F O O O W O M
                                                  //
                                                  //    6666/5555/5555/5544/4444/4444/3333/33 3 3/3 3 2 2/2 2 2 2/2 2 2 2/1 1 1 1/1 1 1 1/11
                                                  //    3210/9876/5432/1098/7654/3210/9876/54 3 2/1 0 9 8/7 6 5 4/3 2 1 0/9 8 7 6/5 4 3 2/10 9 8/7 6 5 4/3 2 1 0
                                                  //
  mov     x0, 0x80000000                          // 0b 0000/0000/0000/0000/0000/0000/0000/00 0 0/1 0 0 0/0 0 0 0/0 0 0 0/0 0 0 0/0 0 0 0/00 0 0/0 0 0 0/0 0 0 0
                                                  // 0x    0    0    0    0    0    0    0      0       8       0       0       0       0      0       0       0
                                                  //
                                                  // ID:    0b0  => VM=0b0 so has no effect on stage 2 EL1/EL0 translation regime for instruction accesses
                                                  // CD:    0b0  => VM=0b0 so has no effect on stage 2 EL1/EL0 translation regime for data access or translation table walks
                                                  // RW:    0b1  => EL1 is AArch64, not AArch32
                                                  // TRVM:  0b0  => Non-secure EL1 memory reads are not trapped
                                                  // HCD:   0b0  => RES0 (Do not disable HYP call)
                                                  // TDZ:   0b0  => DC ZVA is not trapped
                                                  // TGE:   0b0  => Do not trap general exceptions
                                                  // TVM:   0b0  => Do not trap access to virtual memory registers
                                                  // TTLB:  0b0  => Do not trap TLB maintenance instructions
                                                  // TPU:   0b0  => Do not trap cache maintenance instructions to Point of Unification
                                                  // TPC:   0b0  => Do not trap data/unified cache maintenance operations to Point of Coherency
                                                  // TSW:   0b0  => Do not trap Data/Unified Cache maintenance operations by Set/Way
                                                  // TACR:  0b0  => Do not trap accesses to ACTLR_EL1
                                                  // TIDCP: 0b0  => Do not trap Implementation Dependent functionality
                                                  // TSC:   0b0  => Do not trap SMC instruction
                                                  // TID3:  0b0  => Do not trap ID Group 3 registers
                                                  // TID2:  0b0  => Do not trap ID Group 2 registers
                                                  // TID1:  0b0  => Do not trap ID Group 1 registers
                                                  // TID0:  0b0  => Do not trap ID Group 0 registers
                                                  // TWE:   0b0  => Do not trap WFE instruction
                                                  // TWI:   0b0  => Do not trap WFI instruction
                                                  // DC:    0b0  => Don't enable Default Cachable behaviour
                                                  // BSU:   0b00 => Barrier sharability disabled
                                                  // FB:    0b0  => Do not broadcast instructions within Inner Sharable domain
                                                  // VSE:   0b0  => Virtual Async Abort / SError not pending
                                                  // VI:    0b0  => Virtual IRQ not pending
                                                  // VF:    0b0  => Virtual FIQ not pending
                                                  // AMO:   0b0  => Async external Aborts and SError interrupts not taken to EL2
                                                  // IMO:   0b0  => Physical IRQ are not taken to EL2
                                                  // FMO:   0b0  => Physical FIQ are not taken to EL2
                                                  // PTW:   0b0  => Protected table walk; doesn't apply since VM = 0b0
                                                  // SWIO:  0b0  => DC ISW is not treated as DC CISW in AArch64 state
                                                  // VM:    0b0  => Disable second stage MMU address translation
  msr     hcr_el2, x0

##################################################
# We are in EL3
# Move from EL3 to EL1 directly (skip EL2)


                                                  // +============================================+
                                                  // | SCR_EL3 Secure Configuration Register, EL3 |
                                                  // +============================================+
                                                  //
                                                  // rpi3b: https://developer.arm.com/documentation/ddi0500/j/System-Control/AArch64-register-descriptions/Secure-Configuration-Register?lang=en
                                                  // rpi4b: ???
                                                  //
                                                  //                           T T     S H S       F I
                                                  //                           W W S R I C M     E I R N
                                                  //    0000 0000 0000 0000 00 E I T W F E D 011 A Q Q S
                                                  //
                                                  //    3322/2222/2222/1111/11 1 1/1 1
                                                  //    1098/7654/3210/9876/54 3 2/1 0 9 8/7 654/3 2 1 0
                                                  //
  mov     x0, 0x00000431                          // 0b 0000/0000/0000/0000/00 0 0/0 1 0 0/0 011/0 0 0 1
                                                  // 0x    0    0    0    0      0       4     3       1
                                                  //
                                                  // TWE: 0b0 => WFE instructions are not trapped
                                                  // TWI: 0b0 => WFI instructions are not trapped
                                                  // ST:  0b0 => No Secure EL1 access to CNTPS_TVAL_EL1, CNTS_CTL_EL1, and CNTPS_CVAL_EL1 registers
                                                  // RW:  0b1 => The next lower level (EL2) is AArch64
                                                  // SIF: 0b0 => Secure state instruction fetches from Non-secure memory are permitted
                                                  // HCE: 0b0 => The HVC instruction is undefined at all exception levels
                                                  // SMD: 0b0 => The SMC instruction is enabled at EL1, EL2, and EL3
                                                  // EA:  0b0 => External Abort and SError at EL0-EL2 are not taken in EL3
                                                  // FIQ: 0b0 => Physical FIQ at EL0-EL2 are not taken in EL3
                                                  // IRQ: 0b0 => Physical IRQ at EL0-EL2 are not taken in EL3
                                                  // NS:  0b1 => EL0 and EL1 are in Non-secure state
  msr     scr_el3, x0

                                                  // +=============================================+
                                                  // | SPSR_EL3 Saved Program Status Register, EL3 |
                                                  // +=============================================+
                                                  //
                                                  // rpi3b/rpi4b: https://developer.arm.com/documentation/ddi0601/2024-12/AArch64-Registers/SPSR-EL3--Saved-Program-Status-Register--EL3-?lang=en
                                                  //
                                                  //                                          E                                    A                  M
                                                  //                                          X P                                  L   B              [
                                                  //                                      U P L P                                  L S T            M 3
                                                  //                                      I A O E              T D U P             I S Y            [ :
                                                  //                                      N C C N P            C I A A S I         N B P            4 0
                                                  //    0000 0000 0000 0000 0000 0000 000 J M K D M N Z C V 00 O T O N S L 0000 00 T S E  D A I F 0 ] ]
                                                  //
                                                  //    6666 5555 5555 5544 4444 4444 333 3 3 3 3 3 3 3 2 2 22 2 2 2 2 2 2 1111 11 1 1 11
                                                  //    3210 9876 5432 1098 7654 3210 987 6 5 4 3 2 1 0 9 8 76 5 4 3 2 1 0 9876 54 3 2 10 9 8 7 6 5 4 3210
                                                  //
  mov     x0, 0x000001c5                          // 0b 0000/0000/0000/0000/0000/0000/000 0/0 0 0 0/0 0 0 0/00 0 0/0 0 0 0/0000/00 0 0/00 0 1/1 1 0 0/0101
                                                  // 0x    0    0    0    0    0    0     0       0       0      0       0    0      0      1       c    5
                                                  //
                                                  // UINJ:    0b0     => RES0 since FEAT_UINJ was first optional in Armv9.0 (Undefined Instruction Injection)
                                                  // PACM:    0b0     => RES0 since FEAT_PAuth_LR was first optional in Armv9.4 (Pointer authentication instructions allowing signing of LR using SP and PC)
                                                  // EXLOCK:  0b0     => RES0 since FEAT_GCS was first optional in Armv9.3 (Guarded Control Stack Extension)
                                                  // PPEND:   0b0     => RES0 since FEAT_SEBEP was first optional in Armv9.3 (Synchronous Exception-based Event Profiling)
                                                  // PM:      0b0     => RES0 since FEAT_EBEP was first optional in Armv9.3 (Exception-based Event Profiling)
                                                  // N:       0b0     => set PSTATE.N to 0b0 after next eret
                                                  // Z:       0b0     => set PSTATE.Z to 0b0 after next eret
                                                  // C:       0b0     => set PSTATE.C to 0b0 after next eret
                                                  // V:       0b0     => set PSTATE.V to 0b0 after next eret
                                                  // TCO:     0b0     => RES0 since FEAT_MTE4 was first optional in Armv8.7 (Enhanced Memory Tagging Extension)
                                                  // DIT:     0b0     => RES0 since FEAT_DIT was first optional in Armv8.3 (Data Independent Timing)
                                                  // UAO:     0b0     => RES0 since FEAT_UAO was first optional in Armv8.1 (Unprivileged Access Override)
                                                  // PAN:     0b0     => RES0 since FEAT_PAN is optional but not present in Cortex-A53/Cortex-A72 (ID_AA64MMFR1_EL1 = 0x0) (Privileged Access Never)
                                                  // SS:      0b0     => conditially set PSTATE.SS to 0b0 after next eret (not sure what condition)
                                                  // IL:      0b0     => set PSTATE.IL to 0b0 after next eret (clear illegal execution exception state)
                                                  // ALLINT:  0b0     => RES0 since FEAT_NMI was first optional in Armv8.7 (Non-maskable Interrupts)
                                                  // SSBS:    0b0     => RES0 since FEAT_SSBS is optional but not present in Cortex-A53/Cortex-A72 (ID_AA64PFR1_EL1 = 0x0) (Speculative Store Bypass Safe)
                                                  // BTYPE:   0b0     => RES0 since FEAT_BTI was first optional in Armv8.4 (Branch Target Identification)
                                                  // D:       0b0     => set PSTATE.D to 0b0 after next eret => after eret mask (disable) debug interrupts
                                                  // A:       0b1     => set PSTATE.A to 0b1 after next eret => after eret mask (disable) error (SError) interrupts
                                                  // I:       0b1     => set PSTATE.I to 0b1 after next eret => after eret mask (disable) regular (IRQ) interrupts
                                                  // F:       0b1     => set PSTATE.F to 0b1 after next eret => after eret mask (disable) fast (FIQ) interrupts
                                                  // M[4]:    0b0     => set PSTATE.nRW to 0b0 after next eret => after eret remain in AArch64 execution state
                                                  // M[3:0]:  0b0101  => after next eret enter EL1 directly (i.e. skip EL2) with dedicated stack pointer SP=SP_EL1 (EL1h)
  msr     spsr_el3, x0

  adr     x0, 1f
  msr     elr_el3, x0                             // Update Exception Link Register (EL3):
                                                  //   set to return address after next `eret`
  eret
# Move from EL3 to EL1 completed
##################################################

1:
  bl      set_peripherals_addresses
  bl      set_clocks
  bl      init_rpi_model                          // Fetch raspberry pi model identifier into system variable rpi_model.
  bl      init_framebuffer                        // Allocate a frame buffer with chosen screen settings.

# Configure page tables
  adrp    x0, pg_dir                              // x0 = pg_dir (page aligned, so no additional add needed)
  mov     x1, pg_dir_end - pg_dir                 // clear 6 pages
  bl      memzero
  adrp    x0, pg_dir
  mov     x1, #0x1003
  add     x1, x0, x1
  ldr     x3, peripherals_end
  sub     x3, x3, #0x1
  lsr     x2, x3, #30
  add     x2, x2, #0x1
  2:
    str     x1, [x0], #8                          // [pg_dir + i*8] = pg_dir + 0x1003 + i*0x1000. PUD table complete for 0 - peripherals_end.
    add     x1, x1, #0x1000
    subs    x2, x2, #0x1
    b.ne    2b
  adrp    x0, (pg_dir+0x1000)
  mov     x1, #0x401                              // bit 10: AF=1, bits 2-4: mair attr index = 0 (normal), bits 0-1: 1 (block descriptor)
  ldr     w2, arm_size
  3:                                              // creates 2016 entries for 0x00000000 - 0xfc000000
    str     x1, [x0], #8                          // [pg_dir + 0x1000 + i*8] = 0x401 + i*0x200000. PMD table entries complete for 0 - arm_size address.
    add     x1, x1, #0x200000
    cmp     x1, x2
    b.lt    3b
  add     x1, x1, #0x4                            // bits 2-4: mair attr index = 1 (device)
  4:                                              // creates 32 entries for 0xfc000000 - 0x100000000
    str     x1, [x0], #8                          // [pg_dir + 0x1000 + i*8] = 0x405 + i*0x200000. PMD table entries complete for arm_size to peripherals_end address.
    add     x1, x1, #0x200000
    cmp     x1, x3
    b.lt    4b
  ldr     x0, pcie_init                           // Is PCIe available?
  cbz     x0, 6f                                  // Skip mapping xHCI region if no PCIe
  adrp    x0, pg_dir
  adrp    x1, (pg_dir+0x5000)
  orr     x2, x1, #0b11                           // bit 0 = 1 => valid descriptor. bit 1 = 1 => table descriptor
  str     x2, [x0, 0xc0]                          // [pg_dir+0x10c0] = pg_dir+0x6003. PUD table entry for xHCI region (entry 0x600000000-0x640000000 covers more than xHCI).
  mov     x2, 0x600000000                         // x2 = xHCI start (24GB)
  orr     x3, x2, 0x40000000                      // x3 = xHCI end (1GB higher) (0x640000000) - so we will fill entire table, i.e. all 512 entries
  add     x2, x2, #0x409                          // bit 10: AF=1, bits 2-4: mair attr index = 2 (coherent), bits 0-1: 1 (block descriptor)
  5:                                              // creates 512 entries for xHCI addresses 0x600000000 - 0x640000000
    str     x2, [x1], #8                          // [pg_dir + 0x6000 + i*8] = 0x409 + i*0x200000. PMD table entries complete for xHCI region.
    add     x2, x2, #0x200000
    cmp     x2, x3
    b.lt    5b
6:
  dsb     sy                                      // Data Sync Barrier
  adrp    x0, pg_dir
  msr     ttbr1_el1, x0                           // Configure page tables for virtual addresses with 1's in first 28 bits
  msr     ttbr0_el1, x0                           // Configure page tables for virtual addresses with 0's in first 28 bits
                                                  // This seems to be needed on qemu so that when sctlr_el1 is updated
                                                  // below, that the following instruction can be fetched since at this
                                                  // point, the program counter is using a physical address. On rpi3 this
                                                  // instruction seems not to be needed, for whatever reason.

                                                  // +===========================================+
                                                  // | TCR_EL1 Translation Control Register, EL1 |
                                                  // +===========================================+
                                                  //
                                                  // rpi3b: https://developer.arm.com/documentation/ddi0500/j/System-Control/AArch64-register-descriptions/Translation-Control-Register--EL1?lang=en
                                                  // rpi4b: https://developer.arm.com/documentation/100095/0003/System-Control/AArch64-register-descriptions/Translation-Control-Register--EL1?lang=en
                                                  //
                                                  //                                                      O  I                    O  I
                                                  //                                    T T               R  R  E                 R  R  E
                                                  //                                    B B         T  S  G  G  P           T  S  G  G  P
                                                  //                                    I I A       G  H  N  N  D A         G  H  N  N  D
                                                  //    0000 0000 0000 0000 0000 0000 0 1 0 S 0 IPS 1  1  1  1  1 1 T1SZ___ 0  0  0  0  0 0 T0SZ___
                                                  //
                                                  //    6666 5555 5555 5544 4444 4444 3 3 3 3 3 333 33 22 22 22 2 2 22 1111 11 11 11
                                                  //    3210 9876 5432 1098 7654 3210 9 8 7 6 5 432 10 98 76 54 3 2 10 9876 54 32 10 98 7 6 54 3210
                                                  //
  ldr     x0, =0x00000001b51c351c                 // 0b 0000/0000/0000/0000/0000/0000/0 0 0 0/0 001/10 11/01 01/0 0 01/1100/00 11/01 01/0 0 01/1100
                                                  // 0x    0    0    0    0    0    0       0     1     b     5      1    c     3     5      1    c
                                                  //
                                                  // TBI1:    0b0      => top byte of input address used for address match for the TTBR1_EL1 region
                                                  // TBI0:    0b0      => top byte of input address used for address match for the TTBR0_EL1 region
                                                  // AS:      0b0      => ASID size is 8 bit (not 16 bit)
                                                  // IPS:     0b001    => Intermediate Physical Address size = 36 bits, 64GB
                                                  // TG1:     0b10     => 4KB granule size for the TTBR1_EL1 region
                                                  // SH1:     0b11     => Inner shareable memory for memory associated with TTBR1_EL1 translation table walks
                                                  // ORGN1:   0b01     => Normal memory, Outer Write-Back Write-Allocate Cacheable for memory associated with TTBR1_EL1 translation table walks
                                                  // IRGN1:   0b01     => Normal memory, Inner Write-Back Write-Allocate Cacheable for memory associated with TTBR1_EL1 translation table walks
                                                  // EPD1:    0b0      => perform translation table walks using TTBR1_EL1 on TLB miss
                                                  // A1:      0b0      => TTRB0_EL1.ASID defines the ASID (not TTBR1_EL1.ASID)
                                                  // T1SZ:    0b011100 => TTBR1_EL1 region size = 2^(64-28) = 2^36 bytes = 64GB
                                                  // TG0:     0b00     => 4KB granule size for the TTBR0_EL1 region
                                                  // SH0:     0b11     => Inner shareable memory for memory associated with TTBR0_EL1 translation table walks
                                                  // ORGN0:   0b01     => Normal memory, Outer Write-Back Write-Allocate Cacheable for memory associated with TTBR0_EL1 translation table walks
                                                  // IRGN0:   0b01     => Normal memory, Inner Write-Back Write-Allocate Cacheable for memory associated with TTBR0_EL1 translation table walks
                                                  // EPD0:    0b0      => perform translation table walks using TTBR0_EL1 on TLB miss
                                                  // T0SZ:    0b011100 => TTBR0_EL1 region size = 2^(64-28) = 2^36 bytes = 64GB
  msr     tcr_el1, x0

  ldr     x0, =0x000004ff
  msr     mair_el1, x0                            // mair_el1 = 0x00000000000004ff => attr index 0 => normal, attr index 1 => device, attr index 2 => coherent
  ldr     x2, =7f                                 // use ldr x2, =<label> to make sure not to get relative address (could also just orr top 16 bits)
  mrs     x0, sctlr_el1                           // fetch System Control Register (EL1)
  mov     x1, #0x1005
  orr     x0, x0, x1                              // enable MMU (0x1), data cache (0x4) and instruction cache (0x1000)
  msr     sctlr_el1, x0                           // update System Control Register (EL1)
  dsb     sy
  isb
  br      x2                                      // jump to next instruction so that program counter starts using virtual address
7:
  msr     ttbr0_el1, xzr                          // Ensure only ttbr1_el1 is used from now on
  adrp    x28, sysvars
  add     x28, x28, :lo12:sysvars                 // x28 will remain at this constant value to make all sys vars available via an immediate offset.
.if UART_DEBUG
  bl      uart_init                               // Initialise UART interface.
.endif
  ldr     x0, rand_init
  blr     x0
.if TESTS_AUTORUN
  ldr     w0, arm_size
  orr     x0, x0, 0xfffffff000000000              // Convert to virtual address
  and     sp, x0, #~0xf                           // Set stack pointer at top of ARM memory
  bl      irq_vector_init
  bl      timer_init
  ldr     x0, enable_ic
  blr     x0
  bl      enable_irq
  ldr     x0, pcie_init
  cbz     x0, 8f
  blr     x0
8:
  bl      fill_memory_with_junk
  bl      run_tests
.endif
.if ROMS_AUTORUN
  b       restart                                 // Raspberry Pi initialisation complete.
                                                  // Now call entry point in rom0.s which
                                                  // is the converted ZX Spectrum 128k code.
.endif

sleep:
  msr     daifset, #0x3
1:
  dsb     sy
  wfi                                             // Sleep until woken.
  b       1b


init_rpi_model:
  adr     x0, rpi_model_req                       // x0 = memory block pointer for mailbox call to get rpi model identifier
  mov     x27, x30                                // preserve link register in x27
  bl      mbox_call
  ret     x27


init_framebuffer:
  adr     x0, fb_req                              // x0 = memory block pointer for mailbox call.
  mov     x27, x30
  bl      mbox_call
  ldr     w11, [x0, framebuffer-fb_req]           // w11 = allocated framebuffer address
  and     w11, w11, #0x3fffffff                   // Translate bus address to physical ARM address.
  str     w11, [x0, framebuffer-fb_req]           // Store framebuffer address in framebuffer system variable.
  ret     x27


# Memory block for Raspberry Pi model identifier mailbox call
.align 4
rpi_model_req:
  .word (rpi_model_req_end-rpi_model_req)         // Buffer size
  .word 0                                         // Request/response code
  .word 0x00010001                                // Tag 0 - Get board model
  .word 4                                         //   value buffer size (response > request, so use response size)
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
// On my Raspberry Pi 3 Model B, rpi_model = 0x0
rpi_model:
  .word 0                                         //   request: padding              response: model identifier
  .word 0x00010002                                // Tag 1 - Get board revision
  .word 4                                         //   value buffer size (response > request, so use response size)
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)


                                                  // +=============================+
                                                  // | Raspberry Pi Revision Codes |
                                                  // +=============================+
                                                  //
                                                  // https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#new-style-revision-codes-in-use
                                                  //
                                                  //
                                                  // My Raspberry Pi 3 Model B
                                                  // =========================
                                                  //
                                                  //    N O Q 0 00 W 0 F M__ C___ P___ T________ R___
                                                  //
                                                  //    3 3 2 2 22 2 2 2 222 1111 1111 11
                                                  //    1 0 9 8 76 5 4 3 210 9876 5432 1098 7654 3210
                                                  //
                                                  // 0b 0 0 0 0/00 0 0/1 010/0000/0010/0000/1000/0010
                                                  // 0x       0      0     a    0    2    0    8    2
                                                  //
                                                  // N: 0b0         => Overvoltage allowed
                                                  // O: 0b0         => OTP programming allowed
                                                  // Q: 0b0         => OTP reading allowed
                                                  // W: 0b0         => Warranty is intact
                                                  // F: 0b1         => New style revision code
                                                  // M: 0b010       => Memory size 1GB (0x10000000 << 0b010)
                                                  // C: 0b0000      => Manufacturer: Sony UK
                                                  // P: 0b0010      => Processor: BCM2837
                                                  // T: 0b0000 1000 => Type: 3B
                                                  // R: 0b0010      => Revision: 2
                                                  //
                                                  //
                                                  // My Raspberry Pi 400, 4GB
                                                  // ========================
                                                  //
                                                  //    N O Q 0 00 W 0 F M__ C___ P___ T________ R___
                                                  //
                                                  //    3 3 2 2 22 2 2 2 222 1111 1111 11
                                                  //    1 0 9 8 76 5 4 3 210 9876 5432 1098 7654 3210
                                                  //
                                                  // 0b 0 0 0 0/00 0 0/1 100/0000/0011/0001/0011/0000
                                                  // 0x       0      0     c    0    3    1    3    0
                                                  //
                                                  // N: 0b0         => Overvoltage allowed
                                                  // O: 0b0         => OTP programming allowed
                                                  // Q: 0b0         => OTP reading allowed
                                                  // W: 0b0         => Warranty is intact
                                                  // F: 0b1         => New style revision code
                                                  // M: 0b100       => Memory size 4GB (0x10000000 << 0b100)
                                                  // C: 0b0000      => Manufacturer: Sony UK
                                                  // P: 0b0011      => Processor: BCM2711
                                                  // T: 0b0001 0011 => Type: 400
                                                  // R: 0b0000      => Revision: 0
rpi_revision:
  .word 0                                         //   request: padding              response: revision identifier
  .word 0                                         // End Tags
rpi_model_req_end:


# Memory block for GPU mailbox call to allocate framebuffer
.align 4
fb_req:
  .word (fb_req_end-fb_req)                       // Buffer size
  .word 0                                         // Request/response code
  .word 0x00048003                                // Tag 0 - Set Screen Size
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                              //   request: width                response: width
  .word SCREEN_HEIGHT                             //   request: height               response: height
  .word 0x00048004                                // Tag 1 - Set Virtual Screen Size
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                              //   request: width                response: width
  .word SCREEN_HEIGHT                             //   request: height               response: height
  .word 0x00048009                                // Tag 2 - Set Virtual Offset
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                         //   request: x offset             response: x offset
  .word 0                                         //   request: y offset             response: y offset
  .word 0x00048005                                // Tag 3 - Set Colour Depth
  .word 4                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
                                                  //                   32 bits per pixel => 8 red, 8 green, 8 blue, 8 alpha
                                                  //                   See https://en.wikipedia.org/wiki/RGBA_color_space
  .word 32                                        //   request: bits per pixel       response: bits per pixel
  .word 0x00048006                                // Tag 4 - Set Pixel Order (really is "Colour Order", not "Pixel Order")
  .word 4                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                         //   request: 0 => BGR, 1 => RGB   response: 0 => BGR, 1 => RGB
  .word 0x00040001                                // Tag 5 - Get (Allocate) Buffer
  .word 8                                         //   value buffer size (response > request, so use response size)
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
framebuffer:
  .word 4096                                      //   request: alignment in bytes   response: frame buffer base address
  .word 0                                         //   request: padding              response: frame buffer size in bytes
  .word 0x00040008                                // Tag 6 - Get Pitch (bytes per line)
  .word 4                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
pitch:
  .word 0                                         //   request: padding              response: bytes per line
  .word 0x00010005                                // Tag 7 - Get ARM memory
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
arm_base:
  .word 0                                         //   request: padding              response: base address in bytes
arm_size:
  .word 0                                         //   request: padding              response: size in bytes
  .word 0                                         // End Tags
fb_req_end:


# On entry:
#   x0 = address of mailbox request
# On exit:
#   x0 unchanged
#   x9 corrupted
#   x10 corrupted
#   x11 corrupted
#   x12 corrupted
.align 2
mbox_call:
  dsb     sy                                      // Data Sync Barrier, probably not needed since we always pass statically initialised data
  ldr     x9, mailbox_base                        // x9 = [mailbox_base] (Mailbox Peripheral Address) = 0xfffffff03f00b880 (rpi3) or 0xfffffff0fe00b880 (rpi4)
  lsr     x12, x0, #36                            // Copy upper 28 bits from x0 to x9 since kernel might be high or low depending on whether
  bfi     x9, x12, #36, #28                       // MMU has been enabled already or not.
1:                                                // Wait for mailbox FULL flag to be clear.
  ldr     w10, [x9, #0x18]                        // w10 = mailbox status.
  tbnz    w10, 31, 1b                             // If FULL flag set (bit 31), try again...
  mov     w11, 8                                  // Mailbox channel 8.
  orr     w11, w0, w11                            // w11 = encoded request address + channel number.
  str     w11, [x9, #0x20]                        // Write request address / channel number to mailbox write register.
2:                                                // Wait for mailbox EMPTY flag to be clear.
  ldr     w12, [x9, #0x18]                        // w12 = mailbox status.
  tbnz    w12, 30, 2b                             // If EMPTY flag set (bit 30), try again...
  ldr     w12, [x9]                               // w12 = message request address + channel number.
  cmp     w11, w12                                // See if the message is for us.
  b.ne    2b                                      // If not, try again.
  dmb     sy                                      // Data Memory Barrier
  ret


# On entry:
#   x0 = address
#   w1 = 8 bit value
poke_address:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack
  stp     x23, x24, [sp, #-16]!                   // Backup x23 / x24 on stack
  strb    w1, [x0]                                // Poke address
  adrp    x9, display_file                        // Check if address is in display file
  add     x9, x9, :lo12:display_file
  adrp    x24, attributes_file
  add     x24, x24, :lo12:attributes_file
  subs    x11, x0, x9                             // x11 = display file offset
  b.lo    2f                                      // if x0 < x9, jump ahead since before display file
  adrp    x10, display_file_end                   // Now compare address to upper limit of display file
  add     x10, x10, :lo12:display_file_end
  cmp     x0, x10
  b.hs    2f                                      // if x0 >= x10 (display file end) jump ahead since after display file
// x0 in display file
  // framebuffer addresses = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4 * (BORDER_LEFT + 8*(x11%216) + [0-7])
  // attribute address = attributes_file+((x11/2)%108)+108*(((x11/216)%20)+20*(x11/(216*20*16)))
  adrp    x9, fb_req                              // x9 = address of mailbox request.
  add     x9, x9, :lo12:fb_req
  ldr     w10, [x9, framebuffer-fb_req]           // w10 = physical address of framebuffer
  orr     x10, x10, #0xfffffff000000000           // x10 = virtual address of framebuffer
  ldr     w12, [x9, pitch-fb_req]                 // w12 = pitch
  ldr     x13, =0x97b425ed097b425f                // x13 = 0x97b425ed097b425f = 10931403895531586143
  umulh   x14, x13, x11                           // x14 = (10931403895531586143 * x11) / 18446744073709551616 = int(x11*16/27)
  lsr     x14, x14, #7                            // x14 = int(x11/216)
  mov     x15, #0xcccccccccccccccc
  add     x15, x15, #1                            // x15 = 0x0xcccccccccccccccd
  umulh   x16, x15, x14                           // x16 = 14757395258967641293 * int(x11/216) / 2^64 = (4/5) * int(x11/216)
  lsr     x16, x16, #4                            // x16 = int(int(x11/216)/20)
  add     x16, x16, x16, lsl #2                   // x16 = 5 * int(int(x11/216)/20)
  sub     x16, x14, x16, lsl #2                   // x16 = int(x11/216) - 20 * int(int(x11/216)/20) = (x11/216)%20
  ldr     x17, =0xf2b9d6480f2b9d65                // x17 = 0xf2b9d6480f2b9d65 = 17490246232850537829
  umulh   x18, x17, x11                           // x18 = 17490246232850537829 * x11 / 2^64 = int(x11*128/135)
  ubfx    x19, x18, #12, #4                       // x19 = bits 12-15 of int(x11*128/135) = (x11/(216*20)) % 16
  add     x19, x19, x16, lsl #4                   // x19 = (x11/(216*20))%16 + 16*((x11/216)%20)
  lsr     x18, x18, #16                           // x18 = int(x11/(216*20*16))
  add     x18, x18, x18, lsl #2                   // x18 = 5*int(x11/(216*20*16))
  add     x19, x19, x18, lsl #6                   // x19 = (x11/(216*20))%16 + 16*((x11/216)%20) + 320*int(x11/216*20*16)
  add     x19, x19, BORDER_TOP                    // x19 = BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))
  umaddl  x19, w19, w12, x10                      // x19 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer
  mov     x20, #0xd8                              // x20 = 216
  msub    x21, x20, x14, x11                      // x21 = x11 - int(x11/216)*216 = x11%216
  mov     x22, BORDER_LEFT
  add     x22, x22, x21, lsl #3                   // x22 = BORDER_LEFT + 8*(x11%216)
  add     x23, x19, x22, lsl #2                   // x23 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4*(BORDER_LEFT + 8*(x11%216))
  lsr     x10, x11, #1                            // x10 = int(x11/2)
  umulh   x14, x13, x10                           // x14 = int(int(x11/2)*16/27)
  lsr     x14, x14, #6                            // x14 = int(x11/216)
  mov     x12, #0x6c                              // x12 = 108
  msub    x10, x12, x14, x10                      // x10 = int(x11/2)-108*int((x11/2)/108)=(x11/2)%108
  add     x16, x16, x18, lsl #2                   // x16 = (x11/216)%20+20*int(x11/(216*20*16))
  madd    x16, x16, x12, x10                      // x16 = 108*(((x11/216)%20+20*int(x11/(216*20*16))) + (x11/2)%108
  ldrb    w17, [x24, x16]                         // w17 = attribute data
  mov     w20, #0xcc                              // dim
  mov     w21, #0xff                              // bright
  tst     w17, #0x40                              // bright set?
  csel    w22, w20, w21, eq                       // x22 = brightness
// w15 = foreground colour
  tst     w17, #0x02                              // red set?
  csel    w13, wzr, w22, eq
  tst     w17, #0x04                              // green set?
  csel    w14, wzr, w22, eq
  tst     w17, #0x01                              // blue set?
  csel    w15, wzr, w22, eq
  add     w15, w15, w14, lsl #8
  add     w15, w15, w13, lsl #16
// w7 = background colour
  tst     w17, #0x10                              // red set?
  csel    w5, wzr, w22, eq
  tst     w17, #0x20                              // green set?
  csel    w6, wzr, w22, eq
  tst     w17, #0x08                              // blue set?
  csel    w7, wzr, w22, eq
  add     w7, w7, w6, lsl #8
  add     w7, w7, w5, lsl #16
  mov     w8, #8
  1:
    tst     x1, #0x80                             // pixel set?
    csel    w3, w7, w15, eq
    str     w3, [x23], #4
    lsl     w1, w1, #1
    subs    w8, w8, #1
    b.ne    1b
  b       4f
2:
  subs    x11, x0, x24                            // x11 = attributes file offset
  b.lo    4f                                      // if x0 < x24, jump ahead since before attributes file
  adrp    x10, attributes_file_end                // Now compare address to upper limit of attributes file
  add     x10, x10, :lo12:attributes_file_end
  cmp     x0, x10
  b.hs    4f                                      // if x0 >= x10 (attributes file end), jump ahead since after attributes file
// x0 in attributes file
  // TODO: rewrite this section to be more efficient (don't call poke_address recursively)
  add     x10, x9, x11, lsl #1                    // x10 = disp base address + attr offset * 2
  mov     x8, #64800                              // x8 = 216 * 20 * 15
  cmp     x11, #2160                              // x11 >= 108 * 20? (=> attribute in section 1/2)
  csel    x12, x8, xzr, hs                        // If attribute address in section 0, x12 = 0 else 216*20*15
  add     x10, x10, x12                           // If attribute address in section 0 or 1, x10 = display address of top left pixel
  mov     x3, #4320                               // x3 = 108 * 20 * 2 (attribute offset section 2)
  cmp     x11, x3                                 // x11 >= 108 * 20 * 2? (=> attribute in section 2)
  csel    x12, x8, xzr, hs                        // If attribute address in section 0/1, x12 = 0 else 216*20*15
  add     x0, x10, x12                            // x0 = display address of top left pixel
  mov     x3, #16                                 // x3 = pixel row counter (16 -> 0)
  3:
    stp     x3, x0, [sp, #-16]!
    ldrb    w1, [x0]
    bl      poke_address                          // refresh left 8 pixels
    ldp     x3, x0, [sp]
    add     x0, x0, #1                            // next  address
    ldrb    w1, [x0]
    bl      poke_address                          // refresh right 8 pixels
    ldp     x3, x0, [sp], #16
    add     x0, x0, #4000
    add     x0, x0, #320                          // bump x0 by 216*20 - start of next pixel row for current character
    subs    x3, x3, #1                            // decrement counter
    b.ne    3b                                    // repeat until 16 pixel rows updated for current character
4:
  ldp     x23, x24, [sp], #0x10                   // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Wait (at least) x0 instruction cycles.
# ------------------------------------------------------------------------------
wait_cycles:
  subs    x0, x0, #0x1                            // x0 -= 1
  b.ne    wait_cycles                             // Repeat until x0 == 0.
  ret                                             // Return.


# ------------------------------------------------------------------------------
# Wait x0 microseconds
#
# On exit:
#   x0 corrupted
#   x1 corrupted
#   x2 corrupted
#   x3 corrupted
# ------------------------------------------------------------------------------
wait_usec:
  isb                                             // Instruction Sync Barrier - Circle has this, not sure why
  mrs     x1, cntpct_el0                          // Physical count value in all 64 bits
  ldr     x2, =0x431bde82d7b634db                 // 4835703278458516699
  ldr     w3, cntfrq                              // We don't use https://github.com/raspberrypi/tools/blob/master/armstubs/armstub8.S
                                                  // so ARM register cntfrq_el0 is not set for us. Since we are in EL1 when we know if
                                                  // we are on rpi3b or rpi4/rpi400 we can't update cntfrq_el0 (need to be in EL3 to
                                                  // update it) so we have this value in RAM instead.
  mul     x0, x0, x3                              // x0 = entry x0 * clock frequency
  umulh   x0, x0, x2                              // x0 = entry x0 * clock frequency * 4835703278458516699
  lsr     x0, x0, #18                             // x0 = entry x0 * clock frequency * 4835703278458516699 / 4835703278458516698824704
                                                  //    = entry x0 * clock frequency / 1,000,000
                                                  //    = number of oscillations to wait
  1:
    mrs     x2, cntpct_el0                        // x2 = updated counter
    sub     x2, x2, x1                            // x2 = number of oscillations since function start
    cmp     x2, x0                                // compare actual oscillation count against required oscillation count
    b.lo    1b                                    // loop if additional oscillations are required
  ret


.if UART_DEBUG
  .include "uart.s"
.endif
.include "reboot.s"
.include "paint.s"


# Converts a uint64 value to ASCII decimal representation. The caller must
# provide a buffer of at least 21 bytes. The result will be written to the end of
# the buffer, including a trailing 0 byte. The start address will be returned.
# The generated decimal string has no left padding with 0's or spaces etc.
#
# On entry:
#   x0 = address of 21 (or more) byte buffer to write to
#   x2 = value to convert to decimal
# On exit:
#   x0 = address of start of string within buffer
#   x1 = first char (byte) of generated string (e.g. 48-57 for '0'-'9', _not_ the address)
#   x2 = 0
#   x3 = 0xcccccccccccccccd
#   x4 = 0
base10:
  add     x0, x0, #0x14                           // x0 = address of last allocated byte
  strb    wzr, [x0]                               // Store 0 in last allocated byte
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                              // x3 = constant for divison by 10
  1:
    umulh   x4, x3, x2
    lsr     x4, x4, #3                            // x4 = x2 / 10
    add     x1, x4, x4, lsl #2                    // x1 = 5 * x4
    sub     x2, x2, x1, lsl #1                    // x2 = x2 % 10 = value of last digit
    add     x1, x2, #0x30                         // x1 = ASCII value of digit = x2 + 48
    strb    w1, [x0, #-1]!                        // store ASCII value on stack at correct offset
    mov     x2, x4                                // x2 = previous x2 / 10
    cbnz    x2, 1b                                // if x2 != 0 continue looping
3:
  ret


.if UART_DEBUG
msg_init_rand:                 .asciz "Initialising random number generator unit... "
msg_done:                      .asciz "DONE.\r\n"
msg_read:                      .asciz "read "
msg_write:                     .asciz "write "
.endif


.include "rng.s"
.if PCI_INCLUDE
# .include "pci.s"
  .include "pcie.s"
.endif
.include "irq.s"
.include "timer.s"


# Set initial values to rpi4 values, and replace at runtime if different machine.
#
# RPi 4/400 (bcm2711):
#   * https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf
#   * https://github.com/raspberrypi/firmware/issues/1374 (implies that low peripherals mode is enabled by default by VPU)

.align 3
mailbox_base:
  .quad     0xfe00b880 + _start                   // default is for rpi4
gpio_base:
  .quad     0xfe200000 + _start                   // default is for rpi4
aux_base:
  .quad     0xfe215000 + _start                   // default is for rpi4
rand_init:
  .quad     rand_init_iproc                       // default is for rpi4
rand_block:
  .quad     rand_block_iproc                      // default is for rpi4
rand_x0:
  .quad     rand_x0_iproc                         // default is for rpi4
aux_mu_baud_reg:
  .word     0x0000021d                            // default is for rpi4
cntfrq:
  .word     54000000                              // default is for rpi4
pcie_init:
.if PCI_INCLUDE
  .quad     pcie_init_bcm2711                     // default is for rpi4
.else
  .quad     0x0000000000000000                    // 0 => no pcie
.endif
local_control:
  .quad     0x00000000ff800000                    // default is for rpi4
                                                  // note, clock is set before MMU is enabled, so use physical (not virtual) address
timer_base:
  .quad     0xfe003000 + _start                   // default is for rpi4
enable_ic:
  .quad     enable_ic_bcm2711                     // default is for rpi4
handle_irq:
  .quad     handle_irq_bcm2711                    // default is for rpi4
peripherals_start:
  .quad     0x00000000fc000000                    // default is for rpi4
                                                  // used for MMU page tables, thus physical address needed
peripherals_end:
  .quad     0x0000000100000000                    // default is for rpi4
                                                  // used for MMU page tables, thus physical address needed


# RPi 3B (bcm2837):
#   * https://github.com/raspberrypi/documentation/issues/325 (explains differences between bcm2835 and bcm2837)
#   * https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf
.align 3
base_rpi3:
# rpi3 mailbox_base
  .quad     0x3f00b880 + _start
# rpi3 gpio_base
  .quad     0x3f200000 + _start
# rpi3 aux_base
  .quad     0x3f215000 + _start
# rpi3 rand_init
  .quad     rand_init_bcm283x
# rpi3 rand_block
  .quad     rand_block_bcm283x
# rpi3 rand_x0
  .quad     rand_x0_bcm283x
# rpi3 aux_mu_baud_reg
  .word     0x0000010e
# rpi3 cntfrq
  .word     19200000
# rpi3 pcie_init
  .quad     0x0000000000000000                    // 0 => no pcie
# rpi3 local_control (physical address, not virtual)
  .quad     0x0000000040000000
# rpi3 timer_base
  .quad     0x3f003000 + _start
# rpi3 enable_ic
  .quad     enable_ic_bcm283x
# rpi3 handle_irq
  .quad     handle_irq_bcm283x
# rpi3 peripherals_start (physical address, not virtual)
  .quad     0x000000003f000000
# rpi3 peripherals_end (physical address, not virtual)
  .quad     0x0000000040200000


.align 2
set_peripherals_addresses:
  mrs     x0, midr_el1                            // See https://developer.arm.com/documentation/ddi0601/2022-09/AArch64-Registers/MIDR-EL1--Main-ID-Register?lang=en
                                                  // x0 = Main ID Register value 0xNNNNNNNNIIVAPPPR, where:
                                                  //
                                                  // NNNNNNNN = N/A (reserved)
                                                  // II = Implementer
                                                  //   0x00: Reserved for software use
                                                  //   0xc0: Ampere Computing
                                                  //   0x41: Arm Limited
                                                  //   0x42: Broadcom Corporation
                                                  //   0x43: Cavium Inc.
                                                  //   0x44: Digital Equipment Corporation
                                                  //   0x46: Fujitsu Ltd.
                                                  //   0x49: Infineon Technologies AG
                                                  //   0x4d: Motorola or Freescale Semiconductor Inc.
                                                  //   0x4e: NVIDIA Corporation
                                                  //   0x50: Applied Micro Circuits Corporation
                                                  //   0x51: Qualcomm Inc.
                                                  //   0x56: Marvell International Ltd.
                                                  //   0x69: Intel Corporation
                                                  //   0xc0: Ampere Computing
                                                  // V = Variant
                                                  // A = Architecture
                                                  //   0x1: Armv4
                                                  //   0x2: Armv4T
                                                  //   0x3: Armv5(obsolete)
                                                  //   0x4: Armv5T
                                                  //   0x5: Armv5TE
                                                  //   0x6: Armv5TEJ
                                                  //   0x7: Armv6
                                                  //   0xf: Architectural features are individually identified in the ID_* registers, see 'ID registers'
                                                  // PPP = Part Number
                                                  //   0xd03: Raspberry Pi 3B (potentially also 3A+, 3B+, CM 3+, ...)
                                                  // R = Revision
                                                  //
                                                  // e.g.
                                                  //   0x00000000410fd034 (value on my Raspberry Pi 3 Model B)
                                                  //   => Implementer = 0x41 = Arm Limited
                                                  //   => Variant = 0x0 (r0 for r0p4)
                                                  //   => Architecture = 0xf = "features are identified in the ID_* registers"
                                                  //   => Part Number = 0xd03 (presumably, Raspberry Pi 3)
                                                  //   => Revision = 0x4 (p4 for r0p4)
                                                  //   0x00000000410fd083 (value on my Raspberry Pi 400)
                                                  //   => Implementer = 0x41 = Arm Limited
                                                  //   => Variant = 0x0 (r0 for r0p3)
                                                  //   => Architecture = 0xf = "features are identified in the ID_* registers"
                                                  //   => Part Number = 0xd08 (presumably, Raspberry Pi 4)
                                                  //   => Revision = 0x3 (p3 for r0p3)

# mrs     x1, revidr_el1                          // e.g. x1 = 0x80 (value on my Raspberry Pi 3 Model B)
                                                  //           0x00 (value on my Raspberry Pi 400)
  and     x0, x0, #0xfff0
  mov     x1, #0xd030
  cmp     x0, x1
  b.ne    1f
  adr     x0, base_rpi3
  adr     x1, mailbox_base
  ldp     x2, x3, [x0]                            //  x2 = [rpi3 mailbox_base]
                                                  //  x3 = [rpi3 gpio_base]
  ldp     x4, x5, [x0, #16]                       //  x4 = [rpi3 aux_base]
                                                  //  x5 = [rpi3 uart_init]
  ldp     x6, x7, [x0, #32]                       //  x6 = [rpi3 uart_block]
                                                  //  x7 = [rpi3 uart_x0]
  ldp     x8, x9, [x0, #48]                       //  x8 = [rpi3 aux_mu_baud_reg] (bits 0-31)
                                                  //       [rpi3 cntfrq] (bits 32-63)
                                                  //  x9 = [rpi3 pcie_init]
  ldp     x10, x11, [x0, #64]                     // x10 = [rpi3 local_control]
                                                  // x11 = [rpi3 timer_base]
  ldp     x12, x13, [x0, #80]                     // x12 = [rpi3 enable_ic]
                                                  // x13 = [rpi3 handle_irq]
  ldp     x14, x15, [x0, #96]                     // x14 = [rpi3 peripherals_start]
                                                  // x15 = [rpi3 peripherals_end]
  stp     x2, x3, [x1]                            // [mailbox_base]      = [rpi3 mailbox_base]
                                                  // [gpio_base]         = [rpi3 gpio_base]
  stp     x4, x5, [x1, #16]                       // [aux_base]          = [rpi3 aux_base]
                                                  // [uart_init]         = [rpi3 uart_init]
  stp     x6, x7, [x1, #32]                       // [uart_block]        = [rpi3 uart_block]
                                                  // [uart_x0]           = [rpi3 uart_x0]
  stp     x8, x9, [x1, #48]                       // [aux_mu_baud_reg]   = [rpi3 aux_mu_baud_reg] (32 bit)
                                                  // [cntfrq]            = [rpi3 cntfrq] (32 bit)
                                                  // [pcie_init]         = [rpi3 pcie_init]
  stp     x10, x11, [x1, #64]                     // [local_control]     = [rpi3 local_control]
                                                  // [timer_base]        = [rpi3 timer_base]
  stp     x12, x13, [x1, #80]                     // [enable_ic]         = [rpi3 enable_ic]
                                                  // [handle_irq]        = [rpi3 handle_irq]
  stp     x14, x15, [x1, #96]                     // [peripherals_start] = [rpi3 peripherals_start]
                                                  // [peripherals_end]   = [rpi3 peripherals_end]
1:
  ret


.align 2
# Emulates https://github.com/raspberrypi/tools/blob/2e59fc67d465510179155973d2b959e50a440e47/armstubs/armstub8.S#L98-L102
# which seems to be important for the frequency at which ARM register cntpct_el0 increments (used by wait_usec)
set_clocks:
  ldr     x0, local_control
                                                  // +=======================+
                                                  // | BCM ARM LOCAL CONTROL |
                                                  // +=======================+
                                                  //
                                                  // rpi3: https://datasheets.raspberrypi.com/bcm2836/bcm2836-peripherals.pdf page 9
                                                  // rpi4: https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf page 93
                                                  //
                                                  // TIMER_INCREMENT [8] = 0b0 => main timer increments by 1 (not 2)
                                                  // PROC_CLK_TIMER  [7] = 0b0 => main timer driven by fixed frequency crystal clock reference
                                                  // AXIERRIRQ_EN    [6] = 0b0 => main timer driven by fixed frequency crystal clock reference
  str     wzr, [x0]
  mov     w1, #0x80000000
  str     w1, [x0, 8]
  ret

memzero:
1:
  str     xzr, [x0], #8
  subs    x1, x1, #0x8
  b.gt    1b
  ret

.include "armregs.s"
.include "font.s"
.include "entry.s"
