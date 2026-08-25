ARG SERVER_IMAGE=dsanc9996/l4docker:server-core
ARG PLUGIN_IMAGE=dsanc9996/l4docker:plugins-core

FROM ${PLUGIN_IMAGE} AS plugins
FROM ${SERVER_IMAGE}

COPY --from=plugins --chown=louis:louis /overlay/addons/ /addons/
COPY --from=plugins --chown=louis:louis /overlay/cfg/ /cfg/
