#!/bin/bash
set -euo pipefail

TARGET="${TARGET:-/overlay}"
SOURCE="$(mktemp --suffix=.sp)"
trap 'rm -f "${SOURCE}"' EXIT

curl --fail --location --silent --show-error \
    "https://raw.githubusercontent.com/Robotex/l4d2_yandere_attack/54712726080c9618d492fc513738104fc5c289f9/scripting/l4d_superversus.sp" \
    --output "${SOURCE}"

sed -i 's/PrintToConsoleAll/SV_PrintToConsoleAll/g' "${SOURCE}"
mkdir -p "${TARGET}/addons/sourcemod/plugins" "${TARGET}/addons/sourcemod/gamedata"
"${TARGET}/addons/sourcemod/scripting/spcomp" \
    -i "${TARGET}/addons/sourcemod/scripting/include" \
    -o "${TARGET}/addons/sourcemod/plugins/l4d_superversus.smx" \
    "${SOURCE}"
install -m 0644 gamedata/l4d_superversus.txt \
    "${TARGET}/addons/sourcemod/gamedata/l4d_superversus.txt"

echo "Installed SuperVersus"
