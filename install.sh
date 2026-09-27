#!/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this installer as root: sudo ./install.sh" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

echo "Installing mpv and socat..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes mpv socat

echo "Installing radio commands and service..."
install -m 0755 "$SCRIPT_DIR/radio-play" /usr/local/bin/radio-play
install -m 0755 "$SCRIPT_DIR/radio-stop" /usr/local/bin/radio-stop
install -m 0755 "$SCRIPT_DIR/radio-volume" /usr/local/bin/radio-volume
install -m 0644 "$SCRIPT_DIR/radio.service" /etc/systemd/system/radio.service

systemctl daemon-reload
systemctl enable radio.service
systemctl restart radio.service

echo "Radio installed. Start listening with: radio-play"
