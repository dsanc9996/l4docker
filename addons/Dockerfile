ARG SERVER_IMAGE=dsanc9996/l4docker:server-core

FROM ${SERVER_IMAGE} AS downloader

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-requests \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /overlay/addons \
 && chown -R louis:louis /overlay

WORKDIR /build
COPY --chown=louis:louis download_addons.py .

ARG COLLECTION_ID
USER louis
RUN test -n "${COLLECTION_ID}" \
 && python3 download_addons.py "${COLLECTION_ID}"

FROM scratch

LABEL org.opencontainers.image.title="L4D2 Workshop addon pack" \
      io.l4docker.pack.type="addons"

COPY --from=downloader /overlay/ /overlay/
