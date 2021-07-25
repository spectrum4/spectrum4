### Building natively on your host

For those who prefer to use a native toolchain rather than docker, or cannot
run docker/amd64 containers for some reason (e.g. if building/testing directly
on a Raspberry Pi).

You will require an aarch64 toolchain in your PATH, including the following
tools:

  * `aarch64-none-elf-as`
  * `aarch64-none-elf-ld`
  * `aarch64-none-elf-readelf`
  * `aarch64-none-elf-objcopy`
  * `aarch64-none-elf-objdump`

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

  * `fuse`
  * `z80-unknown-elf-as`
  * `z80-unknown-elf-ld`
  * `z80-unknown-elf-readelf`
  * `z80-unknown-elf-objcopy`
  * `z80-unknown-elf-objdump`

If using gnu binutils, you will require __version 2.36 or later__.

Just as above for the aarch64 toolchain, you can also use a different prefix
than `z80-unknown-elf-` for the z80 toolchain by exporting the
`Z80_TOOLCHAIN_PREFIX` environment variable.

You will also require `qemu-system-aarch64` for running the Spectrum +4 test
suite:

  * `qemu-system-aarch64` (v5.2.0 or later)

Note, GNU gas assembly syntax is assumed, so some z80 assemblers may use
incompatible syntax. GNU gas assembly syntax was chosen for this project to
keep the z80 and aarch64 assembly as closely aligned as possible.

You will also require:

  * `bash`
  * `cat`
  * `cmp`
  * `cp`
  * `curl`
  * `dirname`
  * `env`
  * `find`
  * `go`
  * `head`
  * `hexdump`
  * `ln`
  * `md5sum`
  * `mkdir`
  * `mv`
  * `rm`
  * `sed`
  * `sleep`
  * `sort`
  * `tape2wav` (from fuse-utils)
  * `tup`
  * `wc`
  * `which` (which likely in turn requires `/bin/sh`)

To check your environment is suitable for building, run `./check-env.sh` from
the root folder to build everything.

Run `./check-env.sh -h` to see additional options.

Once the output of `check-env.sh` says that your environment is suitably
configured, you can build simply by running `tup` in any directory of the
repository.

Note, if you switch between running `tup` and `./tup-under-docker.sh`,
everything will be rebuilt, so it is far more efficient to use one or the
other, rather than alternate between the two.
