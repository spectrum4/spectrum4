FROM ubuntu:20.04 AS ubuntu
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget xz-utils
RUN wget -nv -O gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz 'https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz?revision=ea238776-c7c7-43be-ba0d-40d7f594af1f&la=en&hash=2937ED76D3E6B85BA511BCBD46AE121DBA5268F3' \
    && tar xvf gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz \
    && rm gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz
FROM bash:5.0.18
COPY --from=ubuntu /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=ubuntu /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libdl.so.2
COPY --from=ubuntu /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
COPY --from=ubuntu /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-as /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-as
COPY --from=ubuntu /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-ld /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-ld
COPY --from=ubuntu /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-objcopy /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-objcopy
COPY --from=ubuntu /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-objdump /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-objdump
COPY --from=ubuntu /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-readelf /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/aarch64-none-elf-readelf

ENV PATH $PATH:/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin
