#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture i386
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    locales \
    tar \
    telnet \
    libc6:i386 \
    libcurl4t64:i386 \
    libgcc-s1:i386 \
    libsdl2-2.0-0:i386 \
    libstdc++6:i386
rm -rf /var/lib/apt/lists/*

useradd --create-home --shell /bin/bash louis

mkdir             /addons /cfg /motd /tmp/dumps
chown louis:louis /addons /cfg /motd /tmp/dumps
