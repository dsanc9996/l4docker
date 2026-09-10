FROM ubuntu:24.04 AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl lib32stdc++6 libc6-i386 unzip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .
RUN sed -i 's/\r$//' install.sh get-mm-and-sm.sh install.d/*.sh \
 && bash ./install.sh

FROM scratch

LABEL org.opencontainers.image.title="L4D2 core plugin pack" \
      io.l4docker.pack.type="plugins" \
      io.l4docker.metamod.version="2.0.0-git1406" \
      io.l4docker.sourcemod.version="1.12.0-git7246" \
      io.l4docker.l4dtoolz.version="2.5.1"

COPY --from=builder /overlay/ /overlay/
