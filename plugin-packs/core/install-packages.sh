#!/bin/bash
set -euo pipefail

LIST="${1:-packages.list}"
TARGET="${TARGET:-/overlay}"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

while IFS='|' read -r name type url source destination; do
    case "${name}" in ''|'#'*) continue ;; esac

    package="${WORK}/${name}"
    archive="${package}.${type}"
    mkdir -p "${package}"
    curl --fail --location --silent --show-error "${url}" --output "${archive}"

    case "${type}" in
        zip) unzip -q "${archive}" -d "${package}" ;;
        tar) tar -xzf "${archive}" -C "${package}" ;;
        *) echo "Unsupported package type '${type}' for ${name}" >&2; exit 1 ;;
    esac

    input="${package}/${source}"
    output="${TARGET}/${destination}"
    if [[ -d "${input}" ]]; then
        mkdir -p "${output}"
        cp -R "${input}/." "${output}/"
    else
        mkdir -p "$(dirname "${output}")"
        install -m 0644 "${input}" "${output}"
    fi

    echo "Installed ${name}"
done < "${LIST}"
