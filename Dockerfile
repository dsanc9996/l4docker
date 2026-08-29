ARG SERVER_IMAGE=dsanc9996/l4docker:server-core
ARG PLUGIN_IMAGE=dsanc9996/l4docker:plugins-core
ARG ADDON_IMAGE

FROM ${PLUGIN_IMAGE} AS plugins
FROM ${ADDON_IMAGE} AS addons
FROM ${SERVER_IMAGE}

COPY --from=plugins --chown=louis:louis /overlay/addons/ /addons/
COPY --from=plugins --chown=louis:louis /overlay/cfg/ /cfg/
COPY --from=addons --chown=louis:louis /overlay/addons/ /addons/
