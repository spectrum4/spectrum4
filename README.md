<!--
This file is part of the Spectrum +4 Project.
Licencing information can be found in the LICENCE file
(C) 2021 Spectrum +4 Authors. All rights reserved.
-->

# Spectrum +4

A reimagined ZX Spectrum, rewritten from scratch in ARM assembly (aarch64), to
run natively on the Raspberry Pi 400. Based on the ZX Spectrum 128K.

Originally targeted at the Raspberry Pi 3 Model B, the introduction of the
Raspberry Pi 400 led to an adaptation of the project for the newer model. The
USB hardware is easier to work with and requires support for only a single
keyboard.

For now, the code remains compatible with the Raspberry Pi 3 Model B, primarily
to support unit testing under QEMU. QEMU provides insufficient emulation of
Raspberry Pi 400 peripherals for the Spectrum +4 unit tests. Should the
support improve sufficiently, the unit tests may be migrated, and Raspberry Pi
3 Model B support discontinued.

Due to hardware similarity, the Spectrum +4 is also likely to run on the
Raspberry Pi 4 Model B, together with the standard Raspberry Pi USB Keyboard,
although this arrangement is untested.

If you are unfamiliar with the ZX Spectrum computer from the 1980s, there are
excellent emulators available, such as [Retro Virtual
Machine](http://www.retrovirtualmachine.org/), as well as high-quality online
emulators that can be run directly in your browser.

For more information about the history and development of this project, see
[https://github.com/spectrum4/notes](https://github.com/spectrum4/notes).

**Please note this project is in its early stages.**

**Only a handful of routines have been ported/implemented so far.**

## Why "Spectrum +4"?

The name "Spectrum +4" imagines what Sinclair/Amstrad might have developed
as a successor to the [ZX Spectrum
+3](https://sinclair.wiki.zxnet.co.uk/wiki/ZX_Spectrum_%2B2A/2B,_%2B3/3B) had
Raspberry Pi 400 hardware been available at the time. Rather than merely
replicating the original system, this project aims to evolve the platform while
maintaining its spirit. The development process also serves as an opportunity
to learn bare-metal programming and aarch64 assembly.

## Variations from the ZX Spectrum 128K

Spectrum +4 is intentionally incompatible with the original ZX Spectrum. For
running original ZX Spectrum software, consider using an emulator such as
[Retro Virtual Machine](https://www.retrovirtualmachine.org/en/) or
[ZXBaremulator](http://zxmini.speccy.org/en/index.html). Alternatively, modern
compatible hardware is available, such as the [ZX Spectrum
Next](https://www.specnext.com/shop/).

The following sections outline key differences between Spectrum +4 and the
original ZX Spectrum 128K.

## Graphics

![Screen loading demo](animated.gif)

To retain the spirit of the original ZX Spectrum computers, the video display
preserves many of the original design principles:

- The original colour palette
- Character cell restrictions:
  - Each cell is limited to a single 3-bit paper and 3-bit ink colour
  - Each cell may be `BRIGHT` or not
  - Each cell may `FLASH` or not
- A solid border colour around the edges of the display

With the increased screen estate now available to modern displays:

- Each character cell is now **16x16 pixels** instead of 8x8 pixels
- The screen is now **108 characters wide** instead of 32
- The screen is now **60 characters high** instead of 24

### Border Size

- **Left border**: 6 characters wide
- **Right border**: 6 characters wide
- **Top border**: 8 characters high
- **Bottom border**: 7 characters high

This preserves the original screen geometry:

- [http://www.zxdesign.info/vidparam.shtml](http://www.zxdesign.info/vidparam.shtml)

## Memory

The Raspberry Pi 400 features **4GB of RAM**, vastly more than the ZX Spectrum
128K. The 64-bit instruction set eliminates most of the memory paging routines
from the original ZX Spectrum, making more space available for BASIC programs,
machine code routines, and RAM disk storage.

- **Spectrum +4 is loaded at**: Physical ARM address `0x00000000`
- **RAM Disk size**: Initially set to **256MB**
- **Heap size**: Initially set to **256MB**

## Execution Context

- **Privilege Level**: Runs at EL1
- **Memory Management**: MMU enabled
- **Address Mapping**: Kernel virtual addresses map 1:1 with physical
  addresses, with upper 28 bits set (leaving a 36-bit address range)
- **Caching**:
  - EL1 data cache enabled
  - EL1 instruction cache enabled
- **Interrupts**: Configured and enabled (though keyboard routines are not yet
  implemented)

## Code Organisation

- All Spectrum +4 routines are written in **aarch64 assembly (GNU assembler
  syntax)**.
- The **source code** is located in `/src/spectrum4`.
- Build and test directives reside in various `Tup*` files throughout the
  repository (tup build system is used - see [Building](#building)).
- Naming conventions for system variables and routines match the disassembly in
  `src/spectrum128k/roms/romX.s`.
- Each ported routine includes a comment referencing the original ZX Spectrum
  128K routine it was derived from, using its 16-bit hexadecimal address.

## Building

To build and test everything, run:

```bash ./tup-under-docker.sh ```

This requires [`docker`](https://www.docker.com/) to be installed. The script
runs [`tup`](http://gittup.org/tup/index.html) inside a Docker container that
contains all required dependencies. Run `./tup-under-docker.sh -h` for
additional options.

If you prefer a native toolchain or cannot run Docker containers, see [Building
Without Docker](dev-setup/README.md).

## Running

After building, the following directories/files will be updated:

- `src/spectrum4/dist/`: Contains debug and release builds
- `src/spectrum128k/tests/`: Contains ZX Spectrum 128K tape images (`.tzx` and
  `.wav` files) for running tests under an emulator or on real hardware
- `src/spectrum4/targets/`: Contains Raspberry Pi kernel images for running
  test suites (QEMU or real Raspberry Pi)

### Running on a Raspberry Pi

To run Spectrum +4 on an actual Raspberry Pi:

- Copy the contents of the relevant distribution directory to a formatted SD
  card, **or**
- Serve the directory over **TFTP** to a network-boot-configured Raspberry Pi
  ([setup details](https://github.com/spectrum4/notes#5-rpi-3b-bootloading)).

### Running under QEMU

To run Spectrum +4 in QEMU:

```bash qemu-system-aarch64 -full-screen -M raspi3b -kernel \
src/spectrum4/targets/debug.elf -serial null -serial stdio ```

**Note:**

- **QEMU version 5.2.0 or later is required**.
- Use the `.elf` file for `-kernel` instead of `.img` to ensure it loads at
  address `0x0` rather than `0x80000`, which is not possible when using `.img`
  directly.
