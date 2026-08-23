#!/bin/bash
set -e

TARGET="${TARGET:-/overlay}"
METAMOD_URL="${METAMOD_URL:-https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1406-linux.tar.gz}"
SOURCEMOD_URL="${SOURCEMOD_URL:-https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7246-linux.tar.gz}"

mkdir -p "${TARGET}"

for url in \
    "${METAMOD_URL}" \
    "${SOURCEMOD_URL}"
do
    echo -e "Downloading content from ${url}\n"
    archive=$(curl --write-out "%{filename_effective}" -LO "${url}")
    echo -e "\nExtracting ${archive}\n"
    tar -xzf "${archive}" -C "${TARGET}"
done

rm -f "${TARGET}/addons/metamod_x64.vdf"

echo "Successfully downloaded and extracted metamod and sourcemod. Happy plugging!"
