#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p /overlay/game /overlay/cfg

bash ./get-mm-and-sm.sh

for installer in install.d/*.sh; do
    echo "Running ${installer}"
    bash "${installer}"
done

cp -R cfg/. /overlay/cfg/

if [[ -f configs/admins_simple.ini ]]; then
    install -m 0644 configs/admins_simple.ini \
        /overlay/addons/sourcemod/configs/admins_simple.ini
fi
