FROM ubuntu:20.04 AS spectrum4_too_much
MAINTAINER Pete Moore <petemoore@gmx.net>
COPY bootstrap.sh /
RUN ./bootstrap.sh

# now build a fresh image, with just the files in /dist
FROM scratch
COPY --from=spectrum4_too_much /dist/ /
ENV PATH /usr/lib/go/bin:/bin:/usr/bin:/usr/local/bin
ENV GOROOT /usr/lib/go
