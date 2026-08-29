#!/bin/bash
set -euo pipefail

VERSION="1.0.0"
URL="https://github.com/SirPlease/L4D2-Competitive-Rework/releases/download/v${VERSION}/L4D2-Competitive-Rework-v${VERSION}-linux.tar.gz"
SHA256="99a381716dce92db47e86a0b49beab9d60ba9963d54d7731ee485e538e7d7e38"
TARGET="${TARGET:-/overlay}"

archive="$(mktemp)"
unpacked="$(mktemp -d)"
trap 'rm -f "${archive}"; rm -rf "${unpacked}"' EXIT

curl --fail --location --silent --show-error "${URL}" --output "${archive}"
echo "${SHA256}  ${archive}" | sha256sum --check --status
tar -xzf "${archive}" -C "${unpacked}"

install_file() {
    source_path="${unpacked}/$1"
    target_path="${TARGET}/$2"
    mkdir -p "$(dirname "${target_path}")"
    install -m 0644 "${source_path}" "${target_path}"
}

install_file addons/sourcemod/plugins/left4dhooks.smx addons/sourcemod/plugins/left4dhooks.smx
install_file addons/sourcemod/plugins/optional/readyup.smx addons/sourcemod/plugins/readyup.smx
install_file addons/sourcemod/plugins/optional/playermanagement.smx addons/sourcemod/plugins/playermanagement.smx
install_file addons/sourcemod/extensions/builtinvotes.ext.2.l4d2.so addons/sourcemod/extensions/builtinvotes.ext.2.l4d2.so
install_file addons/sourcemod/gamedata/left4dhooks.l4d2.txt addons/sourcemod/gamedata/left4dhooks.l4d2.txt
install_file addons/sourcemod/gamedata/l4d2_si_ability.txt addons/sourcemod/gamedata/l4d2_si_ability.txt
install_file addons/sourcemod/data/left4dhooks.l4d2.cfg addons/sourcemod/data/left4dhooks.l4d2.cfg
install_file addons/sourcemod/translations/readyup.phrases.txt addons/sourcemod/translations/readyup.phrases.txt
install_file addons/sourcemod/translations/playermanagement.phrases.txt addons/sourcemod/translations/playermanagement.phrases.txt

echo "Installed ready-up and player management ${VERSION}"
