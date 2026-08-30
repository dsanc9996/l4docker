FROM ubuntu:24.04 AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl lib32stdc++6 libc6-i386 unzip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY get-mm-and-sm.sh .
COPY install-plugins.sh install-packages.sh install-superversus.sh plugins.list ./
COPY configs/ configs/
COPY gamedata/ gamedata/
RUN ./get-mm-and-sm.sh
RUN ./install-plugins.sh
RUN bash ./install-packages.sh
RUN bash ./install-superversus.sh
RUN if [ -f configs/admins_simple.ini ]; then \
      cp configs/admins_simple.ini /overlay/addons/sourcemod/configs/admins_simple.ini; \
    fi

FROM scratch

LABEL org.opencontainers.image.title="L4D2 core plugin pack" \
      io.l4docker.pack.type="plugins" \
      io.l4docker.metamod.version="2.0.0-git1406" \
      io.l4docker.sourcemod.version="1.12.0-git7246" \
      io.l4docker.l4dtoolz.version="2.5.1"

COPY --from=builder /overlay/ /overlay/
COPY cfg/ /overlay/cfg/
