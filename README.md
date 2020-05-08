# ZX Spectrum +4

A modern-day ZX Spectrum OS rewritten from scratch in ARM assembly (aarch64) to
run natively on RPi +3B. Based on the Spectrum 128K.

If you are not familiar with the ZX Spectrum computer from the 1980's, there
are some excellent emulators around, such as [Retro Virtual
Machine](http://www.retrovirtualmachine.org/), and even some very good online
emulators that you can run directly in your browser.

For more information about the history and development of this project, see
https://github.com/spectrum4/notes.

# Variations from the original Spectrum 128K.

## Graphics

In order to retain the spirit of the original Spectrum computers, the video
display preserves many of the original Spectrum principles:

  * The original colour palette
  * The original character cell restrictions
    * Each character cell is limited to a single 3 bit paper and 3 bit ink
      colour
    * Each character cell may be `BRIGHT` or not
    * Each character cell may FLASH or not
  * A solid border colour around the edges of the display

However, the screen geometry has changed a little:

  * Each character cell is now 16x16 pixels, rather than 8x8 pixels
  * The screen now is 108 character cells wide instead of 32
  * The screen now is 60 character cells high instead of 24

The border thickness is equivalent to the original Spectrum 128K with respect
to equivalent character cell counts:

  * Left border: width of 6 character cells
  * Right border: width of 6 character cells
  * Top border: height of 8 character cells
  * Bottom border: height of 7 character cells

This is designed to match the video display information in:
  * http://www.zxdesign.info/vidparam.shtml

In order to enforce the video restrictions, the current implementation wraps
updates to the display file / attributes file via the `poke_address` routine
which keeps the VideoCore IV GPU firmware framebuffer in sync with the new
display file and attributes file when updating these memory regions. This is
rather inefficient, but I don't know a better way to handle this for now.

Due to the changes screen dimensions, the display file and attributes file are
affected in the following ways: layout, with the following differences:

  * Each vertical screen third is now 20 character cells high rather than 8
  * Each cell now has 16 pixel rows instead of 8
  * A single pixel row of a character cell now requires 2 bytes instead of 1

Due to the new values often not being powers of two, the mechanics of
converting a memory address to x,y coordinates no longer is achieved with
simple bit manipulation. However, sequencially updating bytes in the display
and attributes file simulates the original screen loading mechanics, which is
nice to have preserved.


## Memory

The Raspberry Pi 3B has 1GB RAM, which is considerably more than the Spectrum
128K.  Using the 64 bit instruction set means that most of the memory paging
routines in the original Spectrum can be mostly ignored and don't require
translation. It also means that there is much more space available for BASIC
programs, machine code routines, and RAM disk storage.

* Spectrum +4 is loaded at physical ARM address 0x00000000
* The RAM Disk is initially set to 256MB
* The HEAP is initially set to 256MB


## Execution context

* Spectrum +4 runs at EL3
* MMU is not enabled
* EL3 data cache is enabled
* EL3 instruction cache is enabled
* Currently interrupts are not enabled (keyboard routines not yet written)


# Code organisation

* All code is written in aarch64 assembly.
* All source codes is under the `/src` directory.
* The build script is `/all.sh` in the top folder.
* The majority of code is in `/src/rom0.s` and `/src/rom1.s` which are a
  translation of the original Spectrum 128K ROM routines.
* As much as possible, the naming of system variables and routines, and
  the ordering of routines, match the disassembly documents cited in the
  `romX.s` files.
* The definition of each routine has a comment with the label of the associated
  disassembly, to map back to the original routine. The label is an `L`
  followed by the 64 bit address of the routine in hexadecimal, for convenient
  mapping back to the original Spectrum 128K disassembly code.

## Building

To build, you will require an aarch64 toolchain in your PATH, including the
following tools:

  * aarch64-none-elf-as
  * aarch64-none-elf-ld
  * aarch64-none-elf-readelf
  * aarch64-none-elf-objcopy
  * aarch64-none-elf-objdump

You will also need bash installed.

To build, run `./all.sh` from the root folder to build everything.

If your toolchain has a different prefix to "aarch64-none-elf-" then export
environment variable `TOOLCHAIN_PREFIX` containing the prefix you wish to use
instead.  If you wish to use no prefix at all (`as`, `ld`, `readelf`,
`objcopy`, `objdump`) because you are e.g. building on a Raspberry Pi directly,
explicitly set `TOOLCHAIN_PREFIX` to the empty string:

```
$ export TOOLCHAIN_PREFIX=''
```

After building the contents of the repository `/dist` directory can be copied
to an SD card to place in your Raspberry Pi 3B, or for example they can be
served over TFTP to a suitably configured Raspberry Pi that has been configured
to network boot. The github.com/spectrum4/notes project has some information
about that type of setup, if you are interested.
