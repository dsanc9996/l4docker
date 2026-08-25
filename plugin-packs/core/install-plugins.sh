#!/bin/bash
set -euo pipefail

LOCK_FILE="${1:-plugins.lock}"
TARGET="${TARGET:-/overlay}"

while IFS='|' read -r name url sha256 destination; do
    case "${name}" in
        ''|'#'*) continue ;;
    esac

    download="$(mktemp)"
    curl --fail --location --silent --show-error "${url}" --output "${download}"
    echo "${sha256}  ${download}" | sha256sum --check --status

    install_path="${TARGET}/${destination}"
    mkdir -p "$(dirname "${install_path}")"
    install -m 0644 "${download}" "${install_path}"
    rm -f "${download}"

    echo "Installed ${name}"
done < "${LOCK_FILE}"
