ARG SERVER_IMAGE=dsanc9996/l4d2-server-core:latest
ARG PLUGIN_IMAGE=dsanc9996/l4d2-plugin-pack:core

FROM ${PLUGIN_IMAGE} AS plugins
FROM ${SERVER_IMAGE}

COPY --from=plugins --chown=louis:louis /overlay/addons/ /addons/
COPY --from=plugins --chown=louis:louis /overlay/cfg/ /cfg/
