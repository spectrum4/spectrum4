### Building natively on your host

For those who prefer to use a native toolchain rather than docker, or cannot
run docker/amd64 containers for some reason (e.g. if building/testing directly
on a Raspberry Pi).

You will require an aarch64 toolchain in your PATH, including the following
tools:

  * [`aarch64-none-elf-as`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`aarch64-none-elf-ld`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`aarch64-none-elf-readelf`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`aarch64-none-elf-objcopy`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`aarch64-none-elf-objdump`](https://www.gnu.org/software/binutils/) (from binutils)

If your toolchain has a different prefix to "aarch64-none-elf-" then export
environment variable `AARCH64_TOOLCHAIN_PREFIX` containing the prefix you wish
to use instead.  If you wish to use no prefix at all (`as`, `ld`, `readelf`,
`objcopy`, `objdump`) because you are e.g. building on a Raspberry Pi directly,
explicitly set `AARCH64_TOOLCHAIN_PREFIX` to the empty string:

```
$ export AARCH64_TOOLCHAIN_PREFIX=''
```

You will also need a z80 toolchain in your PATH, and `fuse`, for running the
Spectrum 128K unit tests against an emulated Spectrum 128K:

  * [`fuse`](http://fuse-emulator.sourceforge.net/)
  * [`z80-unknown-elf-as`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`z80-unknown-elf-ld`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`z80-unknown-elf-readelf`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`z80-unknown-elf-objcopy`](https://www.gnu.org/software/binutils/) (from binutils)
  * [`z80-unknown-elf-objdump`](https://www.gnu.org/software/binutils/) (from binutils)

If using gnu binutils, you will require __version 2.36 or later__.

Just as above for the aarch64 toolchain, you can also use a different prefix
than `z80-unknown-elf-` for the z80 toolchain by exporting the
`Z80_TOOLCHAIN_PREFIX` environment variable.

You will also require `qemu-system-aarch64` for running the Spectrum +4 test
suite:

  * [`qemu-system-aarch64`](https://www.qemu.org/) (v5.2.0 or later)

Note, GNU gas assembly syntax is assumed, so some z80 assemblers may use
incompatible syntax. GNU gas assembly syntax was chosen for this project to
keep the z80 and aarch64 assembly as closely aligned as possible.

You will also require:

  * [`bash`](https://www.gnu.org/software/bash/)
  * [`cat`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`cmp`](https://www.gnu.org/software/diffutils/) (from diffutils)
  * [`cp`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`curl`](https://github.com/curl/curl/)
  * [`dirname`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`env`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`find`](https://www.gnu.org/software/findutils/) (from findutils)
  * [`go`](https://golang.org/)
  * [`head`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`hexdump`](https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/) (from util-linux)
  * [`ln`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`md5sum`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`mkdir`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`mv`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`rm`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`sed`](https://www.gnu.org/software/sed/)
  * [`sleep`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`sort`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`tape2wav`](https://sourceforge.net/p/fuse-emulator/fuse-utils/ci/master/tree/) (from fuse-utils)
  * [`tup`](http://gittup.org/tup/)
  * [`wc`](https://www.gnu.org/software/coreutils/) (from coreutils)
  * [`which`](https://carlowood.github.io/which/) (which likely in turn requires [`/bin/sh`](https://www.gnu.org/software/bash/))

To check your environment is suitable for building, run `./check-env.sh` from
the root folder to build everything.

Run `./check-env.sh -h` to see additional options.

Once the output of `check-env.sh` says that your environment is suitably
configured, you can build simply by running `tup` in any directory of the
repository.

Note, if you switch between running `tup` and `./tup-under-docker.sh`,
everything will be rebuilt, so you are usually better off sticking with one
command or the other.
