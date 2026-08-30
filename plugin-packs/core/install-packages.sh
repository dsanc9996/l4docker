#!/bin/bash
set -euo pipefail

TARGET="${TARGET:-/overlay}"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

download_zip() {
    curl --fail --location --silent --show-error "$1" --output "${WORK}/package.zip"
    rm -rf "${WORK}/package"
    mkdir -p "${WORK}/package"
    unzip -q "${WORK}/package.zip" -d "${WORK}/package"
}

download_tar() {
    curl --fail --location --silent --show-error "$1" --output "${WORK}/package.tar.gz"
    rm -rf "${WORK}/package"
    mkdir -p "${WORK}/package"
    tar -xzf "${WORK}/package.tar.gz" -C "${WORK}/package"
}

copy_file() {
    mkdir -p "$(dirname "${TARGET}/$2")"
    install -m 0644 "${WORK}/package/$1" "${TARGET}/$2"
}

copy_directory() {
    mkdir -p "${TARGET}/$2"
    cp -R "${WORK}/package/$1/." "${TARGET}/$2/"
}

download_zip "https://github.com/lakwsh/l4dtoolz/releases/download/2.5.1/l4dtoolz-2.5.1-main.zip"
copy_file l4dtoolz.so addons/l4dtoolz.so
copy_file l4dtoolz.vdf addons/l4dtoolz.vdf

download_tar "https://github.com/SirPlease/L4D2-Competitive-Rework/releases/download/v1.0.0/L4D2-Competitive-Rework-v1.0.0-linux.tar.gz"
copy_file addons/sourcemod/plugins/left4dhooks.smx addons/sourcemod/plugins/left4dhooks.smx
copy_file addons/sourcemod/plugins/optional/readyup.smx addons/sourcemod/plugins/readyup.smx
copy_file addons/sourcemod/plugins/optional/survivor_mvp.smx addons/sourcemod/plugins/survivor_mvp.smx
copy_file addons/sourcemod/extensions/builtinvotes.ext.2.l4d2.so addons/sourcemod/extensions/builtinvotes.ext.2.l4d2.so
copy_file addons/sourcemod/gamedata/left4dhooks.l4d2.txt addons/sourcemod/gamedata/left4dhooks.l4d2.txt
copy_file addons/sourcemod/gamedata/l4d2_si_ability.txt addons/sourcemod/gamedata/l4d2_si_ability.txt
copy_file addons/sourcemod/data/left4dhooks.l4d2.cfg addons/sourcemod/data/left4dhooks.l4d2.cfg
copy_file addons/sourcemod/translations/readyup.phrases.txt addons/sourcemod/translations/readyup.phrases.txt

download_zip "https://github.com/rikka0w0/l4d2_mission_manager/releases/download/v2.3.0/acs_v2.3.0.zip"
copy_directory plugins addons/sourcemod/plugins
copy_directory gamedata addons/sourcemod/gamedata
copy_directory translations addons/sourcemod/translations

echo "Installed plugin packages"
