#!/bin/bash
./steamcmd.sh +runscript update.txt
export LD_LIBRARY_PATH="/home/louis/l4d2/bin:${LD_LIBRARY_PATH:-}"

cd "${INSTALL_DIR}" || exit 50

if [ "${INSTALL_DIR}" = "l4d2" ]; then
    GAME_DIR="left4dead2"
elif [ "${INSTALL_DIR}" = "l4d" ]; then
    GAME_DIR="left4dead"
else
    exit 100
fi

if [ $# -gt 0 ]; then
    ./srcds_run "$@"
else
    STARTUP=("./srcds_run" "-game" "${GAME_DIR}")
    STARTUP+=("-tickrate" "${TICKRATE}")
    STARTUP+=("+sv_logecho" "1")
    STARTUP+=("+hostname" "${HOSTNAME}")
    STARTUP+=("+sv_region" "${REGION}")

    STARTUP+=("+motd_enabled" "${MOTD}")

    if [[ -e "${GAME_DIR}/myhost.txt" ]]; then
      STARTUP+=("+hostfile" "myhost.txt")
    elif [ -n "${HOST_CONTENT}" ]; then
      echo "${HOST_CONTENT}" > "${GAME_DIR}/envhost.txt"
      STARTUP+=("+hostfile" "envhost.txt")
    else
      echo "${HOSTNAME}" > "${GAME_DIR}/myhostname.txt"
      STARTUP+=("+hostfile" "myhostname.txt")
    fi

    if [[ -e "${GAME_DIR}/mymotd.txt" ]]; then
      STARTUP+=("+motdfile" "mymotd.txt")
    elif [ -n "${MOTD_CONTENT}" ]; then
      echo "${MOTD_CONTENT}" > "${GAME_DIR}/envmotd.txt"
      STARTUP+=("+motdfile" "envmotd.txt")
    fi

    if [ "${STEAM_GROUP}" -gt 0 ]; then
        STARTUP+=("+sv_steamgroup" "${STEAM_GROUP}")
        if [ "${STEAM_GROUP_EXCLUSIVE}" ] ; then
            STARTUP+=("+sv_steamgroup_exclusive" "1")
        fi
    fi

    if [ -n "${GAME_TYPES}" ]; then
        STARTUP+=("+sv_gametypes" "${GAME_TYPES}")
    fi

    STARTUP+=("+mp_gamemode" "${DEFAULT_MODE}")

    if [ "${MAX_PLAYERS:-0}" -gt 0 ]; then
        STARTUP+=("+sv_setmax" "${MAX_PLAYERS}")
        STARTUP+=("+sv_maxplayers" "${MAX_PLAYERS}")
    fi

    # SourceMod needs a delayed map command on L4D2.
    SOURCEMOD_BOOTSTRAP=0
    if [[ -f "${GAME_DIR}/addons/sourcemod/bin/sourcemod.2.l4d2.so" ]]; then
        SOURCEMOD_BOOTSTRAP=1
        STARTUP+=("-nodefaultmap")
    else
        STARTUP+=("+map" "${DEFAULT_MAP}")
    fi

    if [ "${FORK:-0}" -gt 0 ]; then
        STARTUP+=("-fork" "${FORK}" "+exec" "server##.cfg")
    else
        if [ "${PORT:-0}" -gt 0 ]; then
            STARTUP+=("-port" "${PORT}")
        fi
    fi

    if [ "${LAN}" ] ; then
        STARTUP+=("+sv_lan" "1")
    fi

    if [ -n "${RCON_PASSWORD}" ]; then
        STARTUP+=("+rcon_password" "${RCON_PASSWORD}")
    fi

    if [ "${NET_CON_PORT:-0}" -gt 0 ]; then
        STARTUP+=("-netconport" "${NET_CON_PORT}")
        if [ -n "${NET_CON_PASSWORD}" ]; then
            STARTUP+=("-netconpassword" "${NET_CON_PASSWORD}")
        fi
    fi

    if [ -n "${EXTRA_ARGS}" ]; then
        STARTUP+=("${EXTRA_ARGS}")
    fi

    if [ "${SOURCEMOD_BOOTSTRAP}" -eq 0 ]; then
        exec "${STARTUP[@]}"
    fi

    CONSOLE_FIFO="/tmp/l4d2-console.$$"
    mkfifo "${CONSOLE_FIFO}"
    exec 3<>"${CONSOLE_FIFO}"
    rm -f "${CONSOLE_FIFO}"

    console() {
        printf '%s\n' "$1" >&3
    }

    "${STARTUP[@]}" <&3 &
    SERVER_PID=$!

    cleanup() {
        kill -TERM "${SERVER_PID}" 2>/dev/null || true
        wait "${SERVER_PID}" 2>/dev/null || true
    }
    trap cleanup TERM INT

    (
        sleep "${SOURCEMOD_MAP_DELAY:-12}"
        if kill -0 "${SERVER_PID}" 2>/dev/null; then
            console "hostname \"${HOSTNAME//\"/\\\"}\""
            console "sv_region ${REGION}"
            console "sv_steamgroup ${STEAM_GROUP}"
            console "sv_gametypes \"${GAME_TYPES//\"/\\\"}\""
            console "map ${DEFAULT_MAP} ${DEFAULT_MODE}"
            sleep 8
            console "sv_allow_lobby_connect_only 0"
        fi
    ) &

    wait "${SERVER_PID}"
    SERVER_STATUS=$?
    trap - TERM INT
    exit "${SERVER_STATUS}"
fi
