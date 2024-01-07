# syntax=docker/dockerfile:1.3

FROM ubuntu:latest AS spectrum4_too_much
MAINTAINER Pete Moore <petemoore@gmx.net>
COPY ./ubuntu/bootstrap-ubuntu.sh /
RUN ./bootstrap-ubuntu.sh

# The following section is a mechanism to strip down the docker image to just
# the files that are needed. Unfortunately, aarch64-none-elf-gdb is not able to
# connect to a remote qemu debugging server using this method, so for now I am
# disabling it. This means the pmoore/spectrum4 docker images will be much
# bigger, but at least they still work. If at some point we work out while
# additional files are needed for aarch64-none-elf-gdb remote debugging to
# work, we can return to stripped down images...
#
# COPY ./docker/extract-dist.sh /
# RUN ./extract-dist.sh
# now build a fresh image, with just the files in /dist
# FROM scratch
# COPY --from=spectrum4_too_much /dist/ /

ENV PATH /usr/lib/go/bin:/bin:/usr/bin:/usr/local/bin
ENV GOROOT /usr/lib/go
