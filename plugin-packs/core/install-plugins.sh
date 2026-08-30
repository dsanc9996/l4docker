#!/bin/bash
set -euo pipefail

LIST="${1:-plugins.list}"
TARGET="${TARGET:-/overlay}"

while IFS='|' read -r name url destination; do
    case "${name}" in ''|'#'*) continue ;; esac

    output="${TARGET}/${destination}"
    mkdir -p "$(dirname "${output}")"
    curl --fail --location --silent --show-error "${url}" --output "${output}"
    echo "Installed ${name}"
done < "${LIST}"
