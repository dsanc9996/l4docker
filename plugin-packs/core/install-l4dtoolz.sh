#!/bin/bash
set -euo pipefail

url="https://github.com/lakwsh/l4dtoolz/releases/download/2.5.1/l4dtoolz-2.5.1-main.zip"
sha256="86c5461a69fd756b8c90d48553a7111a3d7814012aa0bd3c510aae5591fb1049"
archive="$(mktemp)"

curl --fail --location --silent --show-error "${url}" --output "${archive}"
echo "${sha256}  ${archive}" | sha256sum --check --status
unzip -q "${archive}" l4dtoolz.so l4dtoolz.vdf -d /overlay/addons
rm -f "${archive}"

echo "Installed L4DToolZ 2.5.1"
