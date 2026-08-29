FROM ubuntu:24.04 AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl unzip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY get-mm-and-sm.sh .
COPY install-plugins.sh install-l4dtoolz.sh install-competitive.sh plugins.lock ./
COPY configs/ configs/
RUN ./get-mm-and-sm.sh
RUN ./install-plugins.sh
RUN ./install-l4dtoolz.sh
RUN ./install-competitive.sh
RUN cp configs/admins_simple.ini /overlay/addons/sourcemod/configs/admins_simple.ini

FROM scratch

LABEL org.opencontainers.image.title="L4D2 core plugin pack" \
      io.l4docker.pack.type="plugins" \
      io.l4docker.metamod.version="2.0.0-git1406" \
      io.l4docker.sourcemod.version="1.12.0-git7246" \
      io.l4docker.l4dtoolz.version="2.5.1"

COPY --from=builder /overlay/ /overlay/
COPY cfg/ /overlay/cfg/
