FROM ubuntu:24.04 AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY get-mm-and-sm.sh .
COPY install-plugins.sh plugins.lock ./
RUN ./get-mm-and-sm.sh
RUN ./install-plugins.sh

FROM scratch

LABEL org.opencontainers.image.title="L4D2 core plugin pack" \
      io.l4docker.pack.type="plugins" \
      io.l4docker.metamod.version="2.0.0-git1406" \
      io.l4docker.sourcemod.version="1.12.0-git7246"

COPY --from=builder /overlay/ /overlay/
