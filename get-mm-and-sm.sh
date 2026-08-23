#!/bin/bash

TARGET="/home/louis/l4d2/left4dead2"
METAMOD_URL="https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1406-linux.tar.gz"
SOURCEMOD_URL="https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7246-linux.tar.gz"

for url in \
    "$METAMOD_URL" \
    "$SOURCEMOD_URL"
do
    echo -e "Downloading content from $url\n"
    archive=$(curl --write-out "%{filename_effective}" -LO "$url")
    echo -e "\nExtracting $archive\n"
    tar -xzf "$archive" -C "$TARGET"
done

rm -f "$TARGET/addons/metamod_x64.vdf"

echo "Successfully downloaded and extracted metamod and sourcemod. Happy plugging!"
